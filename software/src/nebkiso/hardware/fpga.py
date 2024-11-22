from typing import Dict, Tuple, Optional
import asyncio
import logging
import struct
from enum import IntEnum
import spidev
import RPi.GPIO as GPIO
from dataclasses import dataclass
from datetime import datetime

from ..models.system_state import SensorType, SystemMode

logger = logging.getLogger(__name__)

class RegisterMap(IntEnum):
    # System Control Registers
    SYS_CONTROL = 0x00
    SYS_STATUS = 0x01
    ERROR_CODE = 0x02
    
    # Safety Registers
    SAFETY_CONTROL = 0x10
    EMERGENCY_STOP = 0x11
    VENTILATION_CONTROL = 0x12
    
    # Sensor Registers
    VOC_DATA = 0x20
    AIR_QUALITY = 0x21
    PRESSURE = 0x22
    TEMPERATURE = 0x23
    FLOW_RATE = 0x24
    
    # Chamber Control Registers
    CHAMBER_BASE = 0x30  # Chamber registers start from 0x30
    CHAMBER_INTENSITY = 0x00  # Offset from CHAMBER_BASE
    CHAMBER_PRESSURE = 0x01
    CHAMBER_TEMP = 0x02
    CHAMBER_FLOW = 0x03
    
    # Ventilation Control Registers
    FAN_SPEED = 0x40
    DAMPER_POSITION = 0x41
    VENT_FLOW = 0x42
    VENT_PRESSURE = 0x43

@dataclass
class SPITransaction:
    write: bool
    register: int
    data: int = 0

class FPGAInterface:
    def __init__(self, 
                 spi_bus: int = 0, 
                 spi_device: int = 0, 
                 reset_pin: int = 17,
                 interrupt_pin: int = 27):
        self.spi = spidev.SpiDev()
        self.spi_bus = spi_bus
        self.spi_device = spi_device
        self.reset_pin = reset_pin
        self.interrupt_pin = interrupt_pin
        self._lock = asyncio.Lock()
        self._interrupt_event = asyncio.Event()
        self._running = False
        self._last_error: Optional[str] = None
        self._transaction_queue: asyncio.Queue[SPITransaction] = asyncio.Queue()

    async def connect(self) -> bool:
        """Initialize connection to FPGA."""
        try:
            # Setup GPIO
            GPIO.setmode(GPIO.BCM)
            GPIO.setup(self.reset_pin, GPIO.OUT)
            GPIO.setup(self.interrupt_pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
            GPIO.add_event_detect(self.interrupt_pin, GPIO.FALLING, 
                                callback=self._interrupt_callback)

            # Initialize SPI
            self.spi.open(self.spi_bus, self.spi_device)
            self.spi.max_speed_hz = 1000000
            self.spi.mode = 0
            
            # Reset FPGA
            await self._reset_fpga()
            
            # Start transaction processor
            self._running = True
            asyncio.create_task(self._process_transactions())
            
            # Verify communication
            if not await self._verify_communication():
                raise RuntimeError("FPGA communication verification failed")
            
            logger.info("FPGA connection established successfully")
            return True

        except Exception as e:
            logger.error(f"Failed to connect to FPGA: {e}")
            self._last_error = str(e)
            return False

    async def disconnect(self):
        """Safely disconnect from FPGA."""
        try:
            self._running = False
            GPIO.cleanup()
            self.spi.close()
            logger.info("FPGA disconnected successfully")
        except Exception as e:
            logger.error(f"Error disconnecting from FPGA: {e}")

    async def read_sensors(self) -> Dict[SensorType, Tuple[float, int]]:
        """Read all sensor values."""
        try:
            sensor_data = {}
            
            # Read VOC sensor
            raw_voc = await self._read_register(RegisterMap.VOC_DATA)
            sensor_data[SensorType.VOC] = (self._scale_voc(raw_voc), raw_voc)
            
            # Read Air Quality
            raw_aq = await self._read_register(RegisterMap.AIR_QUALITY)
            sensor_data[SensorType.AIR_QUALITY] = (self._scale_air_quality(raw_aq), raw_aq)
            
            # Read Pressure
            raw_pressure = await self._read_register(RegisterMap.PRESSURE)
            sensor_data[SensorType.PRESSURE] = (self._scale_pressure(raw_pressure), raw_pressure)
            
            # Read Temperature
            raw_temp = await self._read_register(RegisterMap.TEMPERATURE)
            sensor_data[SensorType.TEMPERATURE] = (self._scale_temperature(raw_temp), raw_temp)
            
            # Read Flow Rate
            raw_flow = await self._read_register(RegisterMap.FLOW_RATE)
            sensor_data[SensorType.FLOW] = (self._scale_flow(raw_flow), raw_flow)
            
            return sensor_data

        except Exception as e:
            logger.error(f"Error reading sensors: {e}")
            raise

    async def set_chamber_intensity(self, chamber_id: int, intensity: float) -> bool:
        """Set intensity for a specific chamber."""
        try:
            # Convert intensity (0.0-1.0) to raw value (0-4095)
            raw_intensity = int(intensity * 4095)
            register = RegisterMap.CHAMBER_BASE + (chamber_id * 4) + RegisterMap.CHAMBER_INTENSITY
            await self._write_register(register, raw_intensity)
            return True

        except Exception as e:
            logger.error(f"Error setting chamber intensity: {e}")
            return False

    async def set_fan_speed(self, speed: float) -> bool:
        """Set ventilation fan speed."""
        try:
            # Convert speed (0.0-1.0) to raw value (0-255)
            raw_speed = int(speed * 255)
            await self._write_register(RegisterMap.FAN_SPEED, raw_speed)
            return True

        except Exception as e:
            logger.error(f"Error setting fan speed: {e}")
            return False

    async def set_damper_position(self, position: float) -> bool:
        """Set ventilation damper position."""
        try:
            # Convert position (0.0-1.0) to raw value (0-255)
            raw_position = int(position * 255)
            await self._write_register(RegisterMap.DAMPER_POSITION, raw_position)
            return True

        except Exception as e:
            logger.error(f"Error setting damper position: {e}")
            return False

    async def emergency_shutdown(self) -> bool:
        """Execute emergency shutdown sequence."""
        try:
            # Set emergency stop register
            await self._write_register(RegisterMap.EMERGENCY_STOP, 1)
            # Verify emergency stop was activated
            status = await self._read_register(RegisterMap.SYS_STATUS)
            return (status & 0x01) == 0x01

        except Exception as e:
            logger.error(f"Error in emergency shutdown: {e}")
            return False

    async def reset_all_chambers(self) -> bool:
        """Reset all chambers to zero intensity."""
        try:
            tasks = []
            for chamber_id in range(150):  # Assuming 150 chambers
                register = RegisterMap.CHAMBER_BASE + (chamber_id * 4)
                tasks.append(self._write_register(register, 0))
            await asyncio.gather(*tasks)
            return True

        except Exception as e:
            logger.error(f"Error resetting chambers: {e}")
            return False

    async def _process_transactions(self):
        """Process SPI transactions from queue."""
        while self._running:
            try:
                transaction = await self._transaction_queue.get()
                async with self._lock:
                    if transaction.write:
                        await self._spi_write(transaction.register, transaction.data)
                    else:
                        result = await self._spi_read(transaction.register)
                        # Store result if needed
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Error processing transaction: {e}")
                await asyncio.sleep(0.1)

    async def _read_register(self, register: int) -> int:
        """Read a register value."""
        async with self._lock:
            try:
                # Send read command (register address with MSB=0)
                result = await self._spi_read(register)
                return result

            except Exception as e:
                logger.error(f"Error reading register 0x{register:02x}: {e}")
                raise

    async def _write_register(self, register: int, value: int):
        """Write a value to a register."""
        async with self._lock:
            try:
                # Send write command (register address with MSB=1)
                await self._spi_write(register, value)

            except Exception as e:
                logger.error(f"Error writing register 0x{register:02x}: {e}")
                raise

    async def _spi_read(self, register: int) -> int:
        """Perform SPI read transaction."""
        try:
            # Format: [register(8) | 0x00(24)]
            tx_data = [register & 0x7F, 0, 0, 0]
            rx_data = self.spi.xfer2(tx_data)
            return (rx_data[1] << 16) | (rx_data[2] << 8) | rx_data[3]

        except Exception as e:
            logger.error(f"SPI read error: {e}")
            raise

    async def _spi_write(self, register: int, value: int):
        """Perform SPI write transaction."""
        try:
            # Format: [register(8) | data(24)]
            tx_data = [
                0x80 | (register & 0x7F),
                (value >> 16) & 0xFF,
                (value >> 8) & 0xFF,
                value & 0xFF
            ]
            self.spi.xfer2(tx_data)

        except Exception as e:
            logger.error(f"SPI write error: {e}")
            raise

    async def _reset_fpga(self):
        """Reset the FPGA."""
        try:
            GPIO.output(self.reset_pin, GPIO.LOW)
            await asyncio.sleep(0.1)
            GPIO.output(self.reset_pin, GPIO.HIGH)
            await asyncio.sleep(0.1)

        except Exception as e:
            logger.error(f"Error resetting FPGA: {e}")
            raise

    def _interrupt_callback(self, channel):
        """Handle FPGA interrupt."""
        self._interrupt_event.set()

    def _scale_voc(self, raw_value: int) -> float:
        """Scale raw VOC sensor value to ppb."""
        return raw_value * 0.1

    def _scale_air_quality(self, raw_value: int) -> float:
        """Scale raw air quality sensor value to AQI."""
        return raw_value * 1.0

    def _scale_pressure(self, raw_value: int) -> float:
        """Scale raw pressure sensor value to kPa."""
        return raw_value * 0.01

    def _scale_temperature(self, raw_value: int) -> float:
        """Scale raw temperature sensor value to °C."""
        return raw_value * 0.1

    def _scale_flow(self, raw_value: int) -> float:
        """Scale raw flow sensor value to L/min."""
        return raw_value * 0.1

    async def _verify_communication(self) -> bool:
        """Verify FPGA communication."""
        try:
            # Write test pattern
            test_value = 0xA5A5A5
            await self._write_register(RegisterMap.SYS_CONTROL, test_value)
            
            # Read back and verify
            read_value = await self._read_register(RegisterMap.SYS_CONTROL)
            return read_value == test_value

        except Exception as e:
            logger.error(f"Communication verification failed: {e}")
            return False