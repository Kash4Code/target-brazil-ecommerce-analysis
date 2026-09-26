# Target Brazil E-Commerce Analysis

## Business Question
Where do regional demand concentration, delivery performance, payment behavior, and seller concentration create operational risk or growth opportunity for Target's e-commerce marketplace in Brazil?


## Dataset

* **Source:** Target Brazil e-commerce dataset — 7 relational tables (`customers`, `orders`, `order_items`, `payments`, `order_reviews`, `products`, `sellers`)
* **Timeframe:** 2016–2018
* **Description:** Order-level and line-item transaction data including customer geography, full order lifecycle timestamps, payment methods and installment counts, review scores, product categories, and seller registration details.

**Table sizes:**

| Table | Records |
|---|---|
| `orders` | 99,441 |
| `customers` | 99,441 |
| `order_items` | 112,650 |
| `payments` | 103,886 |
| `order_reviews` | 99,224 |
| `products` | 32,951 |
| `sellers` | 3,096 |

> **Note:** `order_items` and `payments` exceed `orders` because a single order can contain multiple line items and, in some cases, multiple payment transactions (e.g. part credit card, part voucher).


## Tools Used
- SQL (Google BigQuery, Standard SQL) — querying and joining across 7 relational tables
- SQL window functions (NTILE, ROW_NUMBER, LAG) — seller revenue concentration and trend analysis
- SQL CTEs, subqueries, conditional aggregation, date/time arithmetic — delivery SLA and cohort calculations


## Key Findings
1. **Customer demand is heavily concentrated in São Paulo** — SP accounts for ~41.98% of total customers, more than triple Rio de Janeiro (12.92%), reinforcing why fulfillment infrastructure is concentrated in the southeast.
   
   <img src="screenshots/01_customer_distribution.png" alt="Customer Distribution" width="550">
   
2. **Late deliveries sharply damage customer satisfaction** — average review rating drops from 4.29 stars (on-time/early orders) to 2.27 stars (delayed orders), a ~47% decline.

   <img src="screenshots/02_delivery_vs_reviews.png" width="450">
   
3. **Marketplace revenue is highly dependent on a small seller cohort** — using `NTILE(100)`, the top 5% of sellers generate 53% of total marketplace revenue, creating meaningful platform risk if any churn.

   <img src="screenshots/06_seller_concentration.png" width="500">
   
4. **Nearly half of transactions rely on financing at checkout** — 48%+ of orders use multi-installment payment plans (2-10+ months), indicating price sensitivity and financing dependence among buyers.

   <img src="screenshots/04_payment_installments.png" width="450">


## Interactive Dashboard (Tableau Public)

To make these findings accessible to non-technical stakeholders, I built a 2-page interactive dashboard in Tableau, structured directly around the project's core business question: where do regional demand concentration, delivery performance, payment behavior, and seller concentration create operational risk or growth opportunity for the marketplace?

**[View the Live Dashboard on Tableau Public →](https://public.tableau.com/app/profile/kashinath.r.p/viz/TargetBrazilWhereDemandDeliverySellerRiskMeetOpportunity/DemandDeliveryOverview)**

### Design Approach
- **Page 1 – Demand & Delivery Risk:** State-level order concentration, delivery status breakdown, and the delivery-to-satisfaction link (average review score drops from 4.29 to 1.75 stars when an order isn't delivered on time).
- **Page 2 – Payment & Seller Risk/Opportunity:** Installment financing behavior, seller revenue concentration (top 5% of sellers generate 53% of total revenue), and category saturation vs. underserved white space.
- **Executive-First Layout:** Each page opens with a plain-language headline and key insights so a non-technical viewer gets the "so what" before reading a single chart.
- **Consistent Visual Hierarchy:** A consistent color system runs through both pages (**red = risk, green = opportunity, grey = neutral/baseline**) so meaning doesn't need to be re-learned from chart to chart.
- **Data Integrity via Dedicated Views:** Built on three grain-specific BigQuery views (`v_order_level`, `v_payment_level`, `v_item_level`) rather than a single flattened join, avoiding double-counting from the dataset's one-to-many order/payment/item relationships (see `queries/` for view definitions).

  
## Recommendations
- **Build secondary logistics hubs or local 3PL partnerships** in the north/northeast to close the delivery-speed and freight-cost gap with the southeast.
- **Implement proactive delay alerts** so customers are notified before an SLA is missed, reducing the review-score damage caused by late fulfillment.
- **Create a top-seller retention program** (dedicated account support, fee incentives) for the top 5% of sellers responsible for over half of platform revenue, given the concentration risk they represent.


## Files
- `data/` — raw relational CSVs (customers, orders, order_items, payments, order_reviews, products, sellers)
- `queries/01_exploratory_data_analysis.sql` through `06_product_and_seller_analytics.sql` — categorized analysis scripts
- `screenshots/` — BigQuery query output visuals referenced above
- `erd.png` — entity relationship diagram of the 7-table schema


## Methodology
All 7 tables were ingested into Google BigQuery and joined using a combination of CTEs, subqueries, and conditional aggregation to answer questions spanning four areas: regional distribution, delivery performance, payment behavior, and seller concentration. Delivery performance was assessed by comparing actual delivery timestamps against estimated delivery dates to flag late orders, then joining that flag against review scores to quantify the satisfaction impact. Seller concentration was measured using the `NTILE(100)` window function to bucket sellers into revenue percentiles, isolating how much of total marketplace revenue depends on the top tier.

**Limitations:** The dataset covers 2016-2018 only, so findings reflect historical marketplace conditions rather than current performance. The relationship between delivery delay and review score is a correlation, not a controlled causal test — other factors (product quality, packaging, customer service) also influence ratings and weren't isolated here. Seller concentration is measured by revenue only; it doesn't account for margin, so the highest-revenue sellers aren't necessarily the most profitable ones to retain.
