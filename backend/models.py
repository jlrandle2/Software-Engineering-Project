from sqlalchemy import (
    Column, Integer, String, Boolean, Text, ForeignKey, DateTime, DECIMAL
)
from sqlalchemy.sql import func
from db import Base


class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(100), unique=True, nullable=False, index=True)
    preferred_station_id = Column(Integer, ForeignKey("stations.station_id"), nullable=True)
    safety_alerts_enabled = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class Station(Base):
    __tablename__ = "stations"

    station_id = Column(Integer, primary_key=True, index=True)
    station_name = Column(String(100), nullable=False)
    latitude = Column(DECIMAL(10, 8), nullable=False)
    longitude = Column(DECIMAL(11, 8), nullable=False)
    accessibility_features = Column(Boolean, default=False, nullable=False)


class Route(Base):
    __tablename__ = "routes"

    route_id = Column(Integer, primary_key=True, index=True)
    route_name = Column(String(50), nullable=False)
    direction = Column(String(20), nullable=False)


class RouteStop(Base):
    __tablename__ = "route_stops"

    stop_id = Column(Integer, primary_key=True, index=True)
    route_id = Column(Integer, ForeignKey("routes.route_id"), nullable=False)
    station_id = Column(Integer, ForeignKey("stations.station_id"), nullable=False)
    stop_sequence = Column(Integer, nullable=False)


class SystemAlert(Base):
    __tablename__ = "system_alerts"

    alert_id = Column(Integer, primary_key=True, index=True)
    station_id = Column(Integer, ForeignKey("stations.station_id"), nullable=False)
    alert_type = Column(String(50), nullable=False)
    description = Column(Text, nullable=True)
    reported_by = Column(Integer, ForeignKey("users.user_id"), nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)