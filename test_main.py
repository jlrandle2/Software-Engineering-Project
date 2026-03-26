import os
import tempfile

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from db import Base, get_db
from main import app
from models import User, Station, Route, RouteStop, SystemAlert


@pytest.fixture
def client():
    temp_db = tempfile.NamedTemporaryFile(delete=False, suffix=".db")
    temp_db.close()

    test_db_url = f"sqlite:///{temp_db.name}"
    engine = create_engine(
        test_db_url,
        connect_args={"check_same_thread": False}
    )
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    Base.metadata.create_all(bind=engine)

    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()
    Base.metadata.drop_all(bind=engine)
    os.unlink(temp_db.name)


def create_station(client, name="Five Points"):
    response = client.post(
        "/stations",
        json={
            "station_name": name,
            "latitude": 33.7537,
            "longitude": -84.3915,
            "accessibility_features": True
        }
    )
    return response


def create_user(client, username="avvai", email="avvai@example.com", preferred_station_id=None):
    response = client.post(
        "/users",
        json={
            "username": username,
            "email": email,
            "preferred_station_id": preferred_station_id,
            "safety_alerts_enabled": True
        }
    )
    return response


def create_route(client, route_name="Red Line", direction="Northbound"):
    response = client.post(
        "/routes",
        json={
            "route_name": route_name,
            "direction": direction
        }
    )
    return response


def create_alert(client, station_id, alert_type="Delay", description="Train delayed", reported_by=None, is_active=True):
    response = client.post(
        "/alerts",
        json={
            "station_id": station_id,
            "alert_type": alert_type,
            "description": description,
            "reported_by": reported_by,
            "is_active": is_active
        }
    )
    return response


def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_create_user_success(client):
    response = create_user(client)
    assert response.status_code == 200

    data = response.json()
    assert data["username"] == "avvai"
    assert data["email"] == "avvai@example.com"
    assert data["safety_alerts_enabled"] is True
    assert "user_id" in data


def test_create_user_duplicate_email_fails(client):
    create_user(client, username="avvai1", email="same@example.com")
    response = create_user(client, username="avvai2", email="same@example.com")

    assert response.status_code == 409
    assert response.json()["detail"] == "Username or email already exists."


def test_create_user_duplicate_username_fails(client):
    create_user(client, username="sameuser", email="one@example.com")
    response = create_user(client, username="sameuser", email="two@example.com")

    assert response.status_code == 409
    assert response.json()["detail"] == "Username or email already exists."


def test_get_user_not_found(client):
    response = client.get("/users/999")
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found."


def test_create_station_success(client):
    response = create_station(client)
    assert response.status_code == 200

    data = response.json()
    assert data["station_name"] == "Five Points"
    assert "station_id" in data


def test_list_stations_returns_created_station(client):
    create_station(client, name="Peachtree Center")
    response = client.get("/stations")

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["station_name"] == "Peachtree Center"


def test_create_route_success(client):
    response = create_route(client)
    assert response.status_code == 200

    data = response.json()
    assert data["route_name"] == "Red Line"
    assert data["direction"] == "Northbound"


def test_list_routes_returns_created_route(client):
    create_route(client, route_name="Gold Line", direction="Southbound")
    response = client.get("/routes")

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["route_name"] == "Gold Line"


def test_create_route_stop_success(client):
    route_response = create_route(client)
    station_response = create_station(client)

    route_id = route_response.json()["route_id"]
    station_id = station_response.json()["station_id"]

    response = client.post(
        "/route-stops",
        json={
            "route_id": route_id,
            "station_id": station_id,
            "stop_sequence": 1
        }
    )

    assert response.status_code == 200
    data = response.json()
    assert data["route_id"] == route_id
    assert data["station_id"] == station_id
    assert data["stop_sequence"] == 1


def test_create_route_stop_invalid_route_fails(client):
    station_response = create_station(client)
    station_id = station_response.json()["station_id"]

    response = client.post(
        "/route-stops",
        json={
            "route_id": 999,
            "station_id": station_id,
            "stop_sequence": 1
        }
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "route_id does not exist."


def test_create_route_stop_invalid_station_fails(client):
    route_response = create_route(client)
    route_id = route_response.json()["route_id"]

    response = client.post(
        "/route-stops",
        json={
            "route_id": route_id,
            "station_id": 999,
            "stop_sequence": 1
        }
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "station_id does not exist."


def test_get_route_stops_returns_ordered_stops(client):
    route_response = create_route(client)
    route_id = route_response.json()["route_id"]

    station1 = create_station(client, name="Station A").json()["station_id"]
    station2 = create_station(client, name="Station B").json()["station_id"]

    client.post(
        "/route-stops",
        json={"route_id": route_id, "station_id": station2, "stop_sequence": 2}
    )
    client.post(
        "/route-stops",
        json={"route_id": route_id, "station_id": station1, "stop_sequence": 1}
    )

    response = client.get(f"/routes/{route_id}/stops")
    assert response.status_code == 200

    data = response.json()
    assert len(data) == 2
    assert data[0]["stop_sequence"] == 1
    assert data[1]["stop_sequence"] == 2


def test_create_alert_success(client):
    station_id = create_station(client).json()["station_id"]
    user_id = create_user(client).json()["user_id"]

    response = create_alert(
        client,
        station_id=station_id,
        alert_type="Safety",
        description="Suspicious activity reported",
        reported_by=user_id,
        is_active=True
    )

    assert response.status_code == 200
    data = response.json()
    assert data["station_id"] == station_id
    assert data["alert_type"] == "Safety"
    assert data["reported_by"] == user_id
    assert data["is_active"] is True


def test_create_alert_invalid_station_fails(client):
    response = create_alert(client, station_id=999)

    assert response.status_code == 400
    assert response.json()["detail"] == "station_id does not exist."


def test_create_alert_invalid_reported_by_fails(client):
    station_id = create_station(client).json()["station_id"]

    response = create_alert(
        client,
        station_id=station_id,
        reported_by=999
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "reported_by user_id does not exist."


def test_list_alerts_active_only_default(client):
    station_id = create_station(client).json()["station_id"]

    create_alert(client, station_id=station_id, alert_type="Delay", is_active=True)
    create_alert(client, station_id=station_id, alert_type="Maintenance", is_active=False)

    response = client.get("/alerts")
    assert response.status_code == 200

    data = response.json()
    assert len(data) == 1
    assert data[0]["alert_type"] == "Delay"
    assert data[0]["is_active"] is True


def test_list_alerts_can_include_inactive(client):
    station_id = create_station(client).json()["station_id"]

    create_alert(client, station_id=station_id, alert_type="Delay", is_active=True)
    create_alert(client, station_id=station_id, alert_type="Maintenance", is_active=False)

    response = client.get("/alerts?active_only=false")
    assert response.status_code == 200

    data = response.json()
    assert len(data) == 2


def test_list_alerts_filter_by_station(client):
    station1 = create_station(client, name="North Ave").json()["station_id"]
    station2 = create_station(client, name="Midtown").json()["station_id"]

    create_alert(client, station_id=station1, alert_type="Delay")
    create_alert(client, station_id=station2, alert_type="Safety")

    response = client.get(f"/alerts?station_id={station1}&active_only=false")
    assert response.status_code == 200

    data = response.json()
    assert len(data) == 1
    assert data[0]["station_id"] == station1
    assert data[0]["alert_type"] == "Delay"