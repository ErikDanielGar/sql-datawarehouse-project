/*
===============================================================================
Data Quality Script: Validate Gold Layer Integriy
===============================================================================
Script Purpose:
    This script performs essential quality checks to ensure the integrity and 
    reliability of the Gold Layer (Dimensional Model).
    
    The checks focus on:
    - Primary Key Uniqueness: Verifying that Surrogate Keys (customer_key, 
      product_key) are unique and have no duplicates.
    - Referential Integrity: Ensuring that all sales records in the Fact Table 
      correctly map to existing records in the Dimension Tables.
    - Relationship Validation: Identifying "orphaned" records in the fact table 
      that lack a corresponding dimension entry.

Usage:
    - Any returned rows indicate a data quality issue that requires investigation.
===============================================================================
*/


-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.product_key'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  
