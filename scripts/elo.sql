CREATE OR ALTER PROCEDURE init_database AS
BEGIN
	
	BEGIN TRY
		CREATE DATABASE BikeShare;
        GO
        USE BikeShare;
        GO

        -- Create Schemas
        CREATE SCHEMA raw_data;
        GO
        CREATE SCHEMA cleaned_data;
        GO

        -- Create a table for raw data
        IF OBJECT_ID('raw_data.trips_raw', 'U') IS NOT NULL
            DROP TABLE raw_data.trips_raw;
        GO

        CREATE TABLE raw_data.trips_raw (
            ride_id            nvarchar(64),
            rideable_type      nvarchar(50),
            started_at         nvarchar(50),
            ended_at           nvarchar(50),
            start_station_name nvarchar(200),
            start_station_id   nvarchar(50),
            end_station_name   nvarchar(200),
            end_station_id     nvarchar(50),
            start_lat          nvarchar(50),
            start_lng          nvarchar(50),
            end_lat            nvarchar(50),
            end_lng            nvarchar(50),
            member_casual      nvarchar(50)
        );

        -- Create a table for cleared data
        IF OBJECT_ID('cleaned_data.trips_cleaned','U') IS NOT NULL
            DROP TABLE cleaned_data.trips_cleaned;
        GO

        CREATE TABLE cleaned_data.trips_cleaned (
            ride_id            nvarchar(64) PRIMARY KEY,
            rideable_type      nvarchar(20),
            started_at         datetime2(0),    -- accuracy to seconds
            ended_at           datetime2(0),
            start_station_name nvarchar(200),
            start_station_id   nvarchar(50),
            end_station_name   nvarchar(200),
            end_station_id     nvarchar(50),
            start_lat          decimal(9,6),
            start_lng          decimal(9,6),
            end_lat            decimal(9,6),
            end_lng            decimal(9,6),
            member_casual      nvarchar(20),
            ride_seconds       int,
            ride_minutes       decimal(10,2),
            ride_date          date,
            start_hour         tinyint,
            weekday_name       nvarchar(20),
            weekday_num        tinyint,
            -- year_month         char(7),         -- np. "2024-06"
            season             nvarchar(10),
            is_roundtrip       bit
        );
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING RAW DATA'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END