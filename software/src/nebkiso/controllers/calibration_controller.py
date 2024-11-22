
# software/src/nebkiso/controllers/calibration_controller.py
from typing import Dict, List, Optional
import asyncio
import logging
import json
from datetime import datetime
from pathlib import Path

from ..hardware.fpga_interface import FPGAInterface
from ..models.system_state import SensorType

logger = logging.getLogger(__name__)

class CalibrationController:
    def __init__(self, fpga: FPGAInterface):
        self.fpga = fpga
        self._calibration_lock = asyncio.Lock()
        self.calibration_data: Dict[str, Dict] = {}
        self.load_calibration_data()

    def load_calibration_data(self):
        """Load calibration data from file."""
        try:
            cal_file = Path("data/calibration/calibration.json")
            if cal_file.exists():
                with open(cal_file, "r") as f:
                    self.calibration_data = json.load(f)
                logger.info("Calibration data loaded successfully")
        except Exception as e:
            logger.error(f"Error loading calibration data: {e}")
            self.calibration_data = {}

    async def save_calibration_data(self):
        """Save calibration data to file."""
        try:
            cal_file = Path("data/calibration/calibration.json")
            cal_file.parent.mkdir(parents=True, exist_ok=True)
            
            with open(cal_file, "w") as f:
                json.dump(self.calibration_data, f, indent=2)
            logger.info("Calibration data saved successfully")
            
        except Exception as e:
            logger.error(f"Error saving calibration data: {e}")
            raise

    async def start_calibration(self, sensor_type: SensorType) -> bool:
        """Start calibration sequence for a sensor."""
        async with self._calibration_lock:
            try:
                logger.info(f"Starting calibration for {sensor_type.name}")
                
                # Reset calibration data for this sensor
                self.calibration_data[sensor_type.name] = {
                    "timestamp": datetime.now().isoformat(),
                    "points": []
                }
                
                # Perform calibration sequence
                if sensor_type == SensorType.VOC:
                    await self._calibrate_voc_sensor()
                elif sensor_type == SensorType.AIR_QUALITY:
                    await self._calibrate_air_quality_sensor()
                # Add other sensor types...
                
                await self.save_calibration_data()
                return True
                
            except Exception as e:
                logger.error(f"Calibration failed for {sensor_type.name}: {e}")
                return False

    async def _calibrate_voc_sensor(self):
        """Calibrate VOC sensor."""
        try:
            # Example calibration sequence
            test_points = [0, 100, 500, 1000]  # ppb
            
            for test_point in test_points:
                # Set test point
                await self.fpga.set_test_voc_level(test_point)
                await asyncio.sleep(5)  # Allow reading to stabilize
                
                # Read actual sensor value
                readings = []
                for _ in range(10):
                    reading = await self.fpga.read_raw_voc()
                    readings.append(reading)
                    await asyncio.sleep(0.1)
                
                # Calculate average reading
                avg_reading = sum(readings) / len(readings)
                
                # Store calibration point
                self.calibration_data["VOC"]["points"].append({
                    "reference": test_point,
                    "measured": avg_reading
                })
                
            # Calculate calibration coefficients
            await self._calculate_voc_calibration()
            
        except Exception as e:
            logger.error(f"VOC calibration error: {e}")
            raise

    async def _calibrate_air_quality_sensor(self):
        """Calibrate air quality sensor."""
        try:
            # Similar implementation to VOC calibration
            pass
        except Exception as e:
            logger.error(f"Air quality calibration error: {e}")
            raise

    async def _calculate_voc_calibration(self):
        """Calculate VOC calibration coefficients."""
        try:
            points = self.calibration_data["VOC"]["points"]
            references = [p["reference"] for p in points]
            measurements = [p["measured"] for p in points]
            
            # Linear regression
            n = len(points)
            sum_x = sum(measurements)
            sum_y = sum(references)
            sum_xy = sum(x * y for x, y in zip(measurements, references))
            sum_xx = sum(x * x for x in measurements)
            
            slope = (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x)
            intercept = (sum_y - slope * sum_x) / n
            
            self.calibration_data["VOC"]["coefficients"] = {
                "slope": slope,
                "intercept": intercept
            }
            
        except Exception as e:
            logger.error(f"Error calculating VOC calibration: {e}")
            raise

    def apply_calibration(self, sensor_type: SensorType, raw_value: float) -> float:
        """Apply calibration to raw sensor reading."""
        try:
            if sensor_type.name not in self.calibration_data:
                return raw_value
                
            cal_data = self.calibration_data[sensor_type.name]
            if "coefficients" not in cal_data:
                return raw_value
                
            coeff = cal_data["coefficients"]
            return coeff["slope"] * raw_value + coeff["intercept"]
            
        except Exception as e:
            logger.error(f"Error applying calibration: {e}")
            return raw_value