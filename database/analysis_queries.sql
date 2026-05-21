USE bikeshare_toronto;

-- 1. Total trips
SELECT 
    COUNT(*) AS total_trips
FROM clean_trips;

-- 2. Completed vs incomplete trips
SELECT
    is_completed_trip,
    COUNT(*) AS trip_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM clean_trips
GROUP BY is_completed_trip;

-- 3. Valid vs invalid duration trips
SELECT
    valid_duration,
    COUNT(*) AS trip_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM clean_trips
GROUP BY valid_duration;

-- 4. Trips by month
SELECT
    start_month,
    start_month_name,
    COUNT(*) AS trip_count
FROM clean_trips
GROUP BY start_month, start_month_name
ORDER BY start_month;

-- 5. Trips by weekday
SELECT
    start_weekday_num,
    start_weekday,
    COUNT(*) AS trip_count
FROM clean_trips
GROUP BY start_weekday_num, start_weekday
ORDER BY start_weekday_num;

-- 6. Trips by hour
SELECT
    start_hour,
    COUNT(*) AS trip_count
FROM clean_trips
GROUP BY start_hour
ORDER BY start_hour;

-- 7. Top start stations
SELECT
    start_station_id,
    start_station_name,
    COUNT(*) AS departures
FROM clean_trips
GROUP BY start_station_id, start_station_name
ORDER BY departures DESC
LIMIT 20;

-- 8. Top end stations
SELECT
    end_station_id,
    end_station_name,
    COUNT(*) AS arrivals
FROM clean_trips
WHERE is_completed_trip = 1
GROUP BY end_station_id, end_station_name
ORDER BY arrivals DESC
LIMIT 20;

-- 9. Top bike shortage risk stations
SELECT
    station_id,
    station_name,
    total_departures,
    total_arrivals,
    total_net_flow,
    bike_shortage_hours,
    min_hourly_net_flow,
    bike_shortage_risk_score
FROM station_risk_summary
ORDER BY bike_shortage_risk_score DESC
LIMIT 10;

-- 10. Top dock shortage risk stations
SELECT
    station_id,
    station_name,
    total_departures,
    total_arrivals,
    total_net_flow,
    dock_shortage_hours,
    max_hourly_net_flow,
    dock_shortage_risk_score
FROM station_risk_summary
ORDER BY dock_shortage_risk_score DESC
LIMIT 10;

-- 11. Worst bike-draining station-hours
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

-- 12. Worst dock-filling station-hours
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