-- Week 1: Order item timeline and population profile

SELECT
  MIN(created_at) AS earliest_order_item,
  MAX(created_at) AS latest_order_item,
  MIN(DATE(created_at)) AS earliest_date,
  MAX(DATE(created_at)) AS latest_date,
  COUNT(*) AS total_order_items,
  COUNT(DISTINCT order_id) AS unique_orders,
  COUNT(DISTINCT user_id) AS unique_customers
FROM `bigquery-public-data.thelook_ecommerce.order_items`;

