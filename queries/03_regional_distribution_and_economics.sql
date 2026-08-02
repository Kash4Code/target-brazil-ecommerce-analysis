
# Calculate month-on-month order counts grouped by customer state.

SELECT 
  c.customer_state,
  EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
  EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
  COUNT(o.order_id) AS total_orders
FROM `TARGET_SQL.orders` o
JOIN `TARGET_SQL.customers` c ON o.customer_id = c.customer_id
GROUP BY c.customer_state, year, month
ORDER BY c.customer_state, year, month;


# Determine customer volume distribution and percentages across all 27 Brazilian states.

# Observation - Sao Paolo accounts for over 41% of total customers which implies supply chain hubs are built nearby mainly in south-eastern Brazil

SELECT
  customer_state,
  COUNT(customer_id) AS total_customers,
  -- Calculate percentage distribution
  ROUND(
    COUNT(customer_id) * 100.0 / SUM(COUNT(customer_id)) OVER(), 2
  ) AS customer_percentage
FROM `TARGET_SQL.customers`
GROUP BY customer_state
ORDER BY total_customers DESC;


# Calculate percentage increase in total order cost (payment_value) from 2017 to 2018 for Jan–Aug.

# Observation - Year Over Year Revenue Growth from 2017 to 2018 (Jan to Aug) is 136.98%  

WITH yearly_totals AS (
  SELECT 
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    SUM(p.payment_value) AS total_payment
  FROM `TARGET_SQL.payments` p
  JOIN `TARGET_SQL.orders` o ON p.order_id = o.order_id
  WHERE (EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)) AND (EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8)
  GROUP BY year
),
yearly_comparisons AS (
  SELECT 
    year,
    total_payment,
    LEAD(total_payment) OVER (ORDER BY year DESC) AS prev_year_payment
  FROM yearly_totals  
)
SELECT 
  ROUND((total_payment - prev_year_payment) * 100 / prev_year_payment, 2) AS percent_growth
FROM yearly_comparisons;


# Calculate Total and Average order price & order freight per state

# Sao Paolo has the least average order price and average freight value implying the reason why it has the most number of orders placed and is also the primary revenue engine. 

SELECT 
  c.customer_state,
  ROUND(SUM(oi.price), 2) AS total_price,
  ROUND(AVG(oi.price), 2) AS avg_price,
  ROUND(SUM(oi.freight_value), 2) AS total_freight,
  ROUND(AVG(oi.freight_value), 2) AS avg_freight
FROM `TARGET_SQL.order_items` oi
JOIN `TARGET_SQL.orders` o ON oi.order_id = o.order_id
JOIN `TARGET_SQL.customers` c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_price DESC;


