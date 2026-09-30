# ECommerce Analytics Project
# 01_create_tables
# Purpose: Create the 4 core tables before loading raw data

create database ecommerce_db;
use ecommerce_db;
create table customers(
customer_id int,
signup_date date,
state varchar(5),
acquisition_channel varchar(50)
);
create table orders(
order_id int primary key,
customer_id int,
order_date datetime,
status varchar(20),
payment_method varchar(30),
discount_code varchar(30),
shipping_fee decimal(6,2)
);
create table order_items(
order_id int,
product_id int,
quantity int,
unit_price decimal (10,2),
discount_amount decimal(10,2)
);
create table products(
product_id int primary key,
product_name varchar(60),
category varchar(60),
list_price decimal(10,2),
unit_cost decimal(10,2)
);
