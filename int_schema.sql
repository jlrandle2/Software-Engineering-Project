-- User profiles & preferences
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    preferred_station_id INT,
    safety_alerts_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Station locations & metadata
CREATE TABLE stations (
    station_id SERIAL PRIMARY KEY,
    station_name VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    accessibility_features BOOLEAN DEFAULT FALSE
);

-- Routes
CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    route_name VARCHAR(50) NOT NULL, -- e.g., 'Red Line', 'Gold Line'
    direction VARCHAR(20) NOT NULL
);

-- Stops (Mapping routes to stations)
CREATE TABLE route_stops (
    stop_id SERIAL PRIMARY KEY,
    route_id INT REFERENCES routes(route_id),
    station_id INT REFERENCES stations(station_id),
    stop_sequence INT NOT NULL
);

-- System alerts & disruptions
CREATE TABLE system_alerts (
    alert_id SERIAL PRIMARY KEY,
    station_id INT REFERENCES stations(station_id),
    alert_type VARCHAR(50) NOT NULL, -- e.g., 'Delay', 'Safety', 'Maintenance'
    description TEXT,
    reported_by INT REFERENCES users(user_id), -- For Crowdsourced Alerts
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);