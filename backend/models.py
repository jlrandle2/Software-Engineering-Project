from sqlalchemy import (
    Column, Integer, String, Boolean, Text, ForeignKey, DateTime, DECIMAL, UniqueConstraint
)

from sqlalchemy.sql import func
from db import Base

from sqlalchemy import UniqueConstraint


from datetime import datetime


class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    password = Column(String(255), nullable=False)
    email = Column(String(100), unique=True, nullable=False, index=True)
    role = Column(String(20), default="rider")

    preferred_station_id = Column(Integer, ForeignKey("stations.station_id"), nullable=True)
    safety_alerts_enabled = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class Station(Base):
    __tablename__ = "stations"

    station_id = Column(Integer, primary_key=True, index=True)
    station_name = Column(String(100), nullable=False, unique=True)
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
    station_id = Column(Integer, ForeignKey("stations.station_id"))
    
    route_name = Column(String(50), nullable=True)   
    direction = Column(String(20), nullable=True)    

    alert_type = Column(String(50))
    description = Column(Text)
    reported_by = Column(Integer, ForeignKey("users.user_id"), nullable=True)

    is_official = Column(Boolean, default=False)

    upvotes = Column(Integer, default=0)
    downvotes = Column(Integer, default=0)

    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class AlertVote(Base):
    __tablename__ = "alert_votes"

    __table_args__ = (
        UniqueConstraint('user_id', 'alert_id', name='unique_user_alert_vote'),
    )

    vote_id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    alert_id = Column(Integer, ForeignKey("system_alerts.alert_id"), nullable=False)

    vote_type = Column(Integer, nullable=False)  # +1 or -1

    created_at = Column(DateTime, default=datetime.utcnow)
