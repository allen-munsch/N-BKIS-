from dataclasses import dataclass
from typing import Dict, Optional, List
import logging
import asyncio
from datetime import datetime, timedelta

from ..models.system_state import SensorType, SensorReading

logger = logging.getLogger(__name__)

@dataclass
class SafetyThresholds:
    voc_max: float = 1000.0  # ppb
    voc_warning: float = 800.0  # ppb
    aq_max: float = 150.0  # AQI
    aq_warning: float = 100.0  # AQI
    pressure_max: float = 110.0  # kPa
    pressure_min: float = 90.0  # kPa
    temperature_max: float = 40.0  # °C
    temperature_min: float = 10.0  # °C
    flow_min: float = 1.0  # L/min

@dataclass
class SafetyStatus:
    safe: bool
    message: str
    violations: List[str]
    warning_level: str  # 'none', 'warning', 'critical'
    timestamp: datetime

class SafetyMonitor:
    def __init__(self):
        self.thresholds = SafetyThresholds()
        self.violation_history: List[SafetyStatus] = []
        self.last_warning_time: Optional[datetime] = None
        self.warning_count = 0
        self._ventilation_lock = asyncio.Lock()

    async def initialize(self):
        """Initialize safety monitoring system."""
        try:
            # Load custom thresholds if available
            await self._load_thresholds()
            # Initialize violation history
            self.violation_history = []
            logger.info("Safety monitor initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize safety monitor: {e}")
            raise

    async def check_conditions(self, sensor_readings: Dict[SensorType, SensorReading]) -> SafetyStatus:
        """Check all safety conditions and return status."""
        violations = []
        warning_level = 'none'

        try:
            # Check VOC levels
            if SensorType.VOC in sensor_readings:
                voc_reading = sensor_readings[SensorType.VOC]
                if voc_reading.valid:
                    if voc_reading.value > self.thresholds.voc_max:
                        violations.append(f"VOC level critical: {voc_reading.value} ppb")
                        warning_level = 'critical'
                    elif voc_reading.value > self.thresholds.voc_warning:
                        violations.append(f"VOC level warning: {voc_reading.value} ppb")
                        warning_level = 'warning'

            # Check air quality
            if SensorType.AIR_QUALITY in sensor_readings:
                aq_reading = sensor_readings[SensorType.AIR_QUALITY]
                if aq_reading.valid:
                    if aq_reading.value > self.thresholds.aq_max:
                        violations.append(f"Air quality critical: {aq_reading.value} AQI")
                        warning_level = 'critical'
                    elif aq_reading.value > self.thresholds.aq_warning:
                        violations.append(f"Air quality warning: {aq_reading.value} AQI")
                        warning_level = max(warning_level, 'warning')

            # Check pressure
            if SensorType.PRESSURE in sensor_readings:
                pressure_reading = sensor_readings[SensorType.PRESSURE]
                if pressure_reading.valid:
                    if pressure_reading.value > self.thresholds.pressure_max:
                        violations.append(f"Pressure too high: {pressure_reading.value} kPa")
                        warning_level = 'critical'
                    elif pressure_reading.value < self.thresholds.pressure_min:
                        violations.append(f"Pressure too low: {pressure_reading.value} kPa")
                        warning_level = 'critical'

            # Handle persistent warnings
            if warning_level != 'none':
                await self._handle_persistent_warnings(warning_level, violations)

            status = SafetyStatus(
                safe=(warning_level != 'critical'),
                message="; ".join(violations) if violations else "All systems normal",
                violations=violations,
                warning_level=warning_level,
                timestamp=datetime.now()
            )

            # Update violation history
            self.violation_history.append(status)
            if len(self.violation_history) > 1000:  # Keep last 1000 status checks
                self.violation_history.pop(0)

            return status

        except Exception as e:
            logger.error(f"Error in safety condition check: {e}")
            return SafetyStatus(
                safe=False,
                message=f"Safety monitoring error: {str(e)}",
                violations=["System error"],
                warning_level='critical',
                timestamp=datetime.now()
            )

    async def _handle_persistent_warnings(self, warning_level: str, violations: List[str]):
        """Handle persistent warning conditions."""
        current_time = datetime.now()
        
        if self.last_warning_time is None:
            self.last_warning_time = current_time
            self.warning_count = 1
        else:
            time_diff = current_time - self.last_warning_time
            
            if time_diff < timedelta(minutes=5):  # Warning window
                self.warning_count += 1
                if self.warning_count >= 3:  # Three warnings within 5 minutes
                    violations.append("Persistent warning condition detected")
                    warning_level = 'critical'
            else:
                # Reset warning counter if outside window
                self.warning_count = 1
                self.last_warning_time = current_time

    async def trigger_emergency_ventilation(self):
        """Activate emergency ventilation system."""
        async with self._ventilation_lock:
            try:
                # Ventilation control sequence
                await self._activate_ventilation()
                logger.info("Emergency ventilation activated")
                
                # Monitor until conditions improve
                while True:
                    await asyncio.sleep(1)
                    if await self._check_ventilation_effectiveness():
                        logger.info("Ventilation effective, conditions improving")
                        break
                    
            except Exception as e:
                logger.error(f"Emergency ventilation error: {e}")
                raise

    async def _activate_ventilation(self):
        """Activate ventilation hardware."""
        # Implementation would interface with FPGA
        pass

    async def _check_ventilation_effectiveness(self) -> bool:
        """Check if ventilation is improving conditions."""
        # Implementation would check sensor readings
        return True

    async def _load_thresholds(self):
        """Load safety thresholds from configuration."""
        try:
            # Load from config file or database
            # For now, using defaults
            pass
        except Exception as e:
            logger.error(f"Error loading safety thresholds: {e}")
            raise
