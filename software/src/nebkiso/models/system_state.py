from dataclasses import dataclass
from enum import Enum
from typing import Dict, List, Optional
from datetime import datetime

class SystemMode(Enum):
    IDLE = "idle"
    CALIBRATING = "calibrating"
    RUNNING = "running"
    EMERGENCY = "emergency"
    MAINTENANCE = "maintenance"
    FAULT = "fault"

class SensorType(Enum):
    VOC = "voc"
    AIR_QUALITY = "air_quality"
    PRESSURE = "pressure"
    TEMPERATURE = "temperature"
    FLOW = "flow"

@dataclass
class SensorReading:
    sensor_type: SensorType
    value: float
    timestamp: datetime
    unit: str
    valid: bool
    raw_value: int

@dataclass
class ChamberId:
    id: int
    name: str
    molecule: str
    concentration: float

@dataclass
class SystemState:
    mode: SystemMode
    sensor_readings: Dict[SensorType, SensorReading]
    active_chambers: List[ChamberId]
    safety_status: bool
    last_update: datetime
    error_code: Optional[int] = None
    error_message: Optional[str] = None


    def __init__(self):
        self.spi = spidev.SpiDev()
        self.connected = False
        self._lock = asyncio.Lock()

    async def connect(self):
        """Initialize SPI connection to FPGA."""
        try:
            self.spi.open(0, 0)  # Bus 0, Device 0
            self.spi.max_speed_hz = 1000000
            self.spi.mode = 0
            self.connected = True
            logger.info("FPGA connection established")
        except Exception as e:
            logger.error(f"Failed to connect to FPGA: {e}")
            raise

    async def read_sensors(self) -> Dict[SensorType, Tuple[float, int]]:
        """Read all sensor values from FPGA."""
        async with self._lock:
            try:
                sensor_data = {}
                
                # Read VOC sensors
                raw_voc = await self._read_register(0x10)
                sensor_data[SensorType.VOC] = (raw_voc * 0.1, raw_voc)
                
                # Read Air Quality
                raw_aq = await self._read_register(0x11)
                sensor_data[SensorType.AIR_QUALITY] = (raw_aq * 1.0, raw_aq)
                
                # Read Pressure
                raw_pressure = await self._read_register(0x12)
                sensor_data[SensorType.PRESSURE] = (raw_pressure * 0.01, raw_pressure)
                
                # Read Temperature
                raw_temp = await self._read_register(0x13)
                sensor_data[SensorType.TEMPERATURE] = (raw_temp * 0.1, raw_temp)
                
                # Read Flow
                raw_flow = await self._read_register(0x14)
                sensor_data[SensorType.FLOW] = (raw_flow * 0.1, raw_flow)
                
                return sensor_data

            except Exception as e:
                logger.error(f"Error reading sensors: {e}")
                raise

    async def _read_register(self, addr: int) -> int:
        """Read a register from the FPGA."""
        try:
            # Send read command
            result = self.spi.xfer2([addr, 0, 0, 0])
            return (result[1] << 16) | (result[2] << 8) | result[3]
        except Exception as e:
            logger.error(f"SPI read error at address 0x{addr:02x}: {e}")
            raise

    async def emergency_shutdown(self):
        """Execute emergency shutdown sequence."""
        try:
            # Shutdown sequence registers
            await self._write_register(0xF0, 0x01)  # Emergency stop
            await self._write_register(0xF1, 0x01)  # Ventilation on
            await self._write_register(0xF2, 0x00)  # All chambers off
            logger.info("Emergency shutdown executed")
        except Exception as e:
            logger.error(f"Emergency shutdown failed: {e}")
            raise

    async def safe_shutdown(self):
        """Execute safe shutdown sequence."""
        try:
            # Gradual shutdown sequence
            await self._write_register(0xE0, 0x01)  # Start safe shutdown
            await asyncio.sleep(1)
            await self._write_register(0xE1, 0x01)  # Confirm shutdown
            logger.info("Safe shutdown executed")
        except Exception as e:
            logger.error(f"Safe shutdown failed: {e}")
            raise

    async def _write_register(self, addr: int, value: int):
        """Write to a register on the FPGA."""
        try:
            self.spi.xfer2([0x80 | addr, (value >> 16) & 0xFF, 
                          (value >> 8) & 0xFF, value & 0xFF])
        except Exception as e:
            logger.error(f"SPI write error at address 0x{addr:02x}: {e}")
            raise

    def __del__(self):
        """Cleanup SPI connection."""
        if self.connected:
            try:
                self.spi.close()
            except:
                pass