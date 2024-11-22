
# software/src/nebkiso/maintenance/scheduler.py
from typing import List, Dict
import asyncio
import logging
from datetime import datetime, timedelta
from dataclasses import dataclass

from ..database.models import MaintenanceRecord
from ..safety.monitor import SafetyMonitor

logger = logging.getLogger(__name__)

@dataclass
class MaintenanceTask:
    component_id: str
    component_type: str
    task_type: str
    interval_days: int
    last_performed: datetime
    procedure: str
    required_parts: List[str]

class MaintenanceScheduler:
    def __init__(self, safety_monitor: SafetyMonitor):
        self.safety_monitor = safety_monitor
        self.maintenance_schedule: Dict[str, MaintenanceTask] = {}
        self._notification_callbacks = []
        self._monitoring_task: Optional[asyncio.Task] = None

    async def initialize(self):
        """Initialize maintenance scheduler."""
        try:
            await self._load_maintenance_schedule()
            self._monitoring_task = asyncio.create_task(self._monitor_maintenance())
            logger.info("Maintenance scheduler initialized")
        except Exception as e:
            logger.error(f"Failed to initialize maintenance scheduler: {e}")
            raise

    async def _load_maintenance_schedule(self):
        """Load maintenance schedule from database."""
        # Example maintenance tasks
        self.maintenance_schedule = {
            "chamber_seals": MaintenanceTask(
                component_id="seals",
                component_type="chamber",
                task_type="inspection",
                interval_days=30,
                last_performed=datetime.now() - timedelta(days=25),
                procedure="Inspect all chamber seals for wear and damage",
                required_parts=["seal_kit"]
            ),
            "voc_sensor": MaintenanceTask(
                component_id="voc_sensor",
                component_type="sensor",
                task_type="calibration",
                interval_days=90,
                last_performed=datetime.now() - timedelta(days=85),
                procedure="Perform VOC sensor calibration",
                required_parts=["calibration_gas"]
            ),
            # Add more maintenance tasks...
        }

    async def _monitor_maintenance(self):
        """Monitor maintenance schedule and trigger notifications."""
        while True:
            try:
                current_time = datetime.now()
                
                for task_id, task in self.maintenance_schedule.items():
                    days_since_maintenance = (
                        current_time - task.last_performed
                    ).days
                    
                    if days_since_maintenance >= task.interval_days:
                        await self._notify_maintenance_due(task_id, task)
                    elif days_since_maintenance >= (task.interval_days - 7):
                        await self._notify_maintenance_upcoming(task_id, task)
                
                await asyncio.sleep(3600)  # Check every hour
                
            except Exception as e:
                logger.error(f"Error in maintenance monitoring: {e}")
                await asyncio.sleep(3600)
