-- VERSION OF CLEAR_DATA_PROCEDURE WITHOUT USAGE OF CROSS APPLY
CREATE OR ALTER PROCEDURE cleaned_data.load_clean_data AS
BEGIN
	DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT '              Loading CLEANED Data ';
		PRINT '================================================';


        --we take nonclustered index down to insert data faster
        DROP INDEX IF EXISTS IX_trips_member   ON cleaned_data.trips_cleaned;
        DROP INDEX IF EXISTS IX_trips_date     ON cleaned_data.trips_cleaned;
        DROP INDEX IF EXISTS IX_trips_startsid ON cleaned_data.trips_cleaned;
        DROP INDEX IF EXISTS IX_trips_endsid   ON cleaned_data.trips_cleaned;

		PRINT '>> Truncating Table: cleaned_data.trips_cleaned';
		TRUNCATE TABLE cleaned_data.trips_cleaned;
		PRINT '>> Inserting Data Into: cleaned_data.trips_cleaned';

        INSERT INTO cleaned_data.trips_cleaned (
			ride_id, 
            rideable_type, 
            started_at, 
            ended_at,
            start_station_name, 
            start_station_id, 
            end_station_name, 
            end_station_id,
            start_lat, 
            start_lng, 
            end_lat, 
            end_lng,
            member_casual, 
            ride_seconds, 
            ride_minutes, 
            ride_date,
            weekday_name, 
            weekday_num, 
            season, 
            is_roundtrip
		)
		SELECT
            t.ride_id AS ride_id,
            CASE LOWER(t.rideable_type)
                WHEN 'classic_bike' THEN 'classic_bike'
                WHEN 'electric_bike' THEN 'electric_bike'
                WHEN 'electric_scooter'   THEN 'electric_scooter'
                ELSE NULL
            END AS rideable_type,
            --  start and end time reduced to seconds, no need for miliseconds accuracy
            TRY_CONVERT(datetime2(0), t.started_at) AS started_at,
            TRY_CONVERT(datetime2(0), t.ended_at)   AS ended_at,
            NULLIF(t.start_station_name,'') AS start_station_name,
            NULLIF(t.start_station_id  ,'') AS start_station_id,
            NULLIF(t.end_station_name  ,'') AS end_station_name,
            NULLIF(t.end_station_id    ,'') AS end_station_id,
            -- lattidtue and lengtittude with accuracy to 6 decimal places
            TRY_CONVERT(decimal(9,6), t.start_lat) AS start_lat,
            TRY_CONVERT(decimal(9,6), t.start_lng) AS start_lng,
            TRY_CONVERT(decimal(9,6), t.end_lat)   AS end_lat,
            TRY_CONVERT(decimal(9,6), t.end_lng)   AS end_lng,
            CASE LOWER(t.member_casual)
                WHEN 'member' THEN 'member'
                WHEN 'casual' THEN 'casual'
                ELSE NULL
            END AS member_casual,
            -- data enrichment, adding cols with time calculated, week name etc.
            DATEDIFF(SECOND, TRY_CONVERT(datetime2(0), t.started_at), TRY_CONVERT(datetime2(0), t.ended_at))        AS ride_seconds,
            DATEDIFF(SECOND, TRY_CONVERT(datetime2(0), t.started_at), TRY_CONVERT(datetime2(0), t.ended_at)) / 60.0 AS ride_minutes,
            CAST(TRY_CONVERT(datetime2(0), t.started_at) AS date)                                                   AS ride_date,
            DATENAME(WEEKDAY, TRY_CONVERT(datetime2(0), t.started_at))                                              AS weekday_name,
            DATEPART(WEEKDAY, TRY_CONVERT(datetime2(0), t.started_at))                                              AS weekday_num,
            CASE DATEPART(MONTH, TRY_CONVERT(datetime2(0), t.started_at))
                WHEN 12 THEN 'winter' WHEN 1 THEN 'winter' WHEN 2 THEN 'winter'
                WHEN 3  THEN 'spring' WHEN 4 THEN 'spring' WHEN 5 THEN 'spring'
                WHEN 6  THEN 'summer' WHEN 7 THEN 'summer' WHEN 8 THEN 'summer'
                ELSE 'autumn'
            END as season,                                                                                                    
            CASE 
                WHEN NULLIF(t.start_station_id,'') = NULLIF(t.end_station_id,'') THEN 1 
                ELSE 0 
            END as is_roundtrip
		FROM (
			SELECT
				-- removing "" symbols and TRIM of data
                TRIM(REPLACE(ride_id           , '"','')) AS ride_id,
                TRIM(REPLACE(rideable_type     , '"','')) AS rideable_type,
                TRIM(REPLACE(started_at        , '"','')) AS started_at,
                TRIM(REPLACE(ended_at          , '"','')) AS ended_at,
                TRIM(REPLACE(start_station_name, '"','')) AS start_station_name,
                TRIM(REPLACE(start_station_id  , '"','')) AS start_station_id,
                TRIM(REPLACE(end_station_name  , '"','')) AS end_station_name,
                TRIM(REPLACE(end_station_id    , '"','')) AS end_station_id,
                TRIM(start_lat)                           AS start_lat,
                TRIM(start_lng)                           AS start_lng,
                TRIM(end_lat)                             AS end_lat,
                TRIM(end_lng)                             AS end_lng,
                TRIM(REPLACE(member_casual     , '"','')) AS member_casual,
				ROW_NUMBER() OVER (
                        PARTITION BY TRIM(REPLACE(ride_id,'"',''))
                        ORDER BY TRY_CONVERT(datetime2(0), TRIM(REPLACE(ended_at,'"',''))) DESC
                    ) AS flag_last
			FROM raw_data.trips_raw
			WHERE ride_id IS NOT NULL
		) t
        -- COLUMNS *** in where are taken from t. query (so from inside of from query)
		WHERE flag_last = 1 -- Select the most recent record per trip
        AND started_at < ended_at -- start of trip reocded before end of trip
        AND started_at >= '2024-01-01' AND started_at < '2025-01-01' -- data from 2024
        AND DATEDIFF(SECOND, TRY_CONVERT(datetime2(0), t.started_at), TRY_CONVERT(datetime2(0), t.ended_at)) BETWEEN 60 and 86400 -- ride lasted between 60 sec and 24h

        AND start_lat BETWEEN 41.0 AND 42.5 -- coordinates for Chicago city 
        AND start_lng BETWEEN -88.0 AND -87.0
        AND end_lat   BETWEEN 41.0 AND 42.5
        AND end_lng   BETWEEN -88.0 AND -87.0

        -- dictionaries (data standarisation)
        AND t.rideable_type IN ('classic_bike','electric_bike','electric_scooter')
        AND t.member_casual IN ('member','casual');
        -- COLUMNS ***

        -- after inserting all the data we bring back the indexes
        CREATE INDEX IX_trips_member   ON cleaned_data.trips_cleaned(member_casual);
        CREATE INDEX IX_trips_date     ON cleaned_data.trips_cleaned(ride_date);
        CREATE INDEX IX_trips_startsid ON cleaned_data.trips_cleaned(start_station_id);
        CREATE INDEX IX_trips_endsid   ON cleaned_data.trips_cleaned(end_station_id);


		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading CLEANED Data is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING CLEANED DATA'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END