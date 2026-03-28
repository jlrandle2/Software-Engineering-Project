from fastapi import FastAPI, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_

from fastapi.middleware.cors import CORSMiddleware


from db import Base, engine, get_db
from models import User, Station, Route, RouteStop, SystemAlert
from schemas import (
    UserCreate, UserOut, UserUpdate,
    StationCreate, StationOut, StationUpdate,
    RouteCreate, RouteOut, RouteUpdate,
    RouteStopCreate, RouteStopOut, RouteStopUpdate,
    AlertCreate, AlertOut, AlertUpdate
)

app = FastAPI(title="Transit Backend API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # allow everything (for now)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create tables (for dev). In prod you’d use migrations.
Base.metadata.create_all(bind=engine)


@app.get("/health")
def health():
    return {"status": "ok"}


# ---------------- Users ----------------
@app.post("/users", response_model=UserOut)
def create_user(payload: UserCreate, db: Session = Depends(get_db)):
    # basic uniqueness checks
    exists = db.query(User).filter(or_(User.username == payload.username, User.email == payload.email)).first()
    if exists:
        raise HTTPException(status_code=409, detail="Username or email already exists.")

    user = User(
        username=payload.username,
        email=payload.email,
        preferred_station_id=payload.preferred_station_id,
        safety_alerts_enabled=payload.safety_alerts_enabled
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@app.get("/users/{user_id}", response_model=UserOut)
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")
    return user

@app.put("/users/{user_id}", response_model=UserOut)
def update_user(user_id: int, payload: UserUpdate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    if payload.username is not None:
        existing = db.query(User).filter(User.username == payload.username, User.user_id != user_id).first()
        if existing:
            raise HTTPException(status_code=409, detail="Username already exists.")
        user.username = payload.username

    if payload.email is not None:
        existing = db.query(User).filter(User.email == payload.email, User.user_id != user_id).first()
        if existing:
            raise HTTPException(status_code=409, detail="Email already exists.")
        user.email = payload.email

    if payload.preferred_station_id is not None:
        station = db.query(Station).filter(Station.station_id == payload.preferred_station_id).first()
        if not station:
            raise HTTPException(status_code=400, detail="preferred_station_id does not exist.")
        user.preferred_station_id = payload.preferred_station_id

    if payload.safety_alerts_enabled is not None:
        user.safety_alerts_enabled = payload.safety_alerts_enabled

    db.commit()
    db.refresh(user)
    return user

@app.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")
    db.delete(user)
    db.commit()
    return {"message": "User deleted successfully."}


# ---------------- Stations ----------------
@app.post("/stations", response_model=StationOut)
def create_station(payload: StationCreate, db: Session = Depends(get_db)):
    station = Station(
        station_name=payload.station_name,
        latitude=payload.latitude,
        longitude=payload.longitude,
        accessibility_features=payload.accessibility_features
    )
    db.add(station)
    db.commit()
    db.refresh(station)
    return station


@app.get("/stations", response_model=list[StationOut])
def list_stations(db: Session = Depends(get_db)):
    return db.query(Station).order_by(Station.station_id.asc()).all()

@app.get("/stations/{station_id}", response_model=StationOut)
def get_station(station_id: int, db: Session = Depends(get_db)):
    station = db.query(Station).filter(Station.station_id == station_id).first()
    if not station:
        raise HTTPException(status_code=404, detail="Station not found.")
    return station

# ---------------- Routes ----------------
@app.post("/routes")
def create_route(payload: RouteCreate, db: Session = Depends(get_db)):
    route = Route(
        route_name=payload.route_name,
        direction=payload.direction
    )
    db.add(route)
    db.commit()
    db.refresh(route)

    for stop in payload.stops:
        db.add(RouteStop(
            route_id=route.route_id,
            station_id=stop.station_id,
            stop_sequence=stop.stop_sequence
        ))

    db.commit()

    print(payload)
    print(type(payload))
    print(dir(payload))

    return route


@app.get("/routes", response_model=list[RouteOut])
def list_routes(db: Session = Depends(get_db)):
    return db.query(Route).order_by(Route.route_id.asc()).all()

@app.get("/routes/{route_id}", response_model=RouteOut)
def get_route(route_id: int, db: Session = Depends(get_db)):
    route = db.query(Route).filter(Route.route_id == route_id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Route not found.")
    return route


# ---------------- Route Stops ----------------
@app.post("/route-stops", response_model=RouteStopOut)
def create_route_stop(payload: RouteStopCreate, db: Session = Depends(get_db)):
    # verify route + station exist
    route = db.query(Route).filter(Route.route_id == payload.route_id).first()
    if not route:
        raise HTTPException(status_code=400, detail="route_id does not exist.")
    station = db.query(Station).filter(Station.station_id == payload.station_id).first()
    if not station:
        raise HTTPException(status_code=400, detail="station_id does not exist.")

    stop = RouteStop(
        route_id=payload.route_id,
        station_id=payload.station_id,
        stop_sequence=payload.stop_sequence
    )
    db.add(stop)
    db.commit()
    db.refresh(stop)
    return stop


@app.get("/routes/{route_id}/stops", response_model=list[RouteStopOut])
def get_route_stops(route_id: int, db: Session = Depends(get_db)):
    return (
        db.query(RouteStop)
        .filter(RouteStop.route_id == route_id)
        .order_by(RouteStop.stop_sequence.asc())
        .all()
    )


# ---------------- System Alerts ----------------
@app.post("/alerts", response_model=AlertOut)
def create_alert(payload: AlertCreate, db: Session = Depends(get_db)):
    # verify station exists
    station = db.query(Station).filter(Station.station_id == payload.station_id).first()
    if not station:
        raise HTTPException(status_code=400, detail="station_id does not exist.")

    # if reported_by is provided, verify user exists
    if payload.reported_by is not None:
        user = db.query(User).filter(User.user_id == payload.reported_by).first()
        if not user:
            raise HTTPException(status_code=400, detail="reported_by user_id does not exist.")

    alert = SystemAlert(
        station_id=payload.station_id,
        alert_type=payload.alert_type,
        description=payload.description,
        reported_by=payload.reported_by,
        is_active=payload.is_active
    )
    db.add(alert)
    db.commit()
    db.refresh(alert)
    return alert


@app.get("/alerts", response_model=list[AlertOut])
def list_alerts(
    active_only: bool = Query(True),
    station_id: int | None = Query(None),
    alert_type: str | None = Query(None),
    reported_by: int | None = Query(None),
    db: Session = Depends(get_db)
):
    q = db.query(SystemAlert)
    if active_only:
        q = q.filter(SystemAlert.is_active == True)  # noqa: E712
    if station_id is not None:
        q = q.filter(SystemAlert.station_id == station_id)
    if alert_type is not None:
        q = q.filter(SystemAlert.alert_type == alert_type)
    if reported_by is not None:
        q = q.filter(SystemAlert.reported_by == reported_by)
    return q.order_by(SystemAlert.created_at.desc()).all()

@app.get("/alerts/{alert_id}", response_model=AlertOut)
def get_alert(alert_id: int, db: Session = Depends(get_db)):
    alert = db.query(SystemAlert).filter(SystemAlert.alert_id == alert_id).first()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found.")
    return alert

@app.put("/alerts/{alert_id}", response_model=AlertOut)
def update_alert(alert_id: int, payload: AlertUpdate, db: Session = Depends(get_db)):
    alert = db.query(SystemAlert).filter(SystemAlert.alert_id == alert_id).first()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found.")

    if payload.station_id is not None:
        station = db.query(Station).filter(Station.station_id == payload.station_id).first()
        if not station:
            raise HTTPException(status_code=400, detail="station_id does not exist.")
        alert.station_id = payload.station_id

    if payload.reported_by is not None:
        user = db.query(User).filter(User.user_id == payload.reported_by).first()
        if not user:
            raise HTTPException(status_code=400, detail="reported_by user_id does not exist.")
        alert.reported_by = payload.reported_by

    if payload.alert_type is not None:
        alert.alert_type = payload.alert_type

    if payload.description is not None:
        alert.description = payload.description

    if payload.is_active is not None:
        alert.is_active = payload.is_active

    db.commit()
    db.refresh(alert)
    return alert

@app.delete("/alerts/{alert_id}")
def delete_alert(alert_id: int, db: Session = Depends(get_db)):
    alert = db.query(SystemAlert).filter(SystemAlert.alert_id == alert_id).first()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found.")
    db.delete(alert)
    db.commit()
    return {"message": "Alert deleted successfully."}