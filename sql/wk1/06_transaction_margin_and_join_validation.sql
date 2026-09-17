-- Week 1: Actual transaction margin validation
-- Analysis cutoff: 2026-09-17

SELECT
  COUNT(*) AS total_order_items,
  COUNTIF(oi.sale_price IS NULL) AS null_sale_price,
  COUNTIF(oi.sale_price <= 0) AS non_positive_sale_price,
  COUNTIF(oi.sale_price < p.cost) AS sold_below_cost,
  COUNTIF(oi.sale_price = p.cost) AS sold_at_cost,
  ROUND(
    100 * COUNTIF(oi.sale_price < p.cost) / COUNT(*),
    2
  ) AS pct_sold_below_cost,
  ROUND(MIN(oi.sale_price - p.cost), 2) AS min_actual_margin,
  ROUND(MAX(oi.sale_price - p.cost), 2) AS max_actual_margin,
  ROUND(AVG(oi.sale_price - p.cost), 2) AS avg_actual_margin
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
WHERE DATE(oi.created_at) <= DATE "2026-09-17";


-- Order items -> products join coverage

SELECT
  COUNT(*) AS total_order_items,
  COUNTIF(p.id IS NOT NULL) AS matched_order_items,
  COUNTIF(p.id IS NULL) AS unmatched_order_items,
  ROUND(
    100 * COUNTIF(p.id IS NOT NULL) / COUNT(*),
    2
  ) AS match_rate_pct
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
WHERE DATE(oi.created_at) <= DATE "2026-09-17";

