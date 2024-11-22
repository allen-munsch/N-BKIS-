from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

from ..models.system_state import SystemMode, SensorType

class SystemStateResponse(BaseModel):
    mode: SystemMode
    safety_status: bool
    last_update: datetime
    error_code: Optional[int] = None
    error_message: Optional[str] = None

class SensorDataResponse(BaseModel):
    sensor_type: SensorType
    value: float
    timestamp: datetime
    unit: str
    valid: bool

class SequenceStep(BaseModel):
    chamber_id: int
    intensity: float = Field(..., ge=0, le=1)
    duration: float = Field(..., gt=0)
    transition_time: Optional[float] = Field(default=0, ge=0)

class SequenceCreate(BaseModel):
    name: str
    description: Optional[str]
    steps: List[SequenceStep]
    loop: bool = False
    total_duration: Optional[float]

class SequenceResponse(BaseModel):
    id: str
    name: str
    created_at: datetime
    created_by: str
    status: str

class AlertResponse(BaseModel):
    level: str
    message: str
    timestamp: datetime
    source: str
    action_required: bool

