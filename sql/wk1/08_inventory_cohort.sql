-- Week 1: Inventory cohort sell-through analysis
-- Analysis cutoff: 2026-09-17

SELECT
  EXTRACT(YEAR FROM created_at) AS inventory_created_year,

  COUNT(*) AS inventory_items,

  COUNTIF(
    sold_at IS NOT NULL
    AND DATE(sold_at) <= DATE "2026-09-17"
  ) AS sold_items,

  COUNTIF(
    sold_at IS NULL
    OR DATE(sold_at) > DATE "2026-09-17"
  ) AS unsold_items,

  ROUND(
    100 * COUNTIF(
      sold_at IS NOT NULL
      AND DATE(sold_at) <= DATE "2026-09-17"
    ) / COUNT(*),
    2
  ) AS sell_through_pct,

  ROUND(
    SUM(
      CASE
        WHEN sold_at IS NULL
          OR DATE(sold_at) > DATE "2026-09-17"
        THEN cost
        ELSE 0
      END
    ),
    2
  ) AS unsold_cost

FROM `bigquery-public-data.thelook_ecommerce.inventory_items`

WHERE DATE(created_at) <= DATE "2026-09-17"

GROUP BY inventory_created_year
ORDER BY inventory_created_year;

