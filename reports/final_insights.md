# Final Insights

## 1. Dataset quality was strong enough for analysis

The cleaned database contains 552,073 trip records from January to March 2026.

Data quality checks showed:

- 550,233 trips had valid duration values
- 1,840 trips had invalid or extreme duration values
- 99.67% of trips were valid for duration-based analysis
- 550,398 trips were completed
- 1,675 trips were incomplete
- 99.70% of trips were usable for arrival and net-flow analysis

This means the dataset was reliable enough for station-flow and demand analysis.

## 2. Demand is strongly weekday-driven

Weekdays accounted for 423,728 trips, or 76.75% of total demand.

Weekends accounted for 128,345 trips, or 23.25%.

This suggests that Bike Share Toronto usage during the January to March period is strongly connected to weekday mobility patterns rather than only recreational weekend usage.

## 3. Members dominate usage, but casual riders take longer trips

Members accounted for 88.92% of all trips.

Casual riders accounted for 11.08%.

However, casual riders had a longer average valid trip duration:

- Casual riders: 16.12 minutes
- Members: 11.51 minutes

This suggests that members are more likely using Bike Share Toronto for shorter routine trips, while casual riders may be taking more occasional or leisure-oriented trips.

## 4. Demand peaks during commute hours

The busiest hour of the day was 5 PM, with 63,694 trips.

Other high-demand hours included:

- 8 AM
- 4 PM
- 6 PM

This supports a clear commute-driven demand pattern, especially during the evening peak.

## 5. Temperature has a clear relationship with demand

Bike-share usage increased as temperature increased.

Average trips per hour rose across temperature bands:

- Below -5°C: 108.39 trips/hour
- -5°C to 0°C: 219.18 trips/hour
- 0°C to 5°C: 314.41 trips/hour
- 5°C to 10°C: 493.60 trips/hour
- 10°C+: 693.80 trips/hour

This suggests that warmer winter and early-spring conditions are associated with higher bike-share demand.

## 6. Downtown stations show repeated rebalancing pressure

Several downtown stations appeared in both bike shortage and dock shortage risk rankings.

The strongest examples were:

- King St W / Bay St (West Side)
- Temperance St Station
- University Ave / Gerrard St W (East Side)

These stations received large numbers of bikes during the morning peak and lost large numbers of bikes during the evening peak.

This pattern suggests strong directional commute flow and repeated rebalancing pressure.

## 7. Morning and evening imbalance require different operational responses

Morning peak pressure is mainly dock-related.

Stations such as King St W / Bay St and Temperance St Station received far more arrivals than departures during the morning peak.

Evening peak pressure is mainly bike-related.

The same stations lost far more bikes than they received during the evening peak.

This means rebalancing should not be planned only by station popularity. It should consider the direction of flow by time of day.