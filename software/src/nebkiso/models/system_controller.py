# software/src/nebkiso/controllers/system_controller.py
import logging
from typing import Optional
import asyncio
from datetime import datetime

from ..models.system_state import SystemState, SystemMode, SensorType, SensorReading
from ..safety.monitor import SafetyMonitor
from ..hardware.fpga_interface import FPGAInterface

logger = logging.getLogger(__name__)

class SystemController:
    def __init__(self):
        self.fpga = FPGAInterface()
        self.safety_monitor = SafetyMonitor()
        self.current_state = SystemState(
            mode=SystemMode.IDLE,
            sensor_readings={},
            active_chambers=[],
            safety_status=True,
            last_update=datetime.now()
        )
        self.monitoring_task: Optional[asyncio.Task] = None

    async def initialize(self):
        """Initialize the system and start monitoring."""
        try:
            await self.fpga.connect()
            await self.safety_monitor.initialize()
            self.monitoring_task = asyncio.create_task(self.monitor_loop())
            logger.info("System initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize system: {e}")
            self.current_state.mode = SystemMode.FAULT
            self.current_state.error_message = str(e)
            raise

    async def monitor_loop(self):
        """Continuous monitoring loop for system status."""
        while True:
            try:
                # Read sensor data
                sensor_data = await self.fpga.read_sensors()
                self.current_state.sensor_readings = {
                    sensor_type: SensorReading(
                        sensor_type=sensor_type,
                        value=value,
                        timestamp=datetime.now(),
                        unit=self._get_unit(sensor_type),
                        valid=True,
                        raw_value=raw_value
                    )
                    for sensor_type, (value, raw_value) in sensor_data.items()
                }

                # Check safety conditions
                safety_status = await self.safety_monitor.check_conditions(
                    self.current_state.sensor_readings
                )

                if not safety_status.safe:
                    await self.handle_safety_violation(safety_status)

                self.current_state.last_update = datetime.now()
                await asyncio.sleep(0.1)  # 10Hz monitoring rate

            except Exception as e:
                logger.error(f"Error in monitoring loop: {e}")
                await self.handle_system_error(str(e))
                await asyncio.sleep(1)  # Longer delay on error

    async def handle_safety_violation(self, safety_status):
        """Handle safety violations."""
        logger.warning(f"Safety violation detected: {safety_status.message}")
        self.current_state.mode = SystemMode.EMERGENCY
        self.current_state.safety_status = False
        self.current_state.error_message = safety_status.message

        # Emergency shutdown sequence
        try:
            await self.fpga.emergency_shutdown()
            await self.safety_monitor.trigger_emergency_ventilation()
        except Exception as e:
            logger.error(f"Failed to execute emergency shutdown: {e}")

    async def handle_system_error(self, error_message: str):
        """Handle system errors."""
        logger.error(f"System error: {error_message}")
        self.current_state.mode = SystemMode.FAULT
        self.current_state.error_message = error_message

        try:
            await self.fpga.safe_shutdown()
        except Exception as e:
            logger.critical(f"Failed to execute safe shutdown: {e}")

    def _get_unit(self, sensor_type: SensorType) -> str:
        """Get the unit for a sensor type."""
        units = {
            SensorType.VOC: "ppb",
            SensorType.AIR_QUALITY: "AQI",
            SensorType.PRESSURE: "kPa",
            SensorType.TEMPERATURE: "°C",
            SensorType.FLOW: "L/min"
        }
        return units.get(sensor_type, "")

