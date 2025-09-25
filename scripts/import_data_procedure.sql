CREATE OR ALTER PROCEDURE raw_data.load_raw_data AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT '              Loading RAW Data ';
		PRINT '================================================';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: raw_data.trips_flat_table';
		TRUNCATE TABLE raw_data.trips_flat_table;
		PRINT '>> Inserting Data Into: raw_data.trips_flat_table';

        PRINT '---------JANUARY DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202401-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> JANUARY Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------FEBRUARY DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202402-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> FEBRUARY Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------MARCH DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202403-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> MARCH Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------APRIL DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202404-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> APRIL Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------MAY DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202405-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> MAY Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------JUNE DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202406-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> JUNE Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------JULY DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202407-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> JULY Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------AUGUST DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202408-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> AUGUST Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------SEPTEMBER DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202409-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> SEPTEMBER Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------OCTOBER DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202410-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> OCTOBER Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------NOVEMBER DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202411-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> NOVEMBER Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
        PRINT '---------DECEMBER DATA---------'
		BULK INSERT raw_data.trips_flat_table
		FROM 'C:\Users\DELL\Desktop\BikeShare_Cyclistic2024\data\data_raw\202412-divvy-tripdata.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> DECEMBER Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading RAW Data is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
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