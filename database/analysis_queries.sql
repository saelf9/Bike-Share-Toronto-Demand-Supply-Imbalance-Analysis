USE bikeshare_toronto;

-- =========================================================
-- SECTION 1: DATA VALIDATION
-- =========================================================

-- Check table row counts
SELECT COUNT(*) AS clean_trips_count
FROM clean_trips;

SELECT COUNT(*) AS weather_count
FROM clean_weather_hourly;

SELECT COUNT(*) AS station_hourly_flow_count
FROM station_hourly_flow;

SELECT COUNT(*) AS station_risk_summary_count
FROM station_risk_summary;


-- Total trips
SELECT 
    COUNT(*) AS total_trips
FROM clean_trips;


-- Completed vs incomplete trips
SELECT
    is_completed_trip,
    COUNT(*) AS trip_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM clean_trips
GROUP BY is_completed_trip;


-- Valid vs invalid trip duration
SELECT
    valid_duration,
    COUNT(*) AS trip_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM clean_trips
GROUP BY valid_duration;


-- =========================================================
-- SECTION 2: GENERAL DEMAND PATTERNS
-- =========================================================

-- Trips by month
SELECT
    start_month,
    start_month_name,
    COUNT(*) AS trip_count
FROM clean_trips
GROUP BY start_month, start_month_name
ORDER BY start_month;


-- Trips by hour
-- Export as: reports/sql_outputs/trips_by_hour.csv
SELECT
    start_hour,
    COUNT(*) AS trip_count
FROM clean_trips
GROUP BY start_hour
ORDER BY start_hour;


-- Trips by weekday
-- Export as: reports/sql_outputs/trips_by_weekday.csv
SELECT
    start_weekday_num,
    start_weekday,
    COUNT(*) AS trip_count,
    ROUND(AVG(CASE WHEN valid_duration = 1 THEN duration_minutes END), 2) AS avg_valid_duration
FROM clean_trips
GROUP BY start_weekday_num, start_weekday
ORDER BY start_weekday_num;


-- Weekday vs weekend demand
-- Export as: reports/sql_outputs/weekday_weekend_summary.csv
SELECT
    is_weekend,
    COUNT(*) AS trip_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    ROUND(AVG(CASE WHEN valid_duration = 1 THEN duration_minutes END), 2) AS avg_valid_duration
FROM clean_trips
GROUP BY is_weekend;


-- Trips by user type
-- Export as: reports/sql_outputs/user_type_summary.csv
SELECT
    user_type,
    COUNT(*) AS valid_trip_count,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    ROUND(AVG(duration_minutes), 2) AS avg_duration_minutes,
    ROUND(MIN(duration_minutes), 2) AS min_duration_minutes,
    ROUND(MAX(duration_minutes), 2) AS max_duration_minutes
FROM clean_trips
WHERE valid_duration = 1
GROUP BY user_type
ORDER BY avg_duration_minutes DESC;


-- Trips by bike model
-- Export as: reports/sql_outputs/bike_model_summary.csv
SELECT
    bike_model,
    COUNT(*) AS trip_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM clean_trips
GROUP BY bike_model
ORDER BY trip_count DESC;


-- Average valid trip duration by bike model
SELECT
    bike_model,
    COUNT(*) AS valid_trip_count,
    ROUND(AVG(duration_minutes), 2) AS avg_duration_minutes
FROM clean_trips
WHERE valid_duration = 1
GROUP BY bike_model
ORDER BY avg_duration_minutes DESC;


-- =========================================================
-- SECTION 3: STATION DEMAND
-- =========================================================

-- Top start stations by departures
SELECT
    start_station_id,
    start_station_name,
    COUNT(*) AS departures
FROM clean_trips
GROUP BY start_station_id, start_station_name
ORDER BY departures DESC
LIMIT 20;


-- Top end stations by arrivals
SELECT
    end_station_id,
    end_station_name,
    COUNT(*) AS arrivals
FROM clean_trips
WHERE is_completed_trip = 1
GROUP BY end_station_id, end_station_name
ORDER BY arrivals DESC
LIMIT 20;


-- Worst bike-draining station-hours
SELECT
    station_id,
    station_name,
    datetime_hour,
    departures,
    arrivals,
    net_flow
FROM station_hourly_flow
ORDER BY net_flow ASC
LIMIT 20;


--  Worst dock-filling station-hours
SELECT
    station_id,
    station_name,
    datetime_hour,
    departures,
    arrivals,
    net_flow
FROM station_hourly_flow
ORDER BY net_flow DESC
LIMIT 20;


-- =========================================================
-- SECTION 4: REBALANCING RISK
-- =========================================================

-- Top bike shortage risk stations
-- Export as: reports/sql_outputs/top_bike_shortage_risk_stations.csv
SELECT
    station_id,
    station_name,
    total_departures,
    total_arrivals,
    bike_shortage_hours,
    min_hourly_net_flow,
    bike_shortage_risk_score
FROM station_risk_summary
ORDER BY bike_shortage_risk_score DESC
LIMIT 10;


-- Top dock shortage risk stations
-- Export as: reports/sql_outputs/top_dock_shortage_risk_stations.csv
SELECT
    station_id,
    station_name,
    total_departures,
    total_arrivals,
    dock_shortage_hours,
    max_hourly_net_flow,
    dock_shortage_risk_score
FROM station_risk_summary
ORDER BY dock_shortage_risk_score DESC
LIMIT 10;


-- Morning dock pressure stations
-- Morning arrivals can create dock shortage pressure.
-- Export as: reports/sql_outputs/morning_dock_pressure_stations.csv
SELECT
    station_id,
    station_name,
    SUM(arrivals) AS morning_arrivals,
    SUM(departures) AS morning_departures,
    SUM(net_flow) AS morning_net_flow
FROM station_hourly_flow
WHERE hour BETWEEN 7 AND 9
  AND is_weekend = 0
GROUP BY station_id, station_name
ORDER BY morning_net_flow DESC
LIMIT 15;


-- Evening bike pressure stations
-- Evening departures can create bike shortage pressure.
-- Export as: reports/sql_outputs/evening_bike_pressure_stations.csv
SELECT
    station_id,
    station_name,
    SUM(departures) AS evening_departures,
    SUM(arrivals) AS evening_arrivals,
    SUM(net_flow) AS evening_net_flow
FROM station_hourly_flow
WHERE hour BETWEEN 16 AND 18
  AND is_weekend = 0
GROUP BY station_id, station_name
ORDER BY evening_net_flow ASC
LIMIT 15;


-- Stations that appear in both morning dock pressure and evening bike pressure
WITH morning_pressure AS (
    SELECT
        station_id,
        station_name,
        SUM(arrivals) AS morning_arrivals,
        SUM(departures) AS morning_departures,
        SUM(net_flow) AS morning_net_flow
    FROM station_hourly_flow
    WHERE hour BETWEEN 7 AND 9
      AND is_weekend = 0
    GROUP BY station_id, station_name
),

evening_pressure AS (
    SELECT
        station_id,
        station_name,
        SUM(departures) AS evening_departures,
        SUM(arrivals) AS evening_arrivals,
        SUM(net_flow) AS evening_net_flow
    FROM station_hourly_flow
    WHERE hour BETWEEN 16 AND 18
      AND is_weekend = 0
    GROUP BY station_id, station_name
)

SELECT
    m.station_id,
    m.station_name,
    m.morning_arrivals,
    m.morning_departures,
    m.morning_net_flow,
    e.evening_departures,
    e.evening_arrivals,
    e.evening_net_flow
FROM morning_pressure m
JOIN evening_pressure e
    ON m.station_id = e.station_id
WHERE m.morning_net_flow > 0
  AND e.evening_net_flow < 0
ORDER BY m.morning_net_flow DESC, e.evening_net_flow ASC
LIMIT 20;


-- =========================================================
-- SECTION 5: WEATHER ANALYSIS
-- =========================================================

-- precipitation demand summary
-- Export as: reports/sql_outputs/weather_precipitation_summary.csv
WITH hourly_trip_counts AS (
    SELECT
        start_time_hour,
        COUNT(*) AS trips
    FROM clean_trips
    GROUP BY start_time_hour
)

SELECT
    w.has_precipitation,
    COUNT(w.weather_datetime) AS weather_hours,
    SUM(COALESCE(h.trips, 0)) AS total_trips,
    ROUND(AVG(COALESCE(h.trips, 0)), 2) AS avg_trips_per_hour
FROM clean_weather_hourly w
LEFT JOIN hourly_trip_counts h
    ON w.weather_datetime = h.start_time_hour
WHERE w.temperature_c IS NOT NULL
GROUP BY w.has_precipitation
ORDER BY w.has_precipitation;


-- Temperature band demand summary
-- Export as: reports/sql_outputs/weather_temperature_band_summary.csv
WITH hourly_trip_counts AS (
    SELECT
        start_time_hour,
        COUNT(*) AS trips
    FROM clean_trips
    GROUP BY start_time_hour
),

weather_bands AS (
    SELECT
        weather_datetime,
        CASE
            WHEN temperature_c < -5 THEN 'Below -5°C'
            WHEN temperature_c >= -5 AND temperature_c < 0 THEN '-5°C to 0°C'
            WHEN temperature_c >= 0 AND temperature_c < 5 THEN '0°C to 5°C'
            WHEN temperature_c >= 5 AND temperature_c < 10 THEN '5°C to 10°C'
            ELSE '10°C+'
        END AS temperature_band,
        temperature_c
    FROM clean_weather_hourly
    WHERE temperature_c IS NOT NULL
)

SELECT
    wb.temperature_band,
    COUNT(wb.weather_datetime) AS weather_hours,
    SUM(COALESCE(h.trips, 0)) AS total_trips,
    ROUND(AVG(COALESCE(h.trips, 0)), 2) AS avg_trips_per_hour
FROM weather_bands wb
LEFT JOIN hourly_trip_counts h
    ON wb.weather_datetime = h.start_time_hour
GROUP BY wb.temperature_band
ORDER BY MIN(wb.temperature_c);


-- Average duration during precipitation vs no precipitation
SELECT
    w.has_precipitation,
    COUNT(t.trip_id) AS trip_count,
    ROUND(AVG(CASE WHEN t.valid_duration = 1 THEN t.duration_minutes END), 2) AS avg_valid_duration
FROM clean_trips t
JOIN clean_weather_hourly w
    ON t.start_time_hour = w.weather_datetime
WHERE w.temperature_c IS NOT NULL
GROUP BY w.has_precipitation
ORDER BY w.has_precipitation;


-- Average duration by temperature band
SELECT
    CASE
        WHEN w.temperature_c < -5 THEN 'Below -5°C'
        WHEN w.temperature_c >= -5 AND w.temperature_c < 0 THEN '-5°C to 0°C'
        WHEN w.temperature_c >= 0 AND w.temperature_c < 5 THEN '0°C to 5°C'
        WHEN w.temperature_c >= 5 AND w.temperature_c < 10 THEN '5°C to 10°C'
        ELSE '10°C+'
    END AS temperature_band,
    COUNT(t.trip_id) AS trip_count,
    ROUND(AVG(CASE WHEN t.valid_duration = 1 THEN t.duration_minutes END), 2) AS avg_valid_duration
FROM clean_trips t
JOIN clean_weather_hourly w
    ON t.start_time_hour = w.weather_datetime
WHERE w.temperature_c IS NOT NULL
GROUP BY temperature_band
ORDER BY MIN(w.temperature_c);


-- =========================================================
-- SECTION 6: DASHBOARD-READY SUMMARY QUERIES
-- =========================================================

-- Executive KPI summary
SELECT
    COUNT(*) AS total_trips,
    SUM(CASE WHEN is_completed_trip = 1 THEN 1 ELSE 0 END) AS completed_trips,
    ROUND(SUM(CASE WHEN is_completed_trip = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completed_trip_rate,
    SUM(CASE WHEN valid_duration = 1 THEN 1 ELSE 0 END) AS valid_duration_trips,
    ROUND(SUM(CASE WHEN valid_duration = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS valid_duration_rate,
    ROUND(AVG(CASE WHEN valid_duration = 1 THEN duration_minutes END), 2) AS avg_valid_duration
FROM clean_trips;


--  Peak hour summary
SELECT
    start_hour,
    COUNT(*) AS trip_count
FROM clean_trips
GROUP BY start_hour
ORDER BY trip_count DESC
LIMIT 5;


--  Top overall risk stations using both scores
SELECT
    station_id,
    station_name,
    bike_shortage_risk_score,
    dock_shortage_risk_score,
    bike_shortage_hours,
    dock_shortage_hours,
    total_departures,
    total_arrivals,
    total_net_flow
FROM station_risk_summary
ORDER BY (bike_shortage_risk_score + dock_shortage_risk_score) DESC
LIMIT 15;