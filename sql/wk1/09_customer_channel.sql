-- Week 1: Customer acquisition channel profiling
-- Analysis cutoff: 2026-09-17

SELECT
  u.traffic_source,
  COUNT(DISTINCT oi.user_id) AS customers,
  COUNT(DISTINCT oi.order_id) AS orders,
  COUNT(*) AS order_items,
  ROUND(SUM(oi.sale_price), 2) AS sales_value,
  ROUND(
    100 * COUNT(DISTINCT oi.user_id)
    / SUM(COUNT(DISTINCT oi.user_id)) OVER(),
    2
  ) AS pct_customers
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.users` u
  ON oi.user_id = u.id
WHERE DATE(oi.created_at) <= DATE "2026-09-17"
GROUP BY u.traffic_source
ORDER BY customers DESC;


-- Return and cancellation rates by acquisition channel

SELECT
  u.traffic_source,
  COUNT(*) AS order_items,
  COUNTIF(oi.status = "Returned") AS returned_items,
  COUNTIF(oi.status = "Cancelled") AS cancelled_items,

  ROUND(
    100 * COUNTIF(oi.status = "Returned") / COUNT(*),
    2
  ) AS return_rate_pct,

  ROUND(
    100 * COUNTIF(oi.status = "Cancelled") / COUNT(*),
    2
  ) AS cancel_rate_pct,

  ROUND(
    100 * COUNTIF(
      oi.status IN ("Returned", "Cancelled")
    ) / COUNT(*),
    2
  ) AS leakage_item_rate_pct,

  ROUND(
    SUM(
      CASE
        WHEN oi.status IN ("Returned", "Cancelled")
        THEN oi.sale_price
        ELSE 0
      END
    ),
    2
  ) AS revenue_at_risk

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.users` u
  ON oi.user_id = u.id
WHERE DATE(oi.created_at) <= DATE "2026-09-17"
GROUP BY u.traffic_source
ORDER BY leakage_item_rate_pct DESC;
