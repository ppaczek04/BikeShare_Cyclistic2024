/*===============================================================
 Procedure: cleaned_data.load_clean_data
 Purpose  : Cleans and transforms raw trip data into a curated form,
            ready for analytics and reporting (CLEANED layer).
 
 Key Cleaning Rules:
   - Remove duplicate ride_ids (keep latest ended_at).
   - Convert timestamps to datetime2, lat/long to decimal.
   - Enforce trip duration (60 sec – 24h).
   - Keep only trips within Chicago coordinates.
   - Standardize categorical fields (rideable_type, member_casual).
   - Derive enrichment columns: ride_seconds, ride_minutes,
     ride_date, weekday_name/num, season, is_roundtrip.

 Index Handling:
   - Nonclustered indexes are dropped before load (faster insert).
   - Recreated after load to support analysis queries.

 Note:
   Cleaned layer guarantees consistent datatypes,
   valid ranges, and enriched attributes for BI tools.
===============================================================*/

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
            x.x_started_at AS started_at,
            x.x_ended_at   AS ended_at,
            NULLIF(t.start_station_name,'') AS start_station_name,
            NULLIF(t.start_station_id  ,'') AS start_station_id,
            NULLIF(t.end_station_name  ,'') AS end_station_name,
            NULLIF(t.end_station_id    ,'') AS end_station_id,
            -- lattidtue and lengtittude with accuracy to 6 decimal places
            x.x_start_lat AS start_lat,
            x.x_start_lng AS start_lng,
            x.x_end_lat   AS end_lat,
            x.x_end_lng   AS end_lng,
            CASE LOWER(t.member_casual)
                WHEN 'member' THEN 'member'
                WHEN 'casual' THEN 'casual'
                ELSE NULL
            END AS member_casual,
            -- data enrichment, adding cols with time calculated, week name etc.
            x.x_ride_seconds AS ride_seconds,
            x.x_ride_seconds / 60.0 AS ride_minutes,
            CAST(x.x_started_at AS date)                                                   AS ride_date,
            DATENAME(WEEKDAY, x.x_started_at)                                            AS weekday_name,
            DATEPART(WEEKDAY, x.x_started_at)                                            AS weekday_num,
            CASE DATEPART(MONTH, x.x_started_at)
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
        -- cross apply so that i can use parsed (to correct type) data in where clauses,
        -- also, now the conversion happens only in cross apply, not in outer select and in where clause
        CROSS APPLY (
            SELECT
                TRY_CONVERT(datetime2(0), t.started_at) AS x_started_at,
                TRY_CONVERT(datetime2(0), t.ended_at)   AS x_ended_at,
                TRY_CONVERT(decimal(9,6), t.start_lat)  AS x_start_lat,
                TRY_CONVERT(decimal(9,6), t.start_lng)  AS x_start_lng,
                TRY_CONVERT(decimal(9,6), t.end_lat)    AS x_end_lat,
                TRY_CONVERT(decimal(9,6), t.end_lng)    AS x_end_lng,
                DATEDIFF(SECOND,
                    TRY_CONVERT(datetime2(0), t.started_at),
                    TRY_CONVERT(datetime2(0), t.ended_at)
                ) AS x_ride_seconds
        ) x
        -- COLUMNS *** in where are taken from t. query (so from inside of from query)
		WHERE t.flag_last = 1 -- Select the most recent record per trip
        AND x.x_started_at < x.x_ended_at -- start of trip reocded before end of trip
        AND x.x_started_at >= '2024-01-01' AND x.x_started_at < '2025-01-01' -- data from 2024
        AND x.x_ride_seconds BETWEEN 60 and 86400 -- ride lasted between 60 sec and 24h

        AND x.x_start_lat BETWEEN 41.0 AND 42.5 -- coordinates for Chicago city 
        AND x.x_start_lng BETWEEN -88.0 AND -87.0
        AND x.x_end_lat   BETWEEN 41.0 AND 42.5
        AND x.x_end_lng   BETWEEN -88.0 AND -87.0

        -- dictionaries (data standarisation)
        AND LOWER(t.rideable_type) IN ('classic_bike','electric_bike','electric_scooter')
        AND LOWER(t.member_casual) IN ('member','casual');
        -- COLUMNS ***

        /* ===== Normalize station_id by station_name (canonical IDs) ===== */
        PRINT '>> Normalizing station_id values based on station_name...';

        -- create a start_map: for each start_station_name choose the most popular start_station_id
        IF OBJECT_ID('tempdb..#start_map') IS NOT NULL DROP TABLE #start_map;
        WITH start_counts AS (
            SELECT start_station_name, start_station_id, COUNT(*) AS cnt
            FROM cleaned_data.trips_cleaned
            WHERE start_station_name IS NOT NULL AND start_station_id IS NOT NULL
            GROUP BY start_station_name, start_station_id
        ),
        pick AS (
            SELECT
                start_station_name,
                start_station_id,
                ROW_NUMBER() OVER (
                    PARTITION BY start_station_name
                    ORDER BY cnt DESC, start_station_id
                ) AS rn
            FROM start_counts
        )
        SELECT
            start_station_name,
            start_station_id AS canonical_start_id
        INTO #start_map
        FROM pick
        WHERE rn = 1;

        -- create an end_map: for each end_station_name choose the most popular end_station_id
        IF OBJECT_ID('tempdb..#end_map') IS NOT NULL DROP TABLE #end_map;
        WITH end_counts AS (
            SELECT end_station_name, end_station_id, COUNT(*) AS cnt
            FROM cleaned_data.trips_cleaned
            WHERE end_station_name IS NOT NULL AND end_station_id IS NOT NULL
            GROUP BY end_station_name, end_station_id
        ),
        pick AS (
            SELECT
                end_station_name,
                end_station_id,
                ROW_NUMBER() OVER (
                    PARTITION BY end_station_name
                    ORDER BY cnt DESC, end_station_id
                ) AS rn
            FROM end_counts
        )
        SELECT
            end_station_name,
            end_station_id AS canonical_end_id
        INTO #end_map
        FROM pick
        WHERE rn = 1;

        -- update start_station_id when it differs from most popular start_station_id
        UPDATE c
        SET c.start_station_id = sm.canonical_start_id
        FROM cleaned_data.trips_cleaned AS c
        JOIN #start_map AS sm
        ON sm.start_station_name = c.start_station_name
        WHERE c.start_station_id IS NULL OR c.start_station_id <> sm.canonical_start_id;

        -- update end_station_id when it differs from most popular end_station_id
        UPDATE c
        SET c.end_station_id = em.canonical_end_id
        FROM cleaned_data.trips_cleaned AS c
        JOIN #end_map AS em
        ON em.end_station_name = c.end_station_name
        WHERE c.end_station_id IS NULL OR c.end_station_id <> em.canonical_end_id;

        PRINT '>> Station_id normalization completed successfully.';
        /* ===== End normalization ===== */

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