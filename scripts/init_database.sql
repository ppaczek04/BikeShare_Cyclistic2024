CREATE DATABASE BikeShare;
GO

USE BikeShare;
GO

-- Create Schemas
CREATE SCHEMA raw_data;
GO

CREATE SCHEMA cleared_data;
GO


IF OBJECT_ID('raw_data.trips_flat_table', 'U') IS NOT NULL
    DROP TABLE raw_data.trips_flat_table;
GO

-- create a raw_data table
CREATE TABLE raw_data.trips_flat_table (
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

-- create a datatable for cleared data