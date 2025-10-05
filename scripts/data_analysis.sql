/* ================================================================
   ANALYSIS SQL — Cyclistic Bike-Share Project
   Dataset: cleaned_data.trips_cleaned
   Goal: Identify behavioral differences between Members and Casual Riders.

   Notes:
     - Each query focuses on one business aspect (usage, timing, duration, etc.).
     - Observations (2024) are based on current dataset results.
     - Use these insights to guide marketing and membership strategy.
   ================================================================ */

-- 0) Quick data preview
SELECT TOP (100) * 
FROM cleaned_data.trips_cleaned;


-- 1) Total number of rides by user type
--    Purpose: Compare total trip counts between Members and Casual Riders.
--    Observation (2024): Members take more trips overall (~3.6M vs ~2.1M).
SELECT 
    member_casual,
    COUNT(*) AS total_rides
FROM cleaned_data.trips_cleaned
GROUP BY member_casual;


-- 2) Average and Median Trip Duration (minutes)
--    Purpose: Compare ride duration across user types.
--    Observation (2024): Casual riders take longer trips (AVG ≈ 21.6 min, MEDIAN ≈ 12.4)
--                        while Members take shorter, more frequent trips (AVG ≈ 12.4, MEDIAN ≈ 8.9).
WITH s AS (
    SELECT 
        member_casual,
        ride_minutes,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ride_minutes)
            OVER (PARTITION BY member_casual) AS med
    FROM cleaned_data.trips_cleaned
)
SELECT 
    member_casual,
    AVG(ride_minutes) AS avg_ride_minutes,
    MIN(med)          AS median_ride_minutes
FROM s
GROUP BY member_casual;


-- 3) Ride distribution by weekday
--    Purpose: Identify on which days users ride the most.
--    Observation (2024): Members are more active on weekdays (commuting patterns),
--                        while Casual riders dominate weekends (leisure trips).
SELECT 
    member_casual,
    weekday_name,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
GROUP BY member_casual, weekday_num, weekday_name
ORDER BY member_casual, weekday_num, rides DESC;


-- 4) Ride distribution by hour of day
--    Purpose: Detect peak riding hours for each user type.
--    Observation (2024): Members have strong peaks at ~8–9 AM and 5–6 PM (work commute),
--                        while Casual riders peak in the afternoon (~2–6 PM).
SELECT 
    member_casual,
    DATEPART(HOUR, started_at) AS start_hour,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
GROUP BY member_casual, DATEPART(HOUR, started_at)
ORDER BY member_casual, start_hour;


-- 5) Type of vehicle by user type
--    Purpose: Analyze rideable preference between user types.
--    Observation (2024): Casuals prefer electric bikes/scooters,
--                        Members use more classic bikes for routine trips.
SELECT 
    member_casual,
    rideable_type,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
GROUP BY member_casual, rideable_type
ORDER BY member_casual, rides DESC;


-- 6) Seasonality – rides by season
--    Purpose: Identify seasonal ride patterns.
--    Observation (2024): Both groups peak in summer, 
--                        but Casual riders are more affected by weather seasonality.
SELECT 
    member_casual,
    season,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
GROUP BY member_casual, season
ORDER BY member_casual, rides;


-- 7) Roundtrip behavior (start = end station)
--    Purpose: Measure how often users return to their starting point.
--    Observation (2024): Casual riders are more likely to take roundtrips 
--                        (recreational loops), while Members mostly travel 
--                        one-way (commuting between different stations).
SELECT 
    member_casual,
    SUM(CASE WHEN is_roundtrip = 1 THEN 1 ELSE 0 END) AS roundtrip_count,
    COUNT(*) AS total_rides,
    CAST(SUM(CASE WHEN is_roundtrip = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS pct_roundtrip
FROM cleaned_data.trips_cleaned
GROUP BY member_casual;



/* ==================================================================
Additional (secondary) queries, which capture additional observations
================================================================== */

-- 1) Most popular starting stations
--    Purpose: Identify top start stations for each user type.
--    Observation (2024): Casuals start more often from tourist-heavy or park areas.
SELECT 
    member_casual,
    start_station_name,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
WHERE start_station_name IS NOT NULL
GROUP BY member_casual, start_station_name
ORDER BY rides DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;  -- optional Top N filter


-- 2) Most frequent route pairs (Start → End)
--    Purpose: Show the most popular travel routes for each user type.
--    Observation (2024): Casuals tend to have common recreational routes (loops or park rides),
--                        Members show diverse commute-based routes.
SELECT 
    member_casual,
    start_station_name,
    end_station_name,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
WHERE start_station_name IS NOT NULL 
  AND end_station_name   IS NOT NULL
GROUP BY member_casual, start_station_name, end_station_name
ORDER BY rides DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


-- 3) Network reach – number of unique stations used
--    Purpose: Compare how widely each group uses the station network.
--    Observation (2024): Members use slightly more unique stations (broader coverage, commute purpose),
--                        while Casuals focus on fewer, recreational zones.
SELECT 
    member_casual,
    COUNT(DISTINCT start_station_id) AS unique_start_stations,
    COUNT(DISTINCT end_station_id)   AS unique_end_stations
FROM cleaned_data.trips_cleaned
GROUP BY member_casual;


-- 4) Ride duration by vehicle type
--    Purpose: Explore whether trip length differs by vehicle type.
--    Observation (2024): Classic bikes show the longest trip durations, especially for casual riders (~29 min median ~16). 
--                        E-bikes and scooters are used for shorter rides (casual ~15/12 min; members ~11/9 min). 
--                        This suggests e-bikes/scooters are chosen mainly for quick hops, while classic bikes are used more for longer leisure trips.
WITH s AS (
  SELECT
      rideable_type,
      member_casual,
      AVG(ride_minutes) OVER (PARTITION BY rideable_type, member_casual) AS avg_ride_minutes,
      PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ride_minutes)
        OVER (PARTITION BY rideable_type, member_casual)               AS median_ride_minutes
  FROM cleaned_data.trips_cleaned
  WHERE ride_minutes IS NOT NULL
)
SELECT DISTINCT
    rideable_type,
    member_casual,
    avg_ride_minutes,
    median_ride_minutes
FROM s
ORDER BY rideable_type, member_casual;