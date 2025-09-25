select DISTINCT(ride_id) from raw_data.trips_flat_table;
select DISTINCT(rideable_type) from raw_data.trips_flat_table;
select DISTINCT(started_at) from raw_data.trips_flat_table;
select DISTINCT(ended_at) from raw_data.trips_flat_table;
select DISTINCT(start_station_name) from raw_data.trips_flat_table;
select DISTINCT(start_station_id) from raw_data.trips_flat_table;
select DISTINCT(end_station_name) from raw_data.trips_flat_table;
select DISTINCT(end_station_id) from raw_data.trips_flat_table;
select DISTINCT(start_lat) from raw_data.trips_flat_table;
select DISTINCT(start_lng) from raw_data.trips_flat_table;
select DISTINCT(end_lat) from raw_data.trips_flat_table;
select DISTINCT(end_lng) from raw_data.trips_flat_table;
select DISTINCT(member_casual) from raw_data.trips_flat_table;

SELECT ride_id, COUNT(*)
FROM raw_data.trips_flat_table
GROUP BY ride_id
ORDER BY COUNT(*) DESC;


SELECT rideable_type, COUNT(*) AS rides
FROM raw_data.trips_flat_table
GROUP BY rideable_type
ORDER BY rides DESC;


SELECT CAST(started_at AS date) AS start_date, COUNT(*) AS rides
FROM raw_data.trips_flat_table
GROUP BY CAST(started_at AS date)
ORDER BY start_date;


SELECT CAST(ended_at AS date) AS end_date, COUNT(*) AS rides
FROM raw_data.trips_flat_table
GROUP BY CAST(ended_at AS date)
ORDER BY end_date;


SELECT start_station_name, COUNT(*) AS rides
FROM raw_data.trips_flat_table
GROUP BY start_station_name
ORDER BY rides DESC;


SELECT start_station_id, COUNT(*) AS rides
FROM raw_data.trips_flat_table
GROUP BY start_station_id
ORDER BY rides DESC;


SELECT end_station_name, COUNT(*) AS rides
FROM raw_data.trips_flat_table
GROUP BY end_station_name
ORDER BY rides DESC;


SELECT end_station_id, COUNT(*) AS rides
FROM raw_data.trips_flat_table
GROUP BY end_station_id
ORDER BY rides DESC;


SELECT start_lat, start_lng, COUNT(*) AS rides
FROM raw_data.trips_flat_table
GROUP BY start_lat, start_lng
ORDER BY rides DESC;


SELECT end_lat, end_lng, COUNT(*) AS rides
FROM raw_data.trips_flat_table
GROUP BY end_lat, end_lng
ORDER BY rides DESC;

SELECT member_casual, COUNT(*) AS rides
FROM raw_data.trips_flat_table
GROUP BY member_casual
ORDER BY rides DESC;