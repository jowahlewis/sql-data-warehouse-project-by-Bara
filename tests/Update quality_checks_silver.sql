/*
=============================================================================================
Quality Checks
=============================================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy, 
  and standadaziation across the 'silver' schemas. it includes checks for:
  -Null or duplicates primary keys
  -Unwanted spaces in string fields.
  -Data standadization and consistency.
  -Invalid data rnages and orders.
  -Data Consistency between related fields.

Usage Notes:
  -Run these checks after data loading silver layer.
  -Investigate and resolve any discrepancies found during the ckecks
=============================================================================================
*/

--===========================================================================================
--Checking 'silver.crm_cust_info'
--Check for NULLS or duplicates in primary keys
--Expectation: no results
--===========================================================================================
SELECT 
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


--Checking for unwanted spaces
--Expectation: No Results
SELECT
	*
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

--Data standardization and consistency
SELECT DISTINCT	
	cst_marital_status
FROM silver.crm_cust_info;

--===========================================================================================
--Checking 'silver.crm_prd_info'
--===========================================================================================
--Check for nulls or duplicates in primary key
--Expectation: No Result
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

--Checking for unwanted spaces
--Expectation: No Results
SELECT
	prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

--Check for nulls or negative value in cost
--Expectation: No Result
SELECT
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Check data standidization and consistency
SELECT DISTINCT
	prd_line
FROM silver.crm_prd_info;

--check for invalid date orders (start date > end date)
--expectation: no result
SELECT
	*
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


--===========================================================================================
--Checking 'silver.crm_sales_details'
--===========================================================================================
--Check for invalid dates
--Expectation: no invalid dates
SELECT
	NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
	OR LEN(sls_due_dt) != 8
	OR sls_due_dt > 20500101
	OR sls_due_dt < 19000101;

--Check for invalid date orders (order date > shipping/due dates)
--Expectation: no results
SELECT	
	*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
	OR sls_order_dt > sls_due_dt;

--Check data consistency: Sales = Quantity * price
--Expectation: No results
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL
	OR sls_quantity IS NULL
	OR sls_price IS NULL
	OR sls_sales <= 0
	OR sls_quantity <= 0
	OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

--===========================================================================================
--Checking 'silver.erp_cust_az1z'
--===========================================================================================
--Identify Out-Of-Range dates
--Expectation: Birthdates between 924-01-01 and today
SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
	OR bdate > GETDATE();

--Data standadization & consistency
SELECT DISTINCT
	gen
FROM silver.erp_cust_az12

--===========================================================================================
--Checking 'silver.erp_loc.a101'
--===========================================================================================
--Data standadization & consistency
SELECT DISTINCT
	cntry
FROM silver.erp_loc_a101
ORDER BY cntry


--===========================================================================================
--Checking 'silver.erp_px_cat_g1v2'
--===========================================================================================
--Check for unwanted spaces
--Expectation: No results
SELECT 
	*
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
	OR subcat != TRIM(subcat)
	OR mainteinance != TRIM(mainteinance)

--Data standadization & consistency
SELECT DISTINCT
	mainteinance
FROM silver.erp_px_cat_g1v2


