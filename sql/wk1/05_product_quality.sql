-- Week 1: Product cost and retail price quality checks

SELECT
  COUNT(*) AS total_products,
  COUNTIF(cost IS NULL) AS null_cost,
  COUNTIF(cost <= 0) AS non_positive_cost,
  COUNTIF(retail_price IS NULL) AS null_retail_price,
  COUNTIF(retail_price <= 0) AS non_positive_retail_price,
  ROUND(MIN(cost), 2) AS min_cost,
  ROUND(MAX(cost), 2) AS max_cost,
  ROUND(AVG(cost), 2) AS avg_cost,
  ROUND(MIN(retail_price), 2) AS min_retail_price,
  ROUND(MAX(retail_price), 2) AS max_retail_price,
  ROUND(AVG(retail_price), 2) AS avg_retail_price
FROM `bigquery-public-data.thelook_ecommerce.products`;

-- Catalog margin validation

SELECT
  COUNT(*) AS total_products,
  COUNTIF(cost > retail_price) AS cost_above_retail,
  COUNTIF(cost = retail_price) AS cost_equals_retail,
  ROUND(
    100 * COUNTIF(cost > retail_price) / COUNT(*),
    2
  ) AS pct_cost_above_retail,
  ROUND(MIN(retail_price - cost), 2) AS min_unit_margin,
  ROUND(MAX(retail_price - cost), 2) AS max_unit_margin,
  ROUND(AVG(retail_price - cost), 2) AS avg_unit_margin
FROM `bigquery-public-data.thelook_ecommerce.products`;

