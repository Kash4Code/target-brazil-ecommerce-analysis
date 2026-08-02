
# Determine if there is a growing trend in the total number of orders placed year over year

# There is a growth from 2016 to 2017 and then the number of orders fall from 2017 to 2018. This is because of we are missing some months in 2016 and 2018

WITH yearly_orders AS (
  SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    COUNT(order_id) AS total_orders
  FROM `TARGET_SQL.orders`
  GROUP BY year
)
SELECT 
  year,
  total_orders,
  LAG(total_orders) OVER (ORDER BY year) as prev_year_orders,
  -- Calculate YoY percentage growth
  ROUND(
    (total_orders - LAG(total_orders) OVER (ORDER BY year)) / LAG(total_orders) OVER (ORDER BY year) * 100, 
    2
  ) AS yoy_growth_percent
FROM yearly_orders
ORDER BY year;


# Measure month-on-month order volumes across different years.

# August, May and July are having the highest order volumes

SELECT 
  EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
  COUNT(order_id) AS total_orders
FROM `TARGET_SQL.orders`
GROUP BY month
ORDER BY total_orders DESC;


# Categorize order purchases into Dawn (0-6h), Morning (7-12h), Afternoon (13-18h), and Night (19-23h)

# Brazilians order at afternoons and nights the most

WITH order_details AS (
  SELECT 
    EXTRACT(hour FROM order_purchase_timestamp) AS hour,
    order_id
  FROM `TARGET_SQL.orders`
)
SELECT
  CASE 
    WHEN hour BETWEEN 0 AND 6 THEN 'Dawn'
    WHEN hour BETWEEN 7 AND 12 THEN 'Morning'
    WHEN hour BETWEEN 13 AND 18 THEN 'Afternoon'
    WHEN hour BETWEEN 19 AND 23 THEN 'Night'
  END AS time_of_day,
  COUNT(order_id) AS total_orders
FROM order_details
GROUP BY time_of_day
ORDER BY total_orders DESC;





