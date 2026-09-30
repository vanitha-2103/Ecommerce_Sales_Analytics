# E-Commerce Analytics Project
# _foreign_keys
-- Purpose: Link the 4 tables into a proper relational model
USE ecommerce_db;

-- customers.customer_id already has a PRIMARY KEY (set in 01_create_tables.sql)
-- orders.order_id already has a PRIMARY KEY
-- products.product_id already has a PRIMARY KEY

# Link orders -> customers
ALTER TABLE orders ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

# Link order_items -> orders
ALTER TABLE order_items ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);

#  Link order_items -> products
ALTER TABLE order_items ADD FOREIGN KEY (product_id) REFERENCES products(product_id);

-- NOTE: order_items has no single-column PRIMARY KEY, since
-- product_id repeats across many orders (multiple customers can
-- order the same product) and order_id repeats across multiple
-- line items in the same order. A composite key of
-- (order_id, product_id) or a surrogate auto-increment key
-- would be the correct design for a production system.

# VERIFICATION: confirm no orphan records exist

-- Orders with no matching customer
select distinct o.customer_id
from orders o
left join customers c
on o.customer_id = c.customer_id
where c.customer_id is null;
-- Order_items with no matching order
select distinct oi.order_id
from order_items oi
left join orders o
on oi.order_id = o.order_id
where o.order_id is Null;
-- Order_items with no matching product
select oi.product_id
from order_items oi
left join products p
on oi.product_id = p.product_id
where p.product_id is null;


