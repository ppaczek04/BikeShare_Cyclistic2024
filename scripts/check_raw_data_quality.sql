select DISTINCT(ride_id) from raw_data.trips_raw;
select DISTINCT(rideable_type) from raw_data.trips_raw;
select DISTINCT(started_at) from raw_data.trips_raw;
select DISTINCT(ended_at) from raw_data.trips_raw;
select DISTINCT(start_station_name) from raw_data.trips_raw;
select DISTINCT(start_station_id) from raw_data.trips_raw;
select DISTINCT(end_station_name) from raw_data.trips_raw;
select DISTINCT(end_station_id) from raw_data.trips_raw;
select DISTINCT(start_lat) from raw_data.trips_raw;
select DISTINCT(start_lng) from raw_data.trips_raw;
select DISTINCT(end_lat) from raw_data.trips_raw;
select DISTINCT(end_lng) from raw_data.trips_raw;
select DISTINCT(member_casual) from raw_data.trips_raw;

SELECT ride_id, COUNT(*)
FROM raw_data.trips_raw
GROUP BY ride_id
ORDER BY COUNT(*) DESC;

-- we noticed duplicate rows we will have to get ride of
select * from raw_data.trips_raw
where ride_id = '"141E161AD457FB35"' ;


SELECT rideable_type, COUNT(*) AS rides
FROM raw_data.trips_raw
GROUP BY rideable_type
ORDER BY rides DESC;


--SELECT CAST(started_at AS date) AS start_date, COUNT(*) AS rides
SELECT CAST(TRY_CONVERT(datetime2, REPLACE(started_at,'"','')) AS date) AS start_date, COUNT(*) AS rides
FROM raw_data.trips_raw
GROUP BY CAST(TRY_CONVERT(datetime2, REPLACE(started_at,'"','')) AS date)
ORDER BY start_date;


--SELECT CAST(ended_at AS date) AS end_date, COUNT(*) AS rides
SELECT CAST(TRY_CONVERT(datetime2, REPLACE(ended_at,'"','')) AS date) AS end_date, COUNT(*) AS rides
FROM raw_data.trips_raw
GROUP BY CAST(TRY_CONVERT(datetime2, REPLACE(ended_at,'"','')) AS date)
ORDER BY end_date;


SELECT start_station_name, COUNT(*) AS rides
FROM raw_data.trips_raw
GROUP BY start_station_name
ORDER BY rides DESC;


SELECT start_station_id, COUNT(*) AS rides
FROM raw_data.trips_raw
GROUP BY start_station_id
ORDER BY rides DESC;


SELECT end_station_name, COUNT(*) AS rides
FROM raw_data.trips_raw
GROUP BY end_station_name
ORDER BY rides DESC;


SELECT end_station_id, COUNT(*) AS rides
FROM raw_data.trips_raw
GROUP BY end_station_id
ORDER BY rides DESC;


SELECT start_lat, start_lng, COUNT(*) AS rides
FROM raw_data.trips_raw
GROUP BY start_lat, start_lng
ORDER BY rides DESC;

------------- SUS ZONE
SELECT start_station_id, COUNT(DISTINCT start_lat) AS lat_variants,
       COUNT(DISTINCT start_lng) AS lng_variants
FROM raw_data.trips_raw
GROUP BY start_station_id
HAVING COUNT(DISTINCT start_lat) > 1 OR COUNT(DISTINCT start_lng) > 1;

------------ STACJE CO MAJA PO KILKA LAT,LONG PUNKTOW


SELECT end_lat, end_lng, COUNT(*) AS rides
FROM raw_data.trips_raw
GROUP BY end_lat, end_lng
ORDER BY rides DESC;

SELECT member_casual, COUNT(*) AS rides
FROM raw_data.trips_raw
GROUP BY member_casual
ORDER BY rides DESC;