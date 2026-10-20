CREATE or ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
    BEGIN TRY

        DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME

        SET @batch_start_time = GETDATE()
        PRINT '================================================='
        PRINT '             Loading Bronze Layer...             '
        PRINT '================================================='
        PRINT '...'


        PRINT '----------------------------------------------'
        PRINT '             Loading From CRM...             '
        PRINT '----------------------------------------------'
        SET @start_time = GETDATE()
        PRINT '<< Trancating bronze.crm_cust_info..'
        TRUNCATE TABLE bronze.crm_cust_info

        PRINT '>> Insering bronze.crm_cust_info...'
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\JOHI-v2\Downloads\Learning\Sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH( 
            first_row = 2 ,
            fieldterminator = ',',
            tablock
        )
        set @end_time = GETDATE()
        PRINT '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) 



        SET @start_time = GETDATE()

        PRINT '<< Trancating bronze.crm_prd_info..'
        TRUNCATE TABLE [Bronze].[crm_prd_info]

        PRINT '>> Insering bronze.crm_prd_info...'
        BULK INSERT [Bronze].[crm_prd_info]
        FROM 'C:\Users\JOHI-v2\Downloads\Learning\Sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH( 
            first_row = 2 ,
            fieldterminator = ',',
            tablock
        )
        set @end_time = GETDATE()
        PRINT '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) 


        SET @start_time = GETDATE()
        PRINT '<< Trancating bronze.crm_sales_details..'
        TRUNCATE TABLE [Bronze].[crm_sales_details]

        PRINT '>> Insering bronze.crm_sales_details...'
        BULK INSERT [Bronze].[crm_sales_details]
        FROM 'C:\Users\JOHI-v2\Downloads\Learning\Sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH( 
            first_row = 2 ,
            fieldterminator = ',',
            tablock
        )
        set @end_time = GETDATE()
        PRINT '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) 



        PRINT '----------------------------------------------'
        PRINT '             Loading From ERP...             '
        PRINT '----------------------------------------------'
        
        SET @start_time = GETDATE()
        PRINT '<< Trancating bronze.erp_cust_az12..'
        TRUNCATE TABLE [Bronze].[erp_cust_az12]

        PRINT '>> Insering bronze.erp_cust_az12...'
        BULK INSERT [Bronze].[erp_cust_az12]
        FROM 'C:\Users\JOHI-v2\Downloads\Learning\Sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        WITH( 
            first_row = 2 ,
            fieldterminator = ',',
            tablock
        )
        set @end_time = GETDATE()
        PRINT '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) 



        SET @start_time = GETDATE()

        PRINT '<< Trancating bronze.erp_loc_a101..'
        TRUNCATE TABLE [Bronze].[erp_loc_a101]

        PRINT '>> Insering bronze.erp_loc_a101...'
        BULK INSERT [Bronze].[erp_loc_a101]
        FROM 'C:\Users\JOHI-v2\Downloads\Learning\Sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        WITH( 
            first_row = 2 ,
            fieldterminator = ',',
            tablock
        )
        set @end_time = GETDATE()
        PRINT '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) 


        SET @start_time = GETDATE()

        PRINT '<< Trancating bronze.erp_px_cat_g1v2..'
        TRUNCATE TABLE [Bronze].[erp_px_cat_g1v2]    

        PRINT '>> Insering bronze.erp_px_cat_g1v2...'
        BULK INSERT [Bronze].[erp_px_cat_g1v2]
        FROM 'C:\Users\JOHI-v2\Downloads\Learning\Sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        WITH( 
            first_row = 2 ,
            fieldterminator = ',',
            tablock
        )
        set @end_time = GETDATE()
        PRINT '>>Load Duration: ' + cast(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) 

        set @batch_end_time = GETDATE()
        PRINT '>>Total Duration: ' + cast(DATEDIFF(second, @batch_start_time, @batch_end_time) as NVARCHAR) 


    END TRY
    BEGIN CATCH
    PRINT '===================================='
    PRINT 'Error During Loading bronze Layer!!!'
    PRINT 'Error message:' + Error_message();
    PRINT 'Error code:' + cast( error_number() as NVARCHAR);
    PRINT '===================================='
    END CATCH
END

EXEC Bronze.load_bronze