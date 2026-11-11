CREATE OR ALTER VIEW gold.dim_customer
AS
SELECT ROW_NUMBER() OVER (ORDER BY csi.cst_id) AS customer_key,
       csi.cst_id AS customer_id,
       csi.cst_key AS customer_number,
       csi.cst_firstname AS customer_firstname,
       csi.cst_lastname AS customer_lastname,
       CASE WHEN csi.cst_gndr = 'N/A' THEN COALESCE (csa.GEN, 'N/A') ELSE cst_gndr END AS gender,
       csi.cst_marital_status AS marital_status,
       csa.BDATE AS birthdate,
       loc.cntry AS country,
       csi.cst_create_date AS create_date
FROM   silver.crm_cust_info AS csi
       LEFT OUTER JOIN
       silver.erp_cust_az12 AS csa
       ON csi.cst_key = csa.CID
       LEFT OUTER JOIN
       Silver.erp_loc_a101 AS loc
       ON csi.cst_key = loc.CID;


GO
CREATE OR ALTER VIEW gold.dim_product
AS
SELECT ROW_NUMBER() OVER (ORDER BY prd.cat_id, prd.prd_key) AS product_key,
       prd.cat_id AS category_id,
       cat.CAT AS category,
       cat.SUBCAT AS subcategory,
       prd.prd_key AS product_number,
       prd.prd_nm AS product_name,
       prd.prd_cost AS cost,
       prd.prd_line AS "line",
       prd.prd_start_dt AS start_date,
       cat.MAINTENANCE AS maintenance
FROM   Silver.crm_prd_info AS prd
       LEFT OUTER JOIN
       silver.erp_px_cat_g1v2 AS cat
       ON prd.cat_id = cat.ID
WHERE  prd_end_dt IS NULL;


GO
CREATE OR ALTER VIEW gold.fact_sales
AS
SELECT sls.sls_ord_num AS order_number,
       cst.customer_key,
       prd.product_key,
       sls.sls_ord_dt AS order_date,
       sls.sls_ship_dt AS ship_date,
       sls.sls_due_dt AS due_date,
       sls.sls_sales AS sales_amount,
       sls.sls_quantity AS quantity,
       sls.sls_price AS price
FROM   Silver.crm_sales_details AS sls
       LEFT OUTER JOIN
       gold.dim_customer AS cst
       ON sls.sls_cust_id = cst.customer_id
       LEFT OUTER JOIN
       gold.dim_product AS prd
       ON sls.sls_prd_key = prd.product_number;