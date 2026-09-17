-- Week 1: Event identity validation and conversion funnel analysis
-- Analysis cutoff: 2026-09-17


-- Event type distribution and identity quality

SELECT
  event_type,
  COUNT(*) AS events,
  COUNTIF(user_id IS NULL) AS null_user_id,
  ROUND(
    100 * COUNTIF(user_id IS NULL) / COUNT(*),
    2
  ) AS null_user_pct,
  COUNTIF(session_id IS NULL) AS null_session_id,
  MIN(sequence_number) AS min_sequence,
  MAX(sequence_number) AS max_sequence,
  COUNT(DISTINCT session_id) AS distinct_sessions
FROM `bigquery-public-data.thelook_ecommerce.events`
WHERE DATE(created_at) <= DATE "2026-09-17"
GROUP BY event_type
ORDER BY events DESC;


-- Validate funnel ordering inside each session

WITH session_funnel AS (
  SELECT
    session_id,
    MIN(CASE WHEN event_type = "product" THEN sequence_number END) AS product_seq,
    MIN(CASE WHEN event_type = "cart" THEN sequence_number END) AS cart_seq,
    MIN(CASE WHEN event_type = "purchase" THEN sequence_number END) AS purchase_seq
  FROM `bigquery-public-data.thelook_ecommerce.events`
  WHERE DATE(created_at) <= DATE "2026-09-17"
  GROUP BY session_id
)

SELECT
  COUNT(*) AS total_sessions,
  COUNTIF(product_seq IS NOT NULL) AS product_sessions,
  COUNTIF(cart_seq IS NOT NULL) AS cart_sessions,
  COUNTIF(purchase_seq IS NOT NULL) AS purchase_sessions,

  COUNTIF(
    product_seq IS NOT NULL
    AND cart_seq IS NOT NULL
    AND product_seq < cart_seq
  ) AS product_to_cart_sessions,

  COUNTIF(
    cart_seq IS NOT NULL
    AND purchase_seq IS NOT NULL
    AND cart_seq < purchase_seq
  ) AS cart_to_purchase_sessions,

  COUNTIF(
    product_seq IS NOT NULL
    AND cart_seq IS NOT NULL
    AND purchase_seq IS NOT NULL
    AND product_seq < cart_seq
    AND cart_seq < purchase_seq
  ) AS full_funnel_sessions,

  COUNTIF(
    purchase_seq IS NOT NULL
    AND cart_seq IS NULL
  ) AS purchase_without_cart_sessions

FROM session_funnel;


-- Conversion and abandonment baseline

WITH session_funnel AS (
  SELECT
    session_id,
    MAX(IF(event_type = "product", 1, 0)) AS saw_product,
    MAX(IF(event_type = "cart", 1, 0)) AS reached_cart,
    MAX(IF(event_type = "purchase", 1, 0)) AS purchased
  FROM `bigquery-public-data.thelook_ecommerce.events`
  WHERE DATE(created_at) <= DATE "2026-09-17"
  GROUP BY session_id
)

SELECT
  COUNTIF(saw_product = 1) AS product_sessions,
  COUNTIF(reached_cart = 1) AS cart_sessions,
  COUNTIF(purchased = 1) AS purchase_sessions,

  COUNTIF(
    saw_product = 1
    AND reached_cart = 0
  ) AS product_abandonments,

  COUNTIF(
    reached_cart = 1
    AND purchased = 0
  ) AS cart_abandonments,

  ROUND(
    100 * COUNTIF(reached_cart = 1)
    / COUNTIF(saw_product = 1),
    2
  ) AS product_to_cart_rate_pct,

  ROUND(
    100 * COUNTIF(purchased = 1)
    / COUNTIF(reached_cart = 1),
    2
  ) AS cart_to_purchase_rate_pct,

  ROUND(
    100 * COUNTIF(purchased = 1)
    / COUNTIF(saw_product = 1),
    2
  ) AS product_to_purchase_rate_pct

FROM session_funnel;

