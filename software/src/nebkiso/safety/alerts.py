from dataclasses import dataclass
from typing import List
import logging
from datetime import datetime
import asyncio

logger = logging.getLogger(__name__)

@dataclass
class Alert:
    level: str  # 'info', 'warning', 'critical'
    message: str
    timestamp: datetime
    source: str
    action_required: bool

class AlertManager:
    def __init__(self):
        self.alerts: List[Alert] = []
        self.alert_handlers = []
        self._alert_lock = asyncio.Lock()

    async def add_alert(self, alert: Alert):
        """Add a new alert and notify handlers."""
        async with self._alert_lock:
            self.alerts.append(alert)
            
            # Log alert
            log_level = {
                'info': logging.INFO,
                'warning': logging.WARNING,
                'critical': logging.ERROR
            }.get(alert.level, logging.INFO)
            
            logger.log(log_level, f"Alert: {alert.message}")
            
            # Notify handlers
            for handler in self.alert_handlers:
                try:
                    await handler(alert)
                except Exception as e:
                    logger.error(f"Error in alert handler: {e}")

    async def clear_alert(self, alert_id: int):
        """Clear a specific alert."""
        async with self._alert_lock:
            if 0 <= alert_id < len(self.alerts):
                self.alerts.pop(alert_id)

    async def get_active_alerts(self) -> List[Alert]:
        """Get all active alerts."""
        async with self._alert_lock:
            return self.alerts.copy()

    def add_alert_handler(self, handler):
        """Add a new alert handler."""
        self.alert_handlers.append(handler)

    def remove_alert_handler(self, handler):
        """Remove an alert handler."""
        if handler in self.alert_handlers:
            self.alert_handlers.remove(handler)