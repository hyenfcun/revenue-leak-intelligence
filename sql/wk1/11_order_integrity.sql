-- Week 1: Order-to-order-item integrity validation
-- Analysis cutoff: 2026-09-17

WITH item_summary AS (
  SELECT
    order_id,
    COUNT(*) AS actual_item_count,
    COUNT(DISTINCT status) AS distinct_item_statuses,
    ANY_VALUE(status) AS item_status
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE DATE(created_at) <= DATE "2026-09-17"
  GROUP BY order_id
)

SELECT
  COUNT(*) AS total_orders,
  COUNTIF(i.order_id IS NULL) AS orders_without_items,
  COUNTIF(o.num_of_item != i.actual_item_count) AS item_count_mismatches,
  COUNTIF(i.distinct_item_statuses > 1) AS orders_with_mixed_item_statuses,
  COUNTIF(o.status != i.item_status) AS order_status_mismatches
FROM `bigquery-public-data.thelook_ecommerce.orders` o
LEFT JOIN item_summary i
  ON o.order_id = i.order_id
WHERE DATE(o.created_at) <= DATE "2026-09-17";


-- Explain cutoff-driven mismatches

WITH item_summary AS (
  SELECT
    order_id,
    COUNT(*) AS all_item_count,
    COUNTIF(DATE(created_at) <= DATE "2026-09-17") AS cutoff_item_count,
    COUNTIF(DATE(created_at) > DATE "2026-09-17") AS future_item_count
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  GROUP BY order_id
)

SELECT
  COUNT(*) AS orders_checked,

  COUNTIF(i.all_item_count = o.num_of_item)
    AS matches_using_all_items,

  COUNTIF(i.all_item_count != o.num_of_item)
    AS mismatches_using_all_items,

  COUNTIF(i.future_item_count > 0)
    AS orders_with_future_items,

  SUM(i.future_item_count)
    AS total_future_items,

  COUNTIF(
    i.cutoff_item_count != o.num_of_item
    AND i.all_item_count = o.num_of_item
  ) AS mismatches_explained_by_cutoff

FROM `bigquery-public-data.thelook_ecommerce.orders` o
LEFT JOIN item_summary i
  ON o.order_id = i.order_id
WHERE DATE(o.created_at) <= DATE "2026-09-17";

