CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
        DECLARE @start_time AS DATETIME, @end_time AS DATETIME, @batch_start_time AS DATETIME, @batch_end_time AS DATETIME;
        BEGIN TRY
                SET @batch_start_time = GETDATE();
                PRINT '================================================';
                PRINT 'Loading Silver Layer';
                PRINT '================================================';
                PRINT '------------------------------------------------';
                PRINT 'Loading CRM Tables';
                PRINT '------------------------------------------------';
                PRINT '>> Truncating Table: silver.crm_cust_info';
                TRUNCATE TABLE silver.crm_cust_info;
                SET @start_time = GETDATE();
                PRINT '>> Inserting Data Into: silver.crm_cust_info';
                SET @start_time = GETDATE();
                INSERT INTO silver.crm_cust_info (
                        cst_id,
                        cst_key,
                        cst_firstname,
                        cst_lastname,
                        cst_marital_status,
                        cst_gndr,
                        cst_create_date
                )
                SELECT cst_id,
                       cst_key,
                       trim(cst_firstname) AS cst_firstname,
                       trim(cst_lastname) AS cst_lastname,
                       CASE WHEN Upper(TRIM(cst_marital_status)) = 'S' THEN 'Single' WHEN upper(TRIM(cst_marital_status)) = 'M' THEN 'Married' ELSE 'N/A' END AS cst_marital_status,
                       CASE WHEN upper(TRIM(cst_gndr)) = 'F' THEN 'Female' WHEN upper(TRIM(cst_gndr)) = 'M' THEN 'Male' ELSE 'N/A' END AS cst_gndr,
                       cst_create_date
                FROM   (SELECT DISTINCT *,
                                        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS recent_cst
                        FROM   bronze.crm_cust_info) AS t
                WHERE  recent_cst = 1
                       AND cst_key LIKE 'AW%';
                SET @end_time = GETDATE();
                PRINT '>> Load Duration ' + CAST (DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Second..';
                PRINT '>> -------------';
                PRINT '>> Truncating Table: silver.crm_prd_info';
                TRUNCATE TABLE silver.crm_prd_info;
                SET @start_time = GETDATE();
                PRINT '>> Inserting Data Into: silver.crm_prd_info';
                INSERT INTO Silver.crm_prd_info (
                        prd_id,
                        cat_id,
                        prd_key,
                        prd_nm,
                        prd_cost,
                        prd_line,
                        prd_start_dt,
                        prd_end_dt
                )
                SELECT prd_id,
                       REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
                       SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
                       TRIM(REPLACE(REPLACE(prd_nm, '- ', '-'), ' -', '-')) AS prd_nm,
                       CASE WHEN prd_cost IS NULL THEN 0 ELSE prd_cost END AS prd_cost,
                       CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain' WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road' WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring' WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Sports' ELSE 'N/A' END,
                       prd_start_dt,
                       DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prdx_end_dt
                FROM   [DataWarehouse].[Bronze].[crm_prd_info];
                SET @end_time = GETDATE();
                PRINT '>> Load Duration ' + CAST (DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Second..';
                PRINT '>> -------------';
                PRINT '>> Truncating Table: silver.crm_sales_details';
                TRUNCATE TABLE silver.crm_sales_details;
                SET @start_time = GETDATE();
                PRINT '>> Inserting Data Into: silver.crm_sales_details';
                INSERT INTO Silver.crm_sales_details (
                        sls_ord_num,
                        sls_prd_key,
                        sls_cust_id,
                        sls_ord_dt,
                        sls_ship_dt,
                        sls_due_dt,
                        sls_sales,
                        sls_quantity,
                        sls_price
                )
                SELECT sls_ord_num,
                       sls_prd_key,
                       sls_cust_id,
                       CASE WHEN NULLIF (sls_ord_dt, 0) IS NULL
                                 OR LEN(sls_ord_dt) <> 8 THEN NULL ELSE CAST (CAST (sls_ord_dt AS NVARCHAR) AS DATE) END AS sls_ord_dt,
                       CASE WHEN NULLIF (sls_ship_dt, 0) IS NULL
                                 OR LEN(sls_ship_dt) <> 8 THEN NULL ELSE CAST (CAST (sls_ship_dt AS NVARCHAR) AS DATE) END AS sls_ship_dt,
                       CASE WHEN NULLIF (sls_due_dt, 0) IS NULL
                                 OR LEN(sls_due_dt) <> 8 THEN NULL ELSE CAST (CAST (sls_due_dt AS NVARCHAR) AS DATE) END AS sls_due_dt,
                       CASE WHEN sls_sales IS NULL
                                 OR sls_sales <= 0
                                 OR sls_sales <> sls_quantity * abs(sls_price) THEN sls_quantity * ABS(sls_price) ELSE sls_sales END AS sls_sales,
                       sls_quantity,
                       CASE WHEN sls_price IS NULL
                                 OR sls_price <= 0
                                 OR sls_price <> abs(sls_sales) / sls_quantity THEN abs(sls_sales) / sls_quantity ELSE sls_price END AS sls_price
                FROM   Bronze.crm_sales_details;
                SET @end_time = GETDATE();
                PRINT '>> Load Duration ' + CAST (DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Second..';
                PRINT '>> -------------';
                PRINT '------------------------------------------------';
                PRINT 'Loading ERP Tables';
                PRINT '------------------------------------------------';
                PRINT '>> Truncating Table: silver.erp_cust_az12';
                TRUNCATE TABLE silver.erp_cust_az12;
                SET @start_time = GETDATE();
                PRINT '>> Inserting Data Into: silver.erp_cust_az12';
                INSERT INTO silver.erp_cust_az12 (
                        CID,
                        BDATE,
                        GEN
                )
                SELECT TRIM(REPLACE(CID, 'NAS', '')) AS cst_key,
                       CASE WHEN BDATE > GETDATE() THEN NULL ELSE BDATE END AS cst_birth_date,
                       CASE WHEN trim(gen) = ''
                                 OR gen IS NULL THEN 'N/A' WHEN TRIM(upper(gen)) = 'M' THEN 'Male' WHEN TRIM(upper(gen)) = 'F' THEN 'Female' ELSE TRIM(gen) END AS gen
                FROM   bronze.erp_cust_az12;
                SET @end_time = GETDATE();
                PRINT '>> Load Duration ' + CAST (DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Second..';
                PRINT '>> -------------';
                PRINT '>> Truncating Table: silver.erp_loc_a101';
                TRUNCATE TABLE silver.erp_loc_a101;
                SET @start_time = GETDATE();
                PRINT '>> Inserting Data Into: silver.erp_loc_a101';
                INSERT INTO Silver.erp_loc_a101 (
                        CID,
                        CNTRY
                )
                SELECT REPLACE(CID, '-', '') AS cst_key,
                       CASE WHEN TRIM(CNTRY) LIKE 'US%' THEN 'United States' WHEN trim(CNTRY) = 'DE' THEN 'Germany' WHEN trim(CNTRY) IS NULL
                                                                                                                         OR TRIM(CNTRY) = '' THEN 'N/A' ELSE TRIM(CNTRY) END AS country
                FROM   bronze.erp_loc_a101;
                SET @end_time = GETDATE();
                PRINT '>> Load Duration ' + CAST (DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Second..';
                PRINT '>> -------------';
                PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
                TRUNCATE TABLE silver.erp_px_cat_g1v2;
                SET @start_time = GETDATE();
                PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
                INSERT INTO silver.erp_px_cat_g1v2 (
                        ID,
                        CAT,
                        SUBCAT,
                        MAINTENANCE
                )
                SELECT *
                FROM   bronze.erp_px_cat_g1v2;
                SET @end_time = GETDATE();
                PRINT '>> Load Duration ' + CAST (DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Second..';
                PRINT '>> -------------';
                SET @batch_end_time = GETDATE();
                PRINT '==========================================';
                PRINT 'Loading Silver Layer is Completed';
                PRINT '   - Total Load Duration: ' + CAST (DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
                PRINT '==========================================';
        END TRY
        BEGIN CATCH
                PRINT '==========================================';
                PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
                PRINT 'Error message: ' + ERROR_MESSAGE();
                PRINT 'Error Number: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
                PRINT 'Error State: ' + CAST (ERROR_STATE() AS NVARCHAR);
                PRINT '==========================================';
        END CATCH
END