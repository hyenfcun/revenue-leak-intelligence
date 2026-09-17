-- Week 1: Customer join coverage validation
-- Analysis cutoff: 2026-09-17

SELECT
  COUNT(*) AS valid_order_items,
  COUNTIF(u.id IS NOT NULL) AS matched_customer_rows,
  COUNTIF(u.id IS NULL) AS unmatched_customer_rows,

  ROUND(
    100 * COUNTIF(u.id IS NOT NULL) / COUNT(*),
    2
  ) AS customer_match_rate_pct,

  COUNT(DISTINCT oi.user_id) AS ordering_customers,
  COUNT(DISTINCT u.id) AS matched_unique_customers

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi

LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` u
  ON oi.user_id = u.id

WHERE DATE(oi.created_at) <= DATE "2026-09-17";

