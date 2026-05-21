# Methodology

## Project Scope

This project analyzes Bike Share Toronto trips from January 1, 2026 to March 31, 2026.

The goal is to identify station-level demand patterns, commute-driven imbalance, and possible rebalancing pressure using trip records, hourly weather data, and time-based features.

The analysis focuses on:

- trip demand patterns
- user behavior
- weather impact
- station-level arrivals and departures
- bike shortage pressure
- dock shortage pressure

## Data Sources

### Bike Share Toronto Ridership Data

The main dataset contains trip-level Bike Share Toronto records, including:

- trip ID
- trip duration
- start station
- start time
- end station
- end time
- bike ID
- user type
- bike model

### Toronto Hourly Weather Data

Hourly weather data was used to analyze how temperature and precipitation relate to bike-share demand.

Weather fields used include:

- temperature
- precipitation
- humidity
- station pressure
- weather timestamp

## Cleaning Decisions

### Date and Time Fields

Trip start time, trip end time, and weather timestamps were converted into datetime format.

Trip start time was used as the main timestamp for demand analysis because demand occurs when a rider starts a trip.

### Trip Duration

Trip duration was converted from seconds to minutes.

A trip was flagged as having a valid duration if:

```text
duration_minutes > 0 and duration_minutes <= 180
```
Trips outside this range were kept for demand and station-flow analysis, but excluded from average duration KPIs.
### Completed Trips

A trip was considered completed if it had:

end time
end station ID
end station name

All trips were used for departure demand analysis.

Only completed trips were used for arrival and net-flow analysis.

### Weather Join

Hourly weather data was joined to trips using the trip start hour.

This allowed each trip to be analyzed with the weather conditions at the time demand occurred.

A small number of trips had missing weather values because the source weather dataset had missing measurements for 5 hourly timestamps.

These trips were kept for demand and station-flow analysis, but excluded from weather-specific analysis when weather fields were required.

### Station Flow Calculation

Station-level flow was calculated by comparing hourly departures and arrivals:

net_flow = arrivals - departures

#### Interpretation:

- negative net flow = station is losing bikes

   Negative net flow indicates possible bike shortage pressure.

- positive net flow = station is gaining bikes

   Positive net flow indicates possible dock shortage pressure.

## Rebalancing Risk Logic

This project does not directly measure whether stations were empty or full.

Instead, it uses station-hour flow imbalance as a proxy for rebalancing pressure.

A station with repeated negative net flow during peak periods may require bike replenishment.

A station with repeated positive net flow during peak periods may require dock availability management.

## SQL Analysis

SQL was used after Python cleaning to:

validate row counts
calculate data quality KPIs
summarize trip demand patterns
compare weekday and weekend behavior
analyze user type and bike model usage
compare demand across weather conditions
identify station-level imbalance
rank high-risk rebalancing stations
produce dashboard-ready result tables
## Limitations

This analysis uses completed trip records and station flow imbalance as a proxy for shortage risk.

The dataset does not directly show:

- riders who could not start a trip because no bikes were available
- riders who could not end a trip because no docks were available
- live bike availability
- live dock availability

A future version could improve the analysis by collecting live GBFS station status data with available bikes and docks.