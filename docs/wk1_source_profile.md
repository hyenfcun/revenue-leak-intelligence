# Week 1 — Source Profiling & Data Quality Assessment

## Objective

Validate the source data before building transformation models and revenue-leak metrics.

Dataset:
`bigquery-public-data.thelook_ecommerce`

Analysis cutoff:
`2026-09-17`

The cutoff is applied because the source contains synthetic records dated after the project analysis date.

---

## 1. Source Tables

| Table | Rows |
|---|---:|
| events | 2,425,353 |
| inventory_items | 488,014 |
| order_items | 180,858 |
| orders | 124,581 |
| users | 100,000 |
| products | 29,120 |
| distribution_centers | 10 |

Primary analytical tables:

- `order_items` — transaction-level revenue and status
- `orders` — order-level lifecycle
- `products` — cost, category, brand, retail price
- `inventory_items` — inventory age and cost
- `users` — customer segmentation and acquisition source
- `events` — session and conversion behavior

---

## 2. Temporal Data Quality

Raw `order_items` coverage:

- Earliest transaction: 2019-01-13
- Latest transaction: 2026-09-21
- Total order items: 180,858
- Unique orders: 124,581
- Unique customers: 80,012

The dataset contains future-dated records relative to the analysis date.

Future records:

- 1,211 order items
- 794 orders
- Date range: 2026-09-18 to 2026-09-21
- 0.67% of raw order-item rows

### Modeling Decision

Use:

`analysis_cutoff_date = 2026-09-17`

Future-dated records will not be deleted from the raw source. They will be excluded or flagged in downstream transformation models.

Valid order-item population after cutoff:

**179,647 rows**

---

## 3. Transaction Status Baseline

| Status | Items | Orders | Sales Value |
|---|---:|---:|---:|
| Shipped | 54,396 | 37,534 | $3,245,111.43 |
| Complete | 44,466 | 30,906 | $2,624,383.84 |
| Processing | 35,910 | 24,874 | $2,158,034.89 |
| Cancelled | 26,859 | 18,573 | $1,596,990.57 |
| Returned | 18,016 | 12,489 | $1,057,414.00 |

Cancelled + Returned items represent approximately 25% of valid order-item volume.

These values are treated as **revenue-at-risk indicators**, not automatically as realized profit loss.

---

## 4. Product & Margin Quality

Product catalog:

- 29,120 products
- 0 null costs
- 0 non-positive costs
- 0 null retail prices
- 0 non-positive retail prices
- Average cost: $28.48
- Average retail price: $59.22

Catalog margin validation:

- 0 products with cost above retail price
- 0 products with cost equal to retail price
- Average listed unit margin: $30.74

Actual transaction margin validation:

- 179,647 valid order items
- 0 null sale prices
- 0 non-positive sale prices
- 0 transactions sold below cost
- 0 transactions sold at cost
- Average actual unit margin: $30.87

### Finding

Negative-margin sales are not a meaningful source of leakage in this dataset.

---

## 5. Join Integrity

### Order Items → Products

- Matched rows: 179,647
- Unmatched rows: 0
- Match rate: 100%

### Order Items → Users

- Matched rows: 179,647
- Unmatched rows: 0
- Match rate: 100%
- Unique ordering customers: 79,923

### Orders → Order Items

Using the complete raw dataset:

- 124,581 / 124,581 orders match `num_of_item`
- 0 structural item-count mismatches
- 0 mixed item-status orders
- 0 order/item status mismatches

794 orders appear incomplete only after applying the cutoff because they contain 1,211 future-dated order items.

### Finding

The source relationships are structurally consistent. The apparent mismatch is caused by the temporal cutoff rather than broken joins.

---

## 6. Inventory Assessment

Inventory as of 2026-09-17:

- Inventory items in scope: 487,996
- Sold items: 179,647
- Unsold items: 308,349
- Unsold inventory cost: $8,816,689.64
- Average days to sell: 29.48 days
- Average unsold inventory age: 1,219.23 days

Inventory older than 365 days:

- 261,374 items
- 84.77% of unsold inventory
- $7,477,981.73 tied-up inventory cost
- Average age: 1,406.4 days

Category-level aging rates are highly uniform, generally around 84–86%.

Annual inventory cohorts also show a highly regular synthetic pattern.

### Modeling Decision

Inventory aging will be retained as a contextual working-capital KPI, but it will **not be treated as a primary root cause of revenue leakage**.

The pattern appears to be largely structural to the synthetic dataset.

---

## 7. Customer Acquisition Mix

Customer acquisition distribution:

| Source | Customers | Orders | Sales Value |
|---|---:|---:|---:|
| Search | 55,992 | 87,122 | $7,477,572.28 |
| Organic | 11,963 | 18,556 | $1,614,175.78 |
| Facebook | 4,764 | 7,447 | $630,343.10 |
| Email | 3,974 | 6,215 | $530,093.83 |
| Display | 3,230 | 5,036 | $429,749.75 |

Return + cancellation rates:

- Display: 25.66%
- Facebook: 25.33%
- Search: 25.01%
- Organic: 24.71%
- Email: 24.42%

### Finding

Acquisition-channel leakage rates are tightly clustered.

Search contributes the largest dollar value mainly because it has the largest customer volume, not because it has materially worse customer quality.

Traffic source will therefore be used primarily as a segmentation dimension rather than a core leakage root cause.

---

## 8. Event & Funnel Validation

Valid event types include:

- product
- cart
- department
- purchase
- cancel
- home

Important data-quality findings:

- `purchase` events: 179,647
- Valid `order_items`: 179,647
- `cancel` events have 100% null `user_id`
- `session_id` is populated across event types
- Purchase sessions always contain a preceding cart event
- Cart sessions always contain a preceding product event

### Modeling Decision

Use:

- `events` for session and behavioral intent
- `orders` / `order_items` for transactional truth

Do not interpret `cancel` events as authoritative order cancellations.

---

## 9. Conversion Funnel Baseline

Session funnel:

- Product sessions: 680,858
- Cart sessions: 431,296
- Purchase sessions: 179,647

Abandonment:

- Product abandonment: 249,562 sessions
- Cart abandonment: 251,649 sessions

Conversion rates:

- Product → Cart: 63.35%
- Cart → Purchase: 41.65%
- Product → Purchase: 26.39%

### Finding

The event data supports session-level conversion analysis, but the synthetic structure is highly regular.

Funnel abandonment will be treated as a behavioral leakage indicator rather than directly translated into lost revenue.

---

## 10. Week 1 Modeling Decisions

The project will proceed with the following analytical principles:

1. Preserve raw source data unchanged.
2. Apply a reproducible analysis cutoff of 2026-09-17.
3. Use `order_items` as the primary financial transaction grain.
4. Use `orders` for order-level lifecycle metrics.
5. Use `products` for cost and margin calculations.
6. Use `users` for customer segmentation.
7. Use `events` for behavioral funnel analysis.
8. Treat cancellations and returns as revenue-at-risk until leakage definitions are formally modeled.
9. Avoid presenting synthetic inventory artifacts as real business root causes.
10. Validate joins and metric grain before aggregating revenue or margin.

---

## Week 1 Outcome

The source data is sufficiently complete and internally consistent to proceed to transformation modeling.

Primary Week 2 focus:

**BigQuery raw sources → dbt staging layer → tested analytics-ready models**

