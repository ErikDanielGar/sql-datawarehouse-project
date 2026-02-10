/* 
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates the final Gold Layer views for the Data Warehouse.
    - It transforms Silver Layer tables into a Star Schema (Dimensional Model).
    - It generates Surrogate Keys (PKs) using ROW_NUMBER() for dimensions.
    - It integrates data from multiple sources (CRM and ERP) into unified views.
    - It ensures business logic application (e.g., gender consolidation and product filtering).

Usage:
    - These views serve as the primary source for BI tools, analytics, and reporting.
    - They provide a clean, user-friendly interface for end-users by renaming 
      technical source columns to business-friendly names.
===============================================================================
*/

-- ===========================================
-- Create Dim Table: gold.dim_customers
-- ===========================================
IF OBJECT_ID ('gold.dim_customers', 'V') IS NOT NULL
  DROP VIEW 'gold.dim_customers';
GO


CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY cci.cst_id) AS customer_key,
	cci.cst_id AS customer_id,
	cci.cst_key AS customer_number,
	cci.cst_firstname AS first_name,
	cci.cst_lastname AS last_name,
	ela.cntry AS country,
	cci.cst_marital_status AS marital_status,
	CASE
		WHEN cci.cst_gndr != 'n/a' THEN cci.cst_gndr -- CRM is the master for gender info.
		ELSE COALESCE(eca.gen, 'n/a')
	END AS gender,
	eca.bdate AS birth_date,
	cci.cst_create_date AS create_date
	FROM silver.crm_cust_info AS cci
	LEFT JOIN silver.erp_cust_az12 AS eca
	ON cci.cst_key = eca.cid
	LEFT JOIN silver.erp_loc_a101 AS ela
	ON cci.cst_key = ela.cid;
GO

-- ===========================================
-- Create Dim Table: gold.dim_products
-- ===========================================
IF OBJECT_ID ('gold.dim_products', 'V') IS NOT NULL
  DROP VIEW 'gold.dim_products';
GO

CREATE VIEW gold.dim_products AS
SELECT 
ROW_NUMBER() OVER(ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key,
cpi.prd_id AS product_id,
cpi.prd_key AS product_number,
cpi.prd_nm AS product_name,
cpi.cat_id AS category_id,
epc.cat AS category,
epc.subcat AS subcategory,
epc.maintenance,
cpi.prd_cost AS cost,
cpi.prd_line AS product_line,
cpi.prd_start_dt AS start_date
FROM silver.crm_prd_info AS cpi
LEFT JOIN silver.erp_px_cat_g1v2 AS epc
ON cpi.cat_id = epc.id
WHERE prd_end_dt IS NULL;
GO


-- ===========================================
-- Create Fact Table: gold.fact_sales
-- ===========================================
IF OBJECT_ID ('gold.fact_sales', 'V') IS NOT NULL
  DROP VIEW 'gold.fact_sales';
GO
  
CREATE VIEW gold.fact_sales AS
SELECT 
sls_ord_num AS order_number,
pr.product_key,
cu.customer_key,
sls_order_dt AS order_date,
sls_ship_dt AS ship_date,
sls_due_dt AS due_date,
sls_sales AS sales,
sls_quantity AS quantity,
sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cu
ON sd.sls_cust_id = cu.customer_id;

