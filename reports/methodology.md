# Methodology

## Cleaning Decisions

### Date and Time Fields

Trip start time, trip end time, and weather timestamps were converted into datetime format. Trip start time was used as the main timestamp for demand analysis because demand occurs when a rider starts a trip.

### Trip Duration

Trip duration was converted from seconds to minutes.

A trip was flagged as having a valid duration if:

```text
duration_minutes > 0 and duration_minutes <= 180
```
Trips outside this range were kept in the dataset for demand and station-flow analysis, but excluded from average duration KPIs.

### Completed Trips
A trip was considered completed if it had:

- end time
- end station ID
- end station name

All trips were used for departure demand analysis. Only completed trips were used for arrival and net-flow analysis.

### Weather Join
Hourly weather data was joined to trips using the trip start hour. This allowed each trip to be analyzed with the weather conditions at the time demand occurred.
A small number of trips had missing weather values because the source weather dataset had missing measurements for 5 hourly timestamps. These trips were kept for demand and station-flow analysis, but excluded from weather-specific analysis when weather fields were required.

### Station Flow
Station-level flow was calculated by comparing hourly departures and arrivals:
```text
net_flow = arrivals - departures
```
#### Interpretation:
- negative net_flow = station is losing bikes
- positive net_flow = station is gaining bikes

Negative net flow indicates possible bike shortage pressure. Positive net flow indicates possible dock shortage pressure.