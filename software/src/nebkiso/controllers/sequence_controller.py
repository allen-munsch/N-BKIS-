from typing import List, Optional, Dict
import asyncio
import logging
from datetime import datetime
from dataclasses import dataclass

from ..models.system_state import SystemMode
from ..hardware.fpga_interface import FPGAInterface
from ..safety.monitor import SafetyMonitor

logger = logging.getLogger(__name__)

@dataclass
class SequenceStep:
    chamber_id: int
    intensity: float  # 0.0 to 1.0
    duration: float  # seconds
    transition_time: float = 0.0  # seconds

@dataclass
class Sequence:
    id: str
    name: str
    steps: List[SequenceStep]
    loop: bool = False
    created_at: datetime = datetime.now()

class SequenceController:
    def __init__(self, fpga: FPGAInterface, safety_monitor: SafetyMonitor):
        self.fpga = fpga
        self.safety_monitor = safety_monitor
        self.current_sequence: Optional[Sequence] = None
        self.sequence_task: Optional[asyncio.Task] = None
        self._running = False
        self._pause_event = asyncio.Event()
        self._sequence_lock = asyncio.Lock()

    async def load_sequence(self, sequence: Sequence) -> bool:
        """Load a new sequence for execution."""
        try:
            async with self._sequence_lock:
                if self._running:
                    logger.warning("Cannot load sequence while another is running")
                    return False

                # Validate sequence
                if not await self._validate_sequence(sequence):
                    logger.error("Sequence validation failed")
                    return False

                self.current_sequence = sequence
                logger.info(f"Sequence '{sequence.name}' loaded successfully")
                return True

        except Exception as e:
            logger.error(f"Error loading sequence: {e}")
            return False

    async def start_sequence(self) -> bool:
        """Start executing the loaded sequence."""
        try:
            async with self._sequence_lock:
                if not self.current_sequence:
                    logger.error("No sequence loaded")
                    return False

                if self._running:
                    logger.warning("Sequence already running")
                    return False

                self._running = True
                self._pause_event.set()
                self.sequence_task = asyncio.create_task(
                    self._execute_sequence(self.current_sequence)
                )
                logger.info(f"Started sequence '{self.current_sequence.name}'")
                return True

        except Exception as e:
            logger.error(f"Error starting sequence: {e}")
            return False

    async def stop_sequence(self) -> bool:
        """Stop the current sequence."""
        try:
            async with self._sequence_lock:
                if not self._running:
                    return True

                self._running = False
                self._pause_event.set()

                if self.sequence_task:
                    self.sequence_task.cancel()
                    try:
                        await self.sequence_task
                    except asyncio.CancelledError:
                        pass

                # Reset all chambers
                await self._reset_chambers()
                logger.info("Sequence stopped and chambers reset")
                return True

        except Exception as e:
            logger.error(f"Error stopping sequence: {e}")
            return False

    async def pause_sequence(self) -> bool:
        """Pause the current sequence."""
        try:
            if not self._running:
                return False

            self._pause_event.clear()
            logger.info("Sequence paused")
            return True

        except Exception as e:
            logger.error(f"Error pausing sequence: {e}")
            return False

    async def resume_sequence(self) -> bool:
        """Resume the paused sequence."""
        try:
            if not self._running:
                return False

            self._pause_event.set()
            logger.info("Sequence resumed")
            return True

        except Exception as e:
            logger.error(f"Error resuming sequence: {e}")
            return False

    async def _execute_sequence(self, sequence: Sequence):
        """Execute sequence steps."""
        try:
            while self._running:
                for step in sequence.steps:
                    if not self._running:
                        break

                    # Wait if paused
                    await self._pause_event.wait()

                    # Check safety before each step
                    if not await self._check_safety():
                        logger.error("Safety check failed, stopping sequence")
                        await self.stop_sequence()
                        return

                    # Execute step
                    await self._execute_step(step)

                    # Handle transitions
                    if step.transition_time > 0:
                        await self._handle_transition(step)

                if not sequence.loop:
                    break

            await self._reset_chambers()
            logger.info(f"Sequence '{sequence.name}' completed")

        except asyncio.CancelledError:
            logger.info("Sequence execution cancelled")
            raise
        except Exception as e:
            logger.error(f"Error executing sequence: {e}")
            await self.stop_sequence()

    async def _execute_step(self, step: SequenceStep):
        """Execute a single sequence step."""
        try:
            # Set chamber intensity
            await self.fpga.set_chamber_intensity(step.chamber_id, step.intensity)
            
            # Wait for duration
            await asyncio.sleep(step.duration)

        except Exception as e:
            logger.error(f"Error executing step: {e}")
            raise

    async def _handle_transition(self, step: SequenceStep):
        """Handle transition between steps."""
        try:
            transition_steps = 50  # Number of steps for smooth transition
            step_time = step.transition_time / transition_steps
            
            for i in range(transition_steps):
                if not self._running:
                    break

                # Calculate transition intensity
                intensity = step.intensity * (1 - (i / transition_steps))
                await self.fpga.set_chamber_intensity(step.chamber_id, intensity)
                await asyncio.sleep(step_time)

        except Exception as e:
            logger.error(f"Error handling transition: {e}")
            raise

    async def _validate_sequence(self, sequence: Sequence) -> bool:
        """Validate sequence parameters."""
        try:
            for step in sequence.steps:
                if not 0 <= step.intensity <= 1:
                    logger.error(f"Invalid intensity value: {step.intensity}")
                    return False
                
                if step.duration <= 0:
                    logger.error(f"Invalid duration value: {step.duration}")
                    return False
                
                if step.transition_time < 0:
                    logger.error(f"Invalid transition time: {step.transition_time}")
                    return False

            return True

        except Exception as e:
            logger.error(f"Error validating sequence: {e}")
            return False

    async def _check_safety(self) -> bool:
        """Check safety conditions."""
        try:
            safety_status = await self.safety_monitor.check_conditions(
                await self.fpga.read_sensors()
            )
            return safety_status.safe

        except Exception as e:
            logger.error(f"Error checking safety: {e}")
            return False

    async def _reset_chambers(self):
        """Reset all chambers to zero intensity."""
        try:
            # Implementation would iterate through all chambers
            # and set their intensity to 0
            await self.fpga.reset_all_chambers()

        except Exception as e:
            logger.error(f"Error resetting chambers: {e}")
            raise
