from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Boolean, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class Molecule(Base):
    __tablename__ = 'molecules'
    
    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    chemical_formula = Column(String)
    molecular_weight = Column(Float)
    density = Column(Float)
    flash_point = Column(Float)
    vapor_pressure = Column(Float)
    compatibility_data = Column(JSON)  # Store compatibility with other molecules
    max_concentration = Column(Float)  # Maximum safe concentration
    safety_notes = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, onupdate=datetime.utcnow)

class Recipe(Base):
    __tablename__ = 'recipes'
    
    id = Column(Integer, primary_key=True)
    name = Column(String)
    description = Column(String)
    version = Column(Integer)
    created_by = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, onupdate=datetime.utcnow)
    sequence_data = Column(JSON)  # Store the actual sequence steps
    safety_verified = Column(Boolean, default=False)
    total_duration = Column(Float)
    tags = Column(JSON)

class MaintenanceRecord(Base):
    __tablename__ = 'maintenance_records'
    
    id = Column(Integer, primary_key=True)
    component_id = Column(String)
    component_type = Column(String)
    maintenance_type = Column(String)  # 'routine', 'repair', 'replacement'
    performed_at = Column(DateTime)
    performed_by = Column(String)
    notes = Column(String)
    next_maintenance_due = Column(DateTime)

class SafetyLog(Base):
    __tablename__ = 'safety_logs'
    
    id = Column(Integer, primary_key=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
    event_type = Column(String)
    severity = Column(String)
    description = Column(String)
    measurements = Column(JSON)  # Store relevant sensor readings
    actions_taken = Column(String)
    requires_followup = Column(Boolean, default=False)