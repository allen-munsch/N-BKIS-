from typing import Dict, List, Optional
import asyncio
import logging
from datetime import datetime
from dataclasses import dataclass

from ..hardware.fpga_interface import FPGAInterface
from ..models.system_state import ChamberId

logger = logging.getLogger(__name__)

@dataclass
class ChamberState:
    chamber_id: ChamberId
    intensity: float  # 0.0 to 1.0
    pressure: float  # kPa
    temperature: float  # °C
    flow_rate: float  # mL/min
    last_update: datetime
    active: bool

class ChamberController:
    def __init__(self, fpga: FPGAInterface):
        self.fpga = fpga
        self._chamber_states: Dict[int, ChamberState] = {}
        self._control_lock = asyncio.Lock()
        self._monitoring_task: Optional[asyncio.Task] = None

    async def initialize_chambers(self, chamber_configs: List[ChamberId]):
        """Initialize chamber configurations."""
        try:
            async with self._control_lock:
                for config in chamber_configs:
                    self._chamber_states[config.id] = ChamberState(
                        chamber_id=config,
                        intensity=0.0,
                        pressure=0.0,
                        temperature=0.0,
                        flow_rate=0.0,
                        last_update=datetime.now(),
                        active=False
                    )
                
                # Start monitoring
                if not self._monitoring_task:
                    self._monitoring_task = asyncio.create_task(self._monitor_chambers())
                
                logger.info(f"Initialized {len(chamber_configs)} chambers")
                
        except Exception as e:
            logger.error(f"Error initializing chambers: {e}")
            raise

    async def set_chamber_intensity(self, chamber_id: int, intensity: float) -> bool:
        """Set the intensity for a specific chamber."""
        try:
            async with self._control_lock:
                if chamber_id not in self._chamber_states:
                    logger.error(f"Invalid chamber ID: {chamber_id}")
                    return False
                
                # Validate intensity
                intensity = max(0.0, min(1.0, intensity))
                
                # Set intensity through FPGA
                await self.fpga.set_chamber_intensity(chamber_id, intensity)
                
                # Update state
                state = self._chamber_states[chamber_id]
                state.intensity = intensity
                state.active = (intensity > 0)
                state.last_update = datetime.now()
                
                return True
                
        except Exception as e:
            logger.error(f"Error setting chamber intensity: {e}")
            return False

    async def get_chamber_state(self, chamber_id: int) -> Optional[ChamberState]:
        """Get the current state of a chamber."""
        if chamber_id in self._chamber_states:
            return self._chamber_states[chamber_id]
        return None

    async def _monitor_chambers(self):
        """Monitor all chamber states."""
        while True:
            try:
                async with self._control_lock:
                    for chamber_id, state in self._chamber_states.items():
                        # Read chamber sensors
                        pressure = await self.fpga.read_chamber_pressure(chamber_id)
                        temperature = await self.fpga.read_chamber_temperature(chamber_id)
                        flow_rate = await self.fpga.read_chamber_flow(chamber_id)
                        
                        # Update state
                        state.pressure = pressure
                        state.temperature = temperature
                        state.flow_rate = flow_rate
                        state.last_update = datetime.now()
                        
                        # Check for issues
                        if state.active:
                            if flow_rate < 0.1:
                                logger.warning(f"Low flow in chamber {chamber_id}")
                            if pressure > 110:
                                logger.warning(f"High pressure in chamber {chamber_id}")
                            if temperature > 45:
                                logger.warning(f"High temperature in chamber {chamber_id}")
                
                await asyncio.sleep(0.1)  # 10Hz monitoring
                
            except asyncio.CancelledError:
                raise
            except Exception as e:
                logger.error(f"Error in chamber monitoring: {e}")
                await asyncio.sleep(1)

    async def shutdown_chamber(self, chamber_id: int) -> bool:
        """Safely shutdown a specific chamber."""
        try:
            async with self._control_lock:
                if chamber_id not in self._chamber_states:
                    return False
                
                # Gradually reduce intensity
                current_intensity = self._chamber_states[chamber_id].intensity
                steps = 20
                for i in range(steps):
                    new_intensity = current_intensity * (1 - ((i + 1) / steps))
                    await self.fpga.set_chamber_intensity(chamber_id, new_intensity)
                    await asyncio.sleep(0.05)
                
                # Final shutdown
                await self.fpga.set_chamber_intensity(chamber_id, 0.0)
                self._chamber_states[chamber_id].intensity = 0.0
                self._chamber_states[chamber_id].active = False
                
                return True
                
        except Exception as e:
            logger.error(f"Error shutting down chamber {chamber_id}: {e}")
            return False

    async def emergency_shutdown(self) -> bool:
        """Emergency shutdown of all chambers."""
        try:
            async with self._control_lock:
                # Immediate shutdown of all chambers
                tasks = [
                    self.fpga.set_chamber_intensity(chamber_id, 0.0)
                    for chamber_id in self._chamber_states
                ]
                await asyncio.gather(*tasks)
                
                # Update states
                for state in self._chamber_states.values():
                    state.intensity = 0.0
                    state.active = False
                    state.last_update = datetime.now()
                
                return True
                
        except Exception as e:
            logger.error(f"Error in emergency shutdown: {e}")
            return False