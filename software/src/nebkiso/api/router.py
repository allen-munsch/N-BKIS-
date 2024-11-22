# software/src/nebkiso/api/router.py
from fastapi import APIRouter, HTTPException, WebSocket, Depends
from typing import List, Optional
from datetime import datetime
import asyncio
import logging
from pydantic import BaseModel

from ..models.system_state import SystemState, SystemMode, SensorType
from ..controllers.system_controller import SystemController
from ..safety.monitor import SafetyStatus
from .auth import get_current_user, User
from .schemas import (
    SystemStateResponse,
    SensorDataResponse,
    SequenceCreate,
    SequenceResponse,
    AlertResponse
)

logger = logging.getLogger(__name__)

router = APIRouter()
system_controller = SystemController()

class WebSocketManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def broadcast(self, message: dict):
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception as e:
                logger.error(f"Error broadcasting to websocket: {e}")
                await self.disconnect(connection)

websocket_manager = WebSocketManager()

@router.get("/system/state", response_model=SystemStateResponse)
async def get_system_state(current_user: User = Depends(get_current_user)):
    """Get current system state."""
    try:
        state = system_controller.current_state
        return SystemStateResponse(
            mode=state.mode,
            safety_status=state.safety_status,
            last_update=state.last_update,
            error_code=state.error_code,
            error_message=state.error_message
        )
    except Exception as e:
        logger.error(f"Error getting system state: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/system/sensors", response_model=List[SensorDataResponse])
async def get_sensor_data(
    sensor_type: Optional[SensorType] = None,
    current_user: User = Depends(get_current_user)
):
    """Get sensor readings."""
    try:
        readings = system_controller.current_state.sensor_readings
        if sensor_type:
            readings = {k: v for k, v in readings.items() if k == sensor_type}
        
        return [
            SensorDataResponse(
                sensor_type=sensor_type,
                value=reading.value,
                timestamp=reading.timestamp,
                unit=reading.unit,
                valid=reading.valid
            )
            for sensor_type, reading in readings.items()
        ]
    except Exception as e:
        logger.error(f"Error getting sensor data: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/sequence/create", response_model=SequenceResponse)
async def create_sequence(
    sequence: SequenceCreate,
    current_user: User = Depends(get_current_user)
):
    """Create a new scent sequence."""
    try:
        # Validate sequence
        if not sequence.steps:
            raise ValueError("Sequence must contain at least one step")
            
        # Create sequence
        # Implementation would store sequence and return ID
        return SequenceResponse(
            id="seq_123",
            name=sequence.name,
            created_at=datetime.now(),
            created_by=current_user.username,
            status="created"
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error creating sequence: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/system/emergency-stop")
async def emergency_stop(current_user: User = Depends(get_current_user)):
    """Trigger emergency stop."""
    try:
        await system_controller.handle_safety_violation(
            SafetyStatus(
                safe=False,
                message="Emergency stop triggered by user",
                violations=["User-triggered emergency stop"],
                warning_level="critical",
                timestamp=datetime.now()
            )
        )
        return {"status": "Emergency stop triggered"}
    except Exception as e:
        logger.error(f"Error triggering emergency stop: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.websocket("/ws/system")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time updates."""
    await websocket_manager.connect(websocket)
    try:
        while True:
            # Send system state updates every second
            state = system_controller.current_state
            await websocket.send_json({
                "type": "state_update",
                "data": {
                    "mode": state.mode.value,
                    "safety_status": state.safety_status,
                    "sensor_readings": {
                        sensor_type.value: {
                            "value": reading.value,
                            "unit": reading.unit,
                            "valid": reading.valid
                        }
                        for sensor_type, reading in state.sensor_readings.items()
                    }
                }
            })
            await asyncio.sleep(1)
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
    finally:
        websocket_manager.disconnect(websocket)

