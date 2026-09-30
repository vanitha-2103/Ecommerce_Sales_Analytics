# E-Commerce Analytics Project
# 02_load_data
# Purpose: Bulk load raw CSV data into the 4 tables
use ecommerce_db;

# Import Customers table
# NOTE: customers.csv (90-ish rows, small file) was loaded using
-- MySQL Workbench's Table Data Import Wizard (right-click > Table
-- Data Import Wizard), not LOAD DATA INFILE -- since the file was
-- small enough that the wizard's row-by-row insert performance
-- wasn't an issue here (unlike orders/order_items at 9,000+ rows,
-- where the wizard was too slow/unreliable)

-- No PRIMARY KEY was applied before loading. Verified afterward
-- that customer_id had no duplicates:
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
-- Result: 0 rows returned -> confirmed customer_id is unique,
-- safe to add as PRIMARY KEY afterward.
ALTER TABLE customers ADD PRIMARY KEY (customer_id);


# Note: Update the file paths below to point to your local
--       copy of the CSVs in the /data/raw/ folder before running.

-- Enable local file loading (required once per session/server)
SET GLOBAL local_infile = 1;

# LOAD ORDERS
LOAD DATA LOCAL INFILE 'data/raw/Raworders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, customer_id, order_date, status, payment_method, @dc, shipping_fee)
SET discount_code = NULLIF(@dc, '');
-- NOTE: 38 rows were rejected here due to the orders.PRIMARY key constraint.
-- These were verified in Excel (COUNTIF) as genuine exact duplicate rows
-- in the source file, not data entry errors -- so rejecting them was the
-- correct behavior, not a bug.
# Result: Records: 9245, Skipped: 38, Warnings: 38 -> 9,207 rows loaded successfully

# Load Order_items
-- unit_price: blank cells in the source file are converted to NULL
-- (not 0) using NULLIF, since 199 rows had genuinely missing prices.
-- Letting MySQL silently default them to 0 would have understated
-- revenue/profit calculations.
LOAD DATA LOCAL INFILE 'data/raw/Raworder_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, product_id, quantity, @up, discount_amount)
SET unit_price = NULLIF(@up, '');

# LOAD PRODUCTS
-- category is standardized to Title Case during load
-- (source file had mixed case: "Kitchen", "kitchen", "KITCHEN")
load data local infile 'data/raw/Rawproducts.csv'
into table products
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
(product_id, product_name, @category, list_price, unit_cost)
set category = concat(upper(left(trim(@category),1)), lower(substring(trim(@category),2)));
-- NOTE: product_name column was initially too short (VARCHAR causing
-- Error 1265 "Data truncated"). Fixed with:
-- ALTER TABLE products MODIFY product_name VARCHAR(100);
-- before reloading.

-- VERIFICATION
-- ---------------------------------------------------
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM order_items;








