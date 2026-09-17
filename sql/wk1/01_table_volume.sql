-- Week 1: Source table volume profiling
-- Dataset: bigquery-public-data.thelook_ecommerce

SELECT "events" AS table_name, COUNT(*) AS row_count
FROM `bigquery-public-data.thelook_ecommerce.events`

UNION ALL

SELECT "inventory_items", COUNT(*)
FROM `bigquery-public-data.thelook_ecommerce.inventory_items`

UNION ALL

SELECT "order_items", COUNT(*)
FROM `bigquery-public-data.thelook_ecommerce.order_items`

UNION ALL

SELECT "orders", COUNT(*)
FROM `bigquery-public-data.thelook_ecommerce.orders`

UNION ALL

SELECT "users", COUNT(*)
FROM `bigquery-public-data.thelook_ecommerce.users`

UNION ALL

SELECT "products", COUNT(*)
FROM `bigquery-public-data.thelook_ecommerce.products`

UNION ALL

SELECT "distribution_centers", COUNT(*)
FROM `bigquery-public-data.thelook_ecommerce.distribution_centers`

ORDER BY row_count DESC;

