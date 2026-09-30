E-Commerce Sales & Customer Analytics

End-to-end analytics project: raw e-commerce data → SQL cleaning & analysis → Power BI dashboard.

📊 Project Overview

This project analyzes an e-commerce dataset (customers, orders, order line items, and products) to answer core business questions around revenue, profitability, customer retention, and payment/discount behavior. All data cleaning and transformation was done in SQL (not in Excel or pandas), so the entire pipeline is reproducible directly from the raw CSV files.

🗂️ Dataset
4 tables: customers, orders, order_items, products
Scale: ~9,200 orders, ~15,600 order line items, 2,047 customers, 90 products
Raw files: available in /data/raw/ (uncleaned, as originally received)
🛠️ Tools Used
MySQL — data loading, cleaning, transformation, business logic
Power BI — dashboard, DAX measures, cross-tool validation
Excel — used only for initial raw file inspection and duplicate verification, not for cleaning

🧹 Data Cleaning — done entirely in SQL
Raw data was loaded as-is and cleaned using SQL, so every transformation is a reproducible, auditable query rather than a manual spreadsheet edit. Key issues handled:

                   Issue	                                                                    Fix
Import Wizard silently dropped/hung on large files	    Switched to LOAD DATA LOCAL INFILE for all bulk loads
local_infile disabled (Error 3948)	                    Enabled on both server (SET GLOBAL local_infile=1) and client (Workbench Advanced settings)
38 duplicate order_id rows (Error 1062)                	Verified as exact duplicates via Excel COUNTIF, then let the PRIMARY KEY constraint reject them
199 blank unit_price values (Error 1366)	              Converted to NULL using NULLIF() during load, instead of letting MySQL silently default them to 0 (which                                                           would have understated revenue/profit)
Inconsistent category casing 
(Kitchen / kitchen / KITCHEN)                           Standardized to Title Case during load using TRIM, UPPER, LOWER
product_name truncation (Error 1265)	                  Increased VARCHAR length after diagnosing the warning

Full detail in sql/02_load_data.sql and sql/03_foreign_keys.sql.

📈 Key Insights
Pareto pattern: Just 25% of customers (loyal, 5+ orders) generate 65% of total revenue, while one-time buyers (35.6% of customers) generate only ~8%.
Revenue ≠ profit: Furniture leads in total revenue ($325K), but Storage has the highest profit margin (56.5%) despite lower revenue — category rankings shift once cost is factored in.
Seasonality: November is the peak revenue month in both 2024 and 2025, ~40-50% above surrounding months.
Counter-intuitive discount finding: Orders with a discount code had a lower average order value ($128) than orders without one ($136) — suggesting the current discount strategy isn't driving larger baskets.
Payment concentration: Credit card accounts for 57% of revenue, more than double all other payment methods combined.
Cross-tool validation: A profit-margin discrepancy between SQL (NULL-safe) and Power BI/DAX (treats blank as 0) was traced to the 199 missing-price rows and corrected in the DAX measure to match SQL.

🖥️ Dashboard


The Power BI dashboard includes:
KPI cards (Total Revenue, Profit, Margin %, Orders, Customers, AOV, Return Rate, Repeat Customer %)
Monthly revenue trend (by year)
Revenue & profit by category
Top 10 products by revenue
Customer segmentation (revenue by loyalty tier)
Revenue by payment method
📁 Repo Structure
ecommerce-analytics-project/
│
├── README.md
├── data/
│   └── raw/
│       ├── customers.csv
│       ├── Raworders.csv
│       ├── Raworder_items.csv
│       └── Rawproducts.csv
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_load_data.sql
│   ├── 03_foreign_keys.sql
│   └── 04_analysis_queries.sql
└── dashboard/
    ├── ecommerce_dashboard.pbix
    └── dashboard_screenshot.png
    
🔍 How to Reproduce
Run sql/01_create_tables.sql to create the schema.
Update the file paths inside sql/02_load_data.sql to point to your local copy of the files in data/raw/.
Run sql/02_load_data.sql, then sql/03_foreign_keys.sql.
Run the queries in sql/04_analysis_queries.sql to reproduce the analysis.
Open dashboard/ecommerce_dashboard.pbix in Power BI Desktop and point the MySQL connection to your local instance.

👤 Author
Vanitha N GitHub · LinkedIn
