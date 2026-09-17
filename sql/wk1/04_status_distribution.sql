-- Week 1: Order status and sales value distribution
-- Analysis cutoff: 2026-09-17

SELECT
  status,
  COUNT(*) AS order_items,
  COUNT(DISTINCT order_id) AS orders,
  ROUND(SUM(sale_price), 2) AS sales_value,
  ROUND(
    100 * COUNT(*) / SUM(COUNT(*)) OVER(),
    2
  ) AS pct_items
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE DATE(created_at) <= DATE "2026-09-17"
GROUP BY status
ORDER BY order_items DESC;

