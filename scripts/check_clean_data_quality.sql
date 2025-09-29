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

