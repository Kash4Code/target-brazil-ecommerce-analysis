
# Get month-on-month order counts categorized by payment type (credit_card, boleto, voucher, debit_card)

# Credit Card and UPI are being the most used payment method (nearly ~75% of order volume)

SELECT 
  p.payment_type,
  EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
  EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM `TARGET_SQL.orders` o
JOIN `TARGET_SQL.payments` p ON o.order_id = p.order_id
GROUP BY year, month, p.payment_type
ORDER BY year, month, total_orders;


# Calculate total orders placed broken down by the number of payment installments

# 49,060 orders (i.e 50%+ of orders) were paid in 1 single installment. Around 48% of orders were paid in multiple installments (mostly between 2 to 10)

SELECT 
  p.payment_installments,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM `TARGET_SQL.payments` p
JOIN `TARGET_SQL.orders` o ON p.order_id = o.order_id
GROUP BY payment_installments
ORDER BY payment_installments;






