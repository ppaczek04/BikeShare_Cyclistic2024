SELECT 
    (SELECT COUNT(*) FROM raw_data.trips_raw) 
  - (SELECT COUNT(*) FROM cleaned_data.trips_cleaned) AS diff_count;


select * from cleaned_data.trips_cleaned
where start_station_name is NULL;

-- how many rides are not start/end in-dock
SELECT COUNT(*) AS null_stations
FROM cleaned_data.trips_cleaned
WHERE start_station_name IS NULL;


-- ** IMPORTANT **
-- This query checks how many trips have NULL station IDs.
-- The results show that all NULLs occur for electric_bike and electric_scooter,
-- which are dockless vehicles and can start/end outside docking stations.
-- Classic_bike trips almost never have NULLs, confirming they are always dock-to-dock.
SELECT rideable_type,
       COUNT(*) AS rides,
       SUM(CASE WHEN start_station_id IS NULL THEN 1 ELSE 0 END) AS start_nulls,
       SUM(CASE WHEN end_station_id   IS NULL THEN 1 ELSE 0 END) AS end_nulls
FROM cleaned_data.trips_cleaned
GROUP BY rideable_type;

-- Count how many distinct station_ids are linked to each station_name
WITH StationNameIdPairs AS (
    SELECT DISTINCT
        start_station_name,
        start_station_id
    FROM cleaned_data.trips_cleaned
)
SELECT
    start_station_name,
    COUNT(*) AS distinct_station_id_count
FROM StationNameIdPairs
GROUP BY start_station_name
ORDER BY distinct_station_id_count DESC;

