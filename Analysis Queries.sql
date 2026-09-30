# E-Commerce Analytics Project
# 04_analysis_queries
-- Purpose: Business analysis queries -- each answers one
--         business question, with the key insight noted.


#Q1: Overall Business Snapshot
select
count(distinct o. order_id) as total_completed_orders,
count(distinct o.customer_id) as total_customer,
round(sum(oi.quantity * oi.unit_price), 2) as total_revenue
from orders o
join order_items oi
on o.order_id = oi.order_id
where o.status ='Completed';
-- Result: 8,456 orders | 2,047 customers | $1,902,680.50 revenue

SELECT ROUND(1902680.50 / 8456, 2) AS avg_order_value;
SELECT ROUND(8456 / 2047, 2) AS avg_orders_per_customer;

# Q2: Revenue and order count by product category
select 
p.category,
round(sum(oi.quantity * oi.unit_price), 2) as revenue,
count(distinct oi.order_id) as orders_count
from order_items oi
join products p
on oi.product_id = p.product_id
join orders o
on oi.order_id = o.order_id
where o.status = 'Completed'
group by p.category
order by revenue desc;
-- Insight: Furniture leads revenue ($325K) despite far fewer orders
-- than Kitchen/Decor -- a high-value, low-volume category.

# Q3: Average order value by category
SELECT 
  p.category,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue,
  COUNT(DISTINCT oi.order_id) AS orders_count,
  ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT oi.order_id), 2) AS avg_value_per_order
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY avg_value_per_order DESC;
-- Insight: Furniture's AOV (~$379) is over 5x Bath's (~$74) --
-- confirms Furniture as a premium, low-frequency category.

# Q4: Profit margin by category (uses unit_cost)
SELECT 
  p.category,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue,
  ROUND(SUM(oi.quantity * p.unit_cost), 2) AS total_cost,
  ROUND(SUM(oi.quantity * (oi.unit_price - p.unit_cost)), 2) AS profit,
  ROUND(SUM(oi.quantity * (oi.unit_price - p.unit_cost)) * 100.0 / SUM(oi.quantity * oi.unit_price), 2) AS profit_margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY profit DESC;
-- Insight: Revenue rank and profit rank don't fully align --
-- Kitchen (#2 revenue) drops to #3 profit; Decor moves up to #2.
-- Storage has the highest margin overall (56.55%) despite lower revenue.

# Q5: Order status breakdown
select 
status,
count(*) as order_count,
round(count(*) * 100.0/(select count(*) from orders),2) as percentage
from orders
group by status;
-- Result: 91.84% completed | 4.42% returned | 3.74% cancelled

# Q6: Monthly revenue trend
select 
date_format(o.order_date, '%y-%m') as month,
round(sum(oi.quantity * oi.unit_price), 2) as revenue
from orders o
join order_items oi
on o.order_id = oi.order_id
where o.status = 'completed'
group by month
order by month;
-- Insight: November is consistently the peak month in both years
-- (2024 and 2025), likely tied to holiday season shopping.

# Q7: Customer segmentation by purchase frequency
SELECT 
  purchase_frequency,
  COUNT(*) AS customer_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM orders WHERE status='completed'), 2) AS percentage
FROM (
  SELECT 
    customer_id,
    CASE 
      WHEN COUNT(order_id) = 1 THEN 'One-time buyer'
      WHEN COUNT(order_id) BETWEEN 2 AND 4 THEN 'Repeat buyer (2-4 orders)'
      ELSE 'Loyal buyer (5+ orders)'
    END AS purchase_frequency
  FROM orders
  WHERE status = 'completed'
  GROUP BY customer_id
) t
GROUP BY purchase_frequency
ORDER BY customer_count DESC;

# Q8: Revenue contribution by customer segment (Pareto check)
SELECT 
  purchase_frequency,
  COUNT(*) AS customer_count,
  ROUND(SUM(total_spent), 2) AS total_revenue,
  ROUND(SUM(total_spent) * 100.0 / SUM(SUM(total_spent)) OVER(), 2) AS revenue_percentage
FROM (
  SELECT 
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.quantity * oi.unit_price) AS total_spent,
    CASE 
      WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One-time buyer'
      WHEN COUNT(DISTINCT o.order_id) BETWEEN 2 AND 4 THEN 'Repeat buyer (2-4 orders)'
      ELSE 'Loyal buyer (5+ orders)'
    END AS purchase_frequency
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.status = 'completed'
  GROUP BY o.customer_id
) t
GROUP BY purchase_frequency
ORDER BY total_revenue DESC;
-- KEY INSIGHT: Just 25% of customers (loyal, 5+ orders) generate
-- 65% of total revenue -- a classic Pareto (80/20-style) pattern.
-- One-time buyers (35.6% of customers) generate only ~8% of revenue.

# Q9: Top 10 products by revenue
SELECT 
  p.product_name,
  p.category,
  SUM(oi.quantity) AS units_sold,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
JOIN orders o 
ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;

# Q10: Revenue by payment method
SELECT 
  payment_method,
  COUNT(*) AS orders_count,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY payment_method
ORDER BY revenue DESC;
-- Insight: Credit card drives 57.2% of revenue -- more than double
-- all other payment methods combined.

# Q11: Discount code Impact
SELECT 
  CASE 
    WHEN discount_code IS NULL OR TRIM(discount_code) = '' THEN 'No Discount' 
    ELSE 'With Discount' 
  END AS discount_used,
  COUNT(DISTINCT o.order_id) AS orders_count,
  ROUND(AVG(oi.quantity * oi.unit_price), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY discount_used;
-- COUNTER-INTUITIVE INSIGHT: orders WITH a discount code had a
-- LOWER average order value ($128.12) than orders WITHOUT one
-- ($136.07) -- suggesting the discount strategy isn't driving
-- larger basket sizes. Only 15.3% of orders used a discount code.

# Q12: Return rate by year
SELECT 
  YEAR(order_date) AS year,
  ROUND(COUNT(CASE WHEN status = 'returned' THEN 1 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM orders
GROUP BY YEAR(order_date);

 


 


 
