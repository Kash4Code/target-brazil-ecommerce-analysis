
# Inspect datatypes of all columns in the customers table

SELECT *
FROM `TARGET_SQL.customers`
LIMIT 10;


# Find the earliest and latest order dates (order_purchase_timestamp)

SELECT 
  MIN(order_purchase_timestamp) AS earliest_order_date,
  MAX(order_purchase_timestamp) AS latest_order_date
FROM `TARGET_SQL.orders`;


# Count the distinct cities and states where customers placed orders during this period.

SELECT 
  c.customer_city,
  c.customer_state,
  COUNT(c.customer_state) AS order_count
FROM `TARGET_SQL.customers` c
JOIN `TARGET_SQL.orders` o ON c.customer_id = o.customer_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) BETWEEN 2016 AND 2018
AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 5
GROUP BY c.customer_state, c.customer_city
ORDER BY order_count DESC;


# Count how many unique customers (customer_unique_id) placed more than 1 order.

WITH customer_order_counts AS (
  SELECT 
    customer_unique_id,
    COUNT(customer_id) AS total_orders
  FROM `TARGET_SQL.customers` 
  GROUP BY customer_unique_id
  HAVING total_orders > 1  
)
SELECT 
  COUNT(*) AS repeat_customers_count
FROM customer_order_counts



