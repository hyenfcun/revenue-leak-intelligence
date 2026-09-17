-- Week 1: Future-dated order item validation
-- Analysis cutoff: 2026-09-17

SELECT
  COUNT(*) AS future_rows,
  COUNT(DISTINCT order_id) AS future_orders,
  MIN(DATE(created_at)) AS first_future_date,
  MAX(DATE(created_at)) AS last_future_date,
  ROUND(
    100 * COUNT(*) /
    (SELECT COUNT(*)
     FROM `bigquery-public-data.thelook_ecommerce.order_items`),
    2
  ) AS pct_of_dataset
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE DATE(created_at) > DATE "2026-09-17";

