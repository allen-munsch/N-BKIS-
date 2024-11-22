from typing import Dict, Optional
import asyncio
import logging
from datetime import datetime
from dataclasses import dataclass

from ..hardware.fpga_interface import FPGAInterface
from ..models.system_state import SensorType
from ..safety.monitor import SafetyMonitor

logger = logging.getLogger(__name__)

@dataclass
class VentilationState:
    active: bool
    fan_speed: float  # 0.0 to 1.0
    damper_position: float  # 0.0 to 1.0
    flow_rate: float  # L/min
    pressure: float  # kPa
    last_update: datetime

class VentilationController:
    def __init__(self, fpga: FPGAInterface, safety_monitor: SafetyMonitor):
        self.fpga = fpga
        self.safety_monitor = safety_monitor
        self._control_lock = asyncio.Lock()
        self._monitoring_task: Optional[asyncio.Task] = None
        self.state = VentilationState(
            active=False,
            fan_speed=0.0,
            damper_position=0.0,
            flow_rate=0.0,
            pressure=0.0,
            last_update=datetime.now()
        )

    async def start_ventilation(self, emergency: bool = False) -> bool:
        """Start ventilation system."""
        async with self._control_lock:
            try:
                if emergency:
                    # Emergency ventilation - maximum settings
                    await self.fpga.set_fan_speed(1.0)
                    await self.fpga.set_damper_position(1.0)
                    self.state.fan_speed = 1.0
                    self.state.damper_position = 1.0
                else:
                    # Normal ventilation - gradual ramp-up
                    await self._ramp_up_ventilation()
                
                self.state.active = True
                self.state.last_update = datetime.now()
                
                # Start monitoring if not already running
                if not self._monitoring_task:
                    self._monitoring_task = asyncio.create_task(self._monitor_ventilation())
                
                return True
                
            except Exception as e:
                logger.error(f"Error starting ventilation: {e}")
                return False

    async def stop_ventilation(self) -> bool:
        """Stop ventilation system."""
        async with self._control_lock:
            try:
                await self._ramp_down_ventilation()
                self.state.active = False
                self.state.last_update = datetime.now()
                
                if self._monitoring_task:
                    self._monitoring_task.cancel()
                    self._monitoring_task = None
                
                return True
                
            except Exception as e:
                logger.error(f"Error stopping ventilation: {e}")
                return False

    async def _ramp_up_ventilation(self):
        """Gradually increase ventilation."""
        try:
            # Open damper first
            for position in range(0, 101, 10):
                damper_pos = position / 100.0
                await self.fpga.set_damper_position(damper_pos)
                self.state.damper_position = damper_pos
                await asyncio.sleep(0.1)

            # Then increase fan speed
            for speed in range(0, 101, 5):
                fan_speed = speed / 100.0
                await self.fpga.set_fan_speed(fan_speed)
                self.state.fan_speed = fan_speed
                await asyncio.sleep(0.1)

        except Exception as e:
            logger.error(f"Error in ventilation ramp-up: {e}")
            raise

    async def _ramp_down_ventilation(self):
        """Gradually decrease ventilation."""
        try:
            # Decrease fan speed first
            for speed in range(100, -1, -5):
                fan_speed = speed / 100.0
                await self.fpga.set_fan_speed(fan_speed)
                self.state.fan_speed = fan_speed
                await asyncio.sleep(0.1)

            # Then close damper
            for position in range(100, -1, -10):
                damper_pos = position / 100.0
                await self.fpga.set_damper_position(damper_pos)
                self.state.damper_position = damper_pos
                await asyncio.sleep(0.1)

        except Exception as e:
            logger.error(f"Error in ventilation ramp-down: {e}")
            raise

    async def _monitor_ventilation(self):
        """Monitor ventilation system performance."""
        while True:
            try:
                # Read sensor data
                flow_rate = await self.fpga.read_flow_rate()
                pressure = await self.fpga.read_pressure()
                
                self.state.flow_rate = flow_rate
                self.state.pressure = pressure
                self.state.last_update = datetime.now()
                
                # Check for issues
                if flow_rate < 0.1 and self.state.fan_speed > 0:
                    logger.warning("Low flow rate detected")
                    await self.safety_monitor.report_ventilation_issue("Low flow rate")
                
                if pressure > 120:  # kPa
                    logger.warning("High pressure detected")
                    await self.safety_monitor.report_ventilation_issue("High pressure")
                
                await asyncio.sleep(0.1)  # 10Hz monitoring
                
            except asyncio.CancelledError:
                raise
            except Exception as e:
                logger.error(f"Error in ventilation monitoring: {e}")
                await asyncio.sleep(1)  # Longer delay on error

