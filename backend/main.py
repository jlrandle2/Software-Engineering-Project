# =========================
# IMPORTS
# =========================

from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_
from datetime import datetime, timedelta

from fastapi.middleware.cors import CORSMiddleware

from db import Base, engine, get_db
from models import User, Station, Route, RouteStop, SystemAlert
from schemas import *


# =========================
# APP SETUP
# =========================

app = FastAPI(title="Transit Backend API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)


# =========================
# HEALTH
# =========================

@app.get("/health")
def health():
    return {"status": "ok"}


# =========================================================
# USERS
# =========================================================

@app.post("/users", response_model=UserOut)
def create_user(payload: UserCreate, db: Session = Depends(get_db)):

    exists = db.query(User).filter(
        or_(User.username == payload.username, User.email == payload.email)
    ).first()

    if exists:
        raise HTTPException(409, "Username or email already exists")

    user = User(**payload.dict())
    db.add(user)
    db.commit()
    db.refresh(user)

    return user


@app.get("/users/{user_id}", response_model=UserOut)
def get_user(user_id: int, db: Session = Depends(get_db)):

    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        raise HTTPException(404, "User not found")

    return user


# =========================================================
# STATIONS
# =========================================================

@app.post("/stations")
def create_station(payload: StationCreate, db: Session = Depends(get_db)):

    station = Station(**payload.dict())
    db.add(station)
    db.commit()
    db.refresh(station)

    return station


@app.get("/stations", response_model=list[StationOut])
def list_stations(db: Session = Depends(get_db)):

    return db.query(Station).order_by(Station.station_name).all()


# =========================================================
# ROUTES + ROUTE STOPS
# =========================================================

@app.post("/routes")
def create_route(payload: RouteCreate, db: Session = Depends(get_db)):

    route = Route(
        route_name=payload.route_name,
        direction=payload.direction
    )

    db.add(route)
    db.commit()
    db.refresh(route)

    # add stops
    for stop in payload.stops:
        db.add(RouteStop(
            route_id=route.route_id,
            station_id=stop.station_id,
            stop_sequence=stop.stop_sequence
        ))

    db.commit()

    return route


@app.get("/routes", response_model=list[RouteOut])
def list_routes(db: Session = Depends(get_db)):
    return db.query(Route).all()


@app.get("/routes/{route_id}/stops", response_model=list[RouteStopOut])
def get_route_stops(route_id: int, db: Session = Depends(get_db)):

    return (
        db.query(RouteStop)
        .filter(RouteStop.route_id == route_id)
        .order_by(RouteStop.stop_sequence)
        .all()
    )


# =========================================================
# LINE → STATIONS (NEW UX FLOW)
# =========================================================

@app.get("/lines/{line_name}/stations")
def get_stations_for_line(line_name: str, db: Session = Depends(get_db)):

    results = (
        db.query(Station.station_id, Station.station_name)
        .join(RouteStop)
        .join(Route)
        .filter(Route.route_name == line_name)
        .distinct()
        .all()
    )

    return [
        {"station_id": s.station_id, "station_name": s.station_name}
        for s in results
    ]


# =========================================================
# LINE + STATION → DIRECTIONS
# =========================================================

@app.get("/lines/{line_name}/stations/{station_id}/directions")
def get_directions(line_name: str, station_id: int, db: Session = Depends(get_db)):

    results = (
        db.query(Route.direction)
        .join(RouteStop)
        .filter(
            Route.route_name == line_name,
            RouteStop.station_id == station_id
        )
        .distinct()
        .all()
    )

    return [r.direction for r in results]


# =========================================================
# ALERTS
# =========================================================

@app.post("/alerts")
def create_alert(payload: AlertCreate, db: Session = Depends(get_db)):

    station = db.query(Station).filter(
        Station.station_id == payload.station_id
    ).first()

    if not station:
        raise HTTPException(400, "Invalid station_id")

    alert = SystemAlert(
        station_id=payload.station_id,
        route_name=payload.route_name,
        direction=payload.direction,
        alert_type=payload.alert_type,
        description=payload.description,
        is_official=payload.is_official,
        is_active=True
    )

    db.add(alert)
    db.commit()
    db.refresh(alert)

    return alert


@app.get("/alerts")
def get_alerts(station_id: int | None = None, db: Session = Depends(get_db)):

    two_hours_ago = datetime.now() - timedelta(hours=2)

    query = db.query(SystemAlert).filter(
        SystemAlert.created_at >= two_hours_ago,
        SystemAlert.is_active == True
    )

    if station_id:
        query = query.filter(SystemAlert.station_id == station_id)

    alerts = query.order_by(SystemAlert.created_at.desc()).all()

    result = []

    for alert in alerts:

        station = db.query(Station).filter(
            Station.station_id == alert.station_id
        ).first()

        result.append({
            "alert_id": alert.alert_id,
            "alert_type": alert.alert_type,
            "description": alert.description,
            "station_name": station.station_name if station else None,
            "route_name": alert.route_name,
            "direction": alert.direction,
            "created_at": alert.created_at,
            "is_official": alert.is_official,
        })

    return result

@app.delete("/alerts/{alert_id}")
def delete_alert(alert_id: int, db: Session = Depends(get_db)):

    alert = db.query(SystemAlert).filter(
        SystemAlert.alert_id == alert_id
    ).first()

    if not alert:
        raise HTTPException(404, "Alert not found")

    db.delete(alert)
    db.commit()

    return {"message": "Deleted"}