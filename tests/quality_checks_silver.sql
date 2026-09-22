-- Check the Nulls or Duplicates in Primary ky.
-- Expectation: No Results

SELECT 
prd_id,
Count(*)
FROM silver.crm_prd_info
Group by prd_id
Having Count(*)>1 or prd_id is NULL;

-- Checks fpr unwanted Spaces
-- Expectation: No Results

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

SELECT gen
FROM bronze.erp_cust_az12
WHERE gen != TRIM(gen);

SELECT * 
FROM bronze.erp_px_cat_g1v2
Where cat != Trim(cat) OR subcat != Trim(subcat) OR 
		maintenance != Trim(maintenance);

-- Data Standardization & Consistency

SELECT Distinct gen
FROM bronze.erp_cust_az12;

SELECT Distinct cst_marital_status
FROM silver.crm_cust_info;

SELECT *
FROM silver.crm_cust_info;

SELECT Distinct
maintenance
FROM bronze.erp_px_cat_g1v2;

-- Checks for NULLS or Negative Numbers
-- Expectations: No Results

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost <0 or prd_cost IS NULL;

-- Check for Invalid Date Orders

SELECT 
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) !=8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Between Sales, Quantity and Price
-- >> Sales = QUantity * Price
-- >> values must not be NULL, Zero or Negative.

SELECT DISTINCT
sls_sales oldS,
sls_quantity,
sls_price OldP,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <=0
		THEN sls_sales/ NULLIF(sls_quantity , 0) 
	ELSE sls_price
END as sls_price

FROM bronze.crm_sales_details
where sls_sales !=  sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales,sls_quantity, sls_price;


-- Identify Date Range

SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();