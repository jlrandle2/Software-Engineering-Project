from datetime import datetime
from decimal import Decimal
from typing import Optional, List
from pydantic import BaseModel, EmailStr, Field


# ---------- Users ----------
class UserCreate(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    email: EmailStr
    preferred_station_id: Optional[int] = None
    safety_alerts_enabled: bool = True

class UserUpdate(BaseModel):
    username: Optional[str] = Field(default=None, min_length=1, max_length=50)
    email: Optional[EmailStr] = None
    preferred_station_id: Optional[int] = None
    safety_alerts_enabled: Optional[bool] = None

class UserOut(BaseModel):
    user_id: int
    username: str
    email: str
    preferred_station_id: Optional[int]
    safety_alerts_enabled: bool
    created_at: datetime

    class Config:
        from_attributes = True


# ---------- Stations ----------
class StationCreate(BaseModel):
    station_name: str = Field(min_length=1, max_length=100)
    latitude: Decimal
    longitude: Decimal
    accessibility_features: bool = False

class StationUpdate(BaseModel):
    station_name: Optional[str] = Field(default=None, min_length=1, max_length=100)
    latitude: Optional[Decimal] = None
    longitude: Optional[Decimal] = None
    accessibility_features: Optional[bool] = None

class StationOut(BaseModel):
    station_id: int
    station_name: str
    latitude: Decimal
    longitude: Decimal
    accessibility_features: bool

    class Config:
        from_attributes = True


# ---------- Routes ----------
class RouteCreate(BaseModel):
    route_name: str = Field(min_length=1, max_length=50)
    direction: str = Field(min_length=1, max_length=20)

class RouteUpdate(BaseModel):
    route_name: Optional[str] = Field(default=None, min_length=1, max_length=50)
    direction: Optional[str] = Field(default=None, min_length=1, max_length=20)

class RouteOut(BaseModel):
    route_id: int
    route_name: str
    direction: str

    class Config:
        from_attributes = True


# ---------- Route Stops ----------
class RouteStopCreate(BaseModel):
    route_id: int
    station_id: int
    stop_sequence: int

class RouteStopUpdate(BaseModel):
    route_id: Optional[int] = None
    station_id: Optional[int] = None
    stop_sequence: Optional[int] = Field(default=None, gt=0)

class RouteStopOut(BaseModel):
    stop_id: int
    route_id: int
    station_id: int
    stop_sequence: int

    class Config:
        from_attributes = True


# ---------- Alerts ----------
class AlertCreate(BaseModel):
    station_id: int
    alert_type: str = Field(min_length=1, max_length=50)
    description: Optional[str] = None
    reported_by: Optional[int] = None
    is_active: bool = True

class AlertUpdate(BaseModel):
    station_id: Optional[int] = None
    alert_type: Optional[str] = Field(default=None, min_length=1, max_length=50)
    description: Optional[str] = None
    reported_by: Optional[int] = None
    is_active: Optional[bool] = None


class AlertOut(BaseModel):
    alert_id: int
    station_id: Optional[int]
    alert_type: str
    description: Optional[str]
    reported_by: Optional[int]
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True