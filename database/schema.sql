CREATE DATABASE IF NOT EXISTS bikeshare_toronto;
USE bikeshare_toronto;

DROP TABLE IF EXISTS clean_trips;
DROP TABLE IF EXISTS clean_weather_hourly;
DROP TABLE IF EXISTS station_hourly_flow;
DROP TABLE IF EXISTS station_risk_summary;

CREATE TABLE clean_trips (
    trip_id BIGINT PRIMARY KEY,
    trip_duration INT,
    start_station_id INT,
    start_time DATETIME,
    start_station_name VARCHAR(255),
    end_station_id INT NULL,
    end_time DATETIME NULL,
    end_station_name VARCHAR(255) NULL,
    bike_id INT,
    user_type VARCHAR(50),
    bike_model VARCHAR(50),
    start_date DATE,
    start_hour INT,
    start_month INT,
    start_month_name VARCHAR(20),
    start_weekday VARCHAR(20),
    start_weekday_num INT,
    is_weekend BOOLEAN,
    start_time_hour DATETIME,
    end_time_hour DATETIME NULL,
    duration_minutes DECIMAL(10,2),
    valid_duration BOOLEAN,
    is_completed_trip BOOLEAN
);

CREATE TABLE clean_weather_hourly (
    weather_datetime DATETIME PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    time_lst VARCHAR(10),
    temperature_c DECIMAL(6,2) NULL,
    dew_point_c DECIMAL(6,2) NULL,
    relative_humidity DECIMAL(6,2) NULL,
    precipitation_mm DECIMAL(6,2) NULL,
    station_pressure_kpa DECIMAL(6,2) NULL,
    weather_station_name VARCHAR(100),
    climate_id INT,
    longitude DECIMAL(8,4),
    latitude DECIMAL(8,4),
    weather_date DATE,
    weather_hour INT,
    has_precipitation BOOLEAN
);

CREATE TABLE station_hourly_flow (
    station_id INT,
    station_name VARCHAR(255),
    datetime_hour DATETIME,
    departures INT,
    arrivals INT,
    net_flow INT,
    date DATE,
    hour INT,
    weekday VARCHAR(20),
    is_weekend BOOLEAN,
    PRIMARY KEY (station_id, datetime_hour)
);

CREATE TABLE station_risk_summary (
    station_id INT PRIMARY KEY,
    station_name VARCHAR(255),
    total_departures INT,
    total_arrivals INT,
    avg_hourly_departures DECIMAL(10,4),
    avg_hourly_arrivals DECIMAL(10,4),
    min_hourly_net_flow INT,
    max_hourly_net_flow INT,
    avg_net_flow DECIMAL(10,4),
    bike_shortage_hours INT,
    dock_shortage_hours INT,
    active_hours INT,
    total_net_flow INT,
    bike_shortage_risk_score DECIMAL(10,2),
    dock_shortage_risk_score DECIMAL(10,2)
);