-- Week 1: Inventory aging and working-capital assessment
-- Analysis cutoff: 2026-09-17

WITH inventory_age AS (
  SELECT
    id,
    product_category,
    cost,
    TIMESTAMP_DIFF(
      TIMESTAMP("2026-09-17"),
      created_at,
      DAY
    ) AS age_days
  FROM `bigquery-public-data.thelook_ecommerce.inventory_items`
  WHERE DATE(created_at) <= DATE "2026-09-17"
    AND (
      sold_at IS NULL
      OR DATE(sold_at) > DATE "2026-09-17"
    )
)

SELECT
  CASE
    WHEN age_days <= 30 THEN "0-30 days"
    WHEN age_days <= 60 THEN "31-60 days"
    WHEN age_days <= 90 THEN "61-90 days"
    WHEN age_days <= 180 THEN "91-180 days"
    WHEN age_days <= 365 THEN "181-365 days"
    ELSE "365+ days"
  END AS aging_bucket,
  COUNT(*) AS inventory_items,
  ROUND(SUM(cost), 2) AS inventory_cost,
  ROUND(AVG(age_days), 1) AS avg_age_days,
  ROUND(
    100 * COUNT(*) / SUM(COUNT(*)) OVER(),
    2
  ) AS pct_unsold_items
FROM inventory_age
GROUP BY aging_bucket
ORDER BY
  CASE aging_bucket
    WHEN "0-30 days" THEN 1
    WHEN "31-60 days" THEN 2
    WHEN "61-90 days" THEN 3
    WHEN "91-180 days" THEN 4
    WHEN "181-365 days" THEN 5
    ELSE 6
  END;


-- Category-level normalization for 365+ day inventory

WITH inventory_status AS (
  SELECT
    product_category,
    cost,
    TIMESTAMP_DIFF(
      TIMESTAMP("2026-09-17"),
      created_at,
      DAY
    ) AS age_days
  FROM `bigquery-public-data.thelook_ecommerce.inventory_items`
  WHERE DATE(created_at) <= DATE "2026-09-17"
    AND (
      sold_at IS NULL
      OR DATE(sold_at) > DATE "2026-09-17"
    )
)

SELECT
  product_category,
  COUNT(*) AS total_unsold_items,
  COUNTIF(age_days > 365) AS aged_365_plus_items,
  ROUND(
    100 * COUNTIF(age_days > 365) / COUNT(*),
    2
  ) AS aged_365_plus_pct,
  ROUND(SUM(cost), 2) AS total_unsold_cost,
  ROUND(
    SUM(CASE WHEN age_days > 365 THEN cost ELSE 0 END),
    2
  ) AS aged_365_plus_cost,
  ROUND(
    100 *
    SUM(CASE WHEN age_days > 365 THEN cost ELSE 0 END)
    / SUM(cost),
    2
  ) AS aged_cost_pct
FROM inventory_status
GROUP BY product_category
ORDER BY aged_cost_pct DESC;

