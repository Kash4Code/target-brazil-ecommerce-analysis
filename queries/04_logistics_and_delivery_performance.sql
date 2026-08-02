
# Calculate time_to_deliver (actual delivery - purchase date) and diff_estimated_delivery (actual delivery - estimated delivery date) in a single query

SELECT 
  order_id,
  DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY) AS days_to_deliver,
  DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) AS diff_estimated_delivery,
  CASE 
    WHEN order_delivered_customer_date IS NULL THEN 'Not Delivered / In-Transit'
    WHEN DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) < 0 THEN 'Early delivery'
    WHEN DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) = 0 THEN 'On-Time'
    ELSE 'Late Delivery'
  END AS delivery_status
FROM `TARGET_SQL.orders`;


# Calculate the percentage of orders based on delivery status

# Around ~90% orders has been delivered either early or on-time

WITH delivery_details AS (
  SELECT 
    order_id,
    DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY) AS days_to_deliver,
    DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) AS diff_estimated_delivery,
    CASE 
      WHEN order_delivered_customer_date IS NULL THEN 'Not Delivered / In-Transit'
      WHEN DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) < 0 THEN 'Early delivery'
      WHEN DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) = 0 THEN 'On-Time'
      ELSE 'Late Delivery'
    END AS delivery_status
  FROM `TARGET_SQL.orders` 
)
SELECT 
  delivery_status,
  COUNT(order_id) AS total_orders,
  ROUND(COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER(), 2) AS percentage
FROM delivery_details
GROUP BY delivery_status
ORDER BY total_orders DESC;


# Identify top 5 highest and top 5 lowest average freight value states

WITH state_avg_freight AS (
  SELECT 
    c.customer_state,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight
  FROM `TARGET_SQL.order_items` oi
  JOIN `TARGET_SQL.orders` o ON oi.order_id = o.order_id 
  JOIN `TARGET_SQL.customers` c ON o.customer_id = c.customer_id
  GROUP BY c.customer_state 
),
highest_5 AS (
  SELECT 
    customer_state AS high_state,
    avg_freight AS high_avg_freight,
    ROW_NUMBER() OVER (ORDER BY avg_freight DESC) AS rn
  FROM state_avg_freight
  LIMIT 5
),
lowest_5 AS (
  SELECT 
    customer_state AS low_state,
    avg_freight AS low_avg_freight,
    ROW_NUMBER() OVER (ORDER BY avg_freight ASC) AS rn
  FROM state_avg_freight
  LIMIT 5
)
SELECT
  h.high_state,
  h.high_avg_freight,
  l.low_state,
  l.low_avg_freight
FROM highest_5 h
JOIN lowest_5 l ON h.rn = l.rn
ORDER BY h.rn;


# Identify top 5 fastest and top 5 slowest average delivery time states

WITH state_avg_delivery AS (
  SELECT 
    c.customer_state,
    AVG(EXTRACT(DATE FROM o.order_delivered_customer_date) - EXTRACT(DATE FROM o.order_purchase_timestamp)) AS avg_delivery_time
  FROM `TARGET_SQL.order_items` oi
  JOIN `TARGET_SQL.orders` o ON oi.order_id = o.order_id 
  JOIN `TARGET_SQL.customers` c ON o.customer_id = c.customer_id
  GROUP BY c.customer_state  
),
fastest_5 AS (
  SELECT 
    customer_state AS fast_state,
    avg_delivery_time AS fast_avg_delivery_time,
    ROW_NUMBER() OVER (ORDER BY avg_delivery_time ASC) AS rn
  FROM state_avg_delivery
  LIMIT 5
),
slowest_5 AS (
  SELECT 
    customer_state AS slow_state,
    avg_delivery_time AS slow_avg_delivery_time,
    ROW_NUMBER() OVER (ORDER BY avg_delivery_time DESC) AS rn
  FROM state_avg_delivery
  LIMIT 5
)
SELECT 
  f.fast_state,
  f.fast_avg_delivery_time,
  s.slow_state,
  s.slow_avg_delivery_time
FROM fastest_5 f
JOIN slowest_5 s ON f.rn = s.rn 
ORDER BY f.rn;


# Identify top 5 states where actual delivery was fastest relative to estimated delivery date

SELECT 
  c.customer_state,
  -- Calculate average difference in days
  ROUND(AVG(DATE_DIFF(DATE(o.order_delivered_customer_date), DATE(o.order_estimated_delivery_date), DAY)), 2) AS avg_diff_in_days
FROM `TARGET_SQL.order_items` oi
JOIN `TARGET_SQL.orders` o ON oi.order_id = o.order_id 
JOIN `TARGET_SQL.customers` c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
-- Which ORDER BY direction gets the most negative numbers (fastest relative delivery)?
ORDER BY avg_diff_in_days ASC
LIMIT 5;


# Compare average review scores for on-time orders versus delayed orders (actual delivery > estimated delivery) 

# We can see a average rating drop from 4.29 to 2.27 when an order shifts from on-time to delayed delivery status

WITH delivery_performance AS (
  SELECT 
    o.order_id,
    r.review_score,
    CASE WHEN DATE(o.order_delivered_customer_date) > DATE(o.order_estimated_delivery_date) THEN 'Delayed'
        ELSE 'On-Time / Early'
    END AS delivery_performance_status
  FROM `TARGET_SQL.order_reviews` r
  JOIN `TARGET_SQL.orders` o ON r.order_id = o.order_id
  WHERE o.order_delivered_customer_date IS NOT NULL  
)
SELECT 
  delivery_performance_status,
  COUNT(DISTINCT order_id) AS total_orders,
  ROUND(AVG(review_score), 2) AS avg_review_score
FROM delivery_performance
GROUP BY delivery_performance_status;

