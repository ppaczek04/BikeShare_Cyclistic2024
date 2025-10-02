---------------------------------------- ANALIZA
select * from cleaned_data.trips_cleaned;

SELECT 
    member_casual,
    COUNT(*) AS total_rides
FROM cleaned_data.trips_cleaned
GROUP BY member_casual;

---------------------------- tu moze cos w stylu ze elo jak dacie zniki na dla jendorazowke na dlugie przejazdy ale tylko na karnecie
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
    MIN(med)          AS median_ride_minutes   -- ta sama mediana w każdym wierszu partycji
FROM s
GROUP BY member_casual;
---------------------------- tu moze byc cos ze jednorazowkowicze najczesiej jezdza na weekndach (czyli przeciwnie do subow)

SELECT 
    member_casual,
    weekday_name,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
GROUP BY member_casual, weekday_name
ORDER BY member_casual, rides DESC;

SELECT 
    member_casual,
    DATEPART(HOUR, started_at) AS start_hour,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
GROUP BY member_casual, DATEPART(HOUR, started_at)
ORDER BY member_casual, start_hour;

SELECT 
    member_casual,
    start_station_name,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
WHERE start_station_name IS NOT NULL
GROUP BY member_casual, start_station_name
ORDER BY rides DESC
--OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

SELECT 
    member_casual,
    start_station_name,
    end_station_name,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
WHERE start_station_name IS NOT NULL AND end_station_name IS NOT NULL
GROUP BY member_casual, start_station_name, end_station_name
ORDER BY rides DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

SELECT 
    member_casual,
    rideable_type,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
GROUP BY member_casual, rideable_type
ORDER BY member_casual, rides DESC;

SELECT 
    member_casual,
    season,
    COUNT(*) AS rides
FROM cleaned_data.trips_cleaned
GROUP BY member_casual, season
ORDER BY member_casual, rides;

SELECT 
    member_casual,
    COUNT(DISTINCT start_station_id) AS unique_start_stations,
    COUNT(DISTINCT end_station_id)   AS unique_end_stations
FROM cleaned_data.trips_cleaned
GROUP BY member_casual;

-- trend of rides started at certain hour (0..23) for casual riders and membership riders
SELECT
    DATEPART(HOUR, started_at) AS start_hour,   -- 0..23
    member_casual,
    COUNT(*)                   AS rides
FROM cleaned_data.trips_cleaned
GROUP BY DATEPART(HOUR, started_at), member_casual
ORDER BY start_hour, member_casual;


----------------------------------