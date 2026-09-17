# Week 4 — Customer Lifecycle & Revenue Leakage

## Objective

Extend revenue leakage analysis from product and operational drivers into customer behavior.

Week 4 evaluates whether leakage is concentrated among specific customer lifecycle stages, repeat-purchase behavior, acquisition sources, or high-value customer segments.

## Customer Lifecycle Model

Built `int_customer_lifecycle.sql` at the grain:

> 1 row = 1 customer

The model includes:

- first and last order timestamps
- lifetime orders and units
- realized revenue
- lifetime cost and gross margin
- average order value
- return and cancellation rates
- acquisition source
- first product category
- lifecycle stage
- activity status

Customer lifecycle and recency are modeled separately:

### Lifecycle Stage

- **New** — 1 lifetime order
- **Repeat** — 2–3 lifetime orders
- **Established** — 4+ lifetime orders

### Activity Status

- **Active** — last order within 90 days of the dataset anchor date
- **Dormant** — more than 90 days since last order

Using the dataset's latest order date instead of the current system date keeps the model reproducible.

## Analysis 1 — New vs Returning Customer Leakage

First purchases and subsequent purchases were classified independently at the order level.

Results:

- New-customer orders generated approximately **$1.72M** in direct revenue leakage from **$6.92M** in gross revenue.
- Returning-customer orders generated approximately **$951K** in direct leakage from **$3.84M** in gross revenue.
- Leak rates were approximately **24.9% for new customers** and **24.8% for returning customers**.

### Finding

Leakage rates are nearly identical between first and repeat purchases.

This indicates that leakage is not primarily a customer-acquisition problem and is more likely associated with broader product or operational factors.

## Analysis 2 — Customer Value × Leak Exposure

Traditional profitability segmentation was evaluated but rejected because the dataset contains no customer-level negative-margin customers and customer margin rates are tightly distributed.

Instead, customers were segmented using revenue value and direct leakage exposure.

Customer value is defined relative to the dataset:

- **High Value** — customer gross revenue at or above the 75th percentile
- **Core Value** — below the 75th percentile

Leak exposure:

- **No Leak**
- **Moderate Leak**
- **Severe Leak** — leak rate at or above the 75th percentile

Key results:

- **High Value / Severe Leak:** 4,820 customers and approximately **$1.26M** in direct leakage.
- **Core Value / Severe Leak:** 15,181 customers and approximately **$995K** in direct leakage.
- High-value customers with severe leakage form a small but financially important intervention group.

## Analysis 3 — Acquisition Cohorts

Customers were grouped by first-purchase month to evaluate repeat behavior over time.

Recent cohorts were separated from mature cohorts to avoid comparing customers with materially different observation windows.

Observed pattern:

- Mature cohorts from late 2024 and early 2025 generally showed repeat rates around **35–38%**.
- Later 2025 cohorts generally declined toward approximately **30–33%**.
- Mature 2026 cohorts were generally around **25–29%**.

### Finding

Repeat behavior appears weaker among newer mature cohorts.

This is a signal for further retention analysis, although recent cohorts require additional time before firm conclusions can be made.

## Analysis 4 — Acquisition Source Quality

Customer economics were compared across Search, Organic, Facebook, Email, and Display acquisition sources.

Repeat behavior and lifetime revenue were highly consistent across channels:

- repeat customer rates were approximately **37%**
- average lifetime orders were approximately **1.55–1.57**
- average lifetime revenue was approximately **$98–$103**

Leak rates were also relatively close:

- Display: **26.23%**
- Email: **24.96%**
- Facebook: **24.90%**
- Search: **24.89%**
- Organic: **24.30%**

### Finding

Display has the highest observed leak rate, but the overall range across channels is narrow.

The evidence does not support acquisition channel as the primary driver of revenue leakage. The problem is more likely occurring downstream in product or operational behavior.

## Analysis 5 — Lifecycle Leak Priority

Customer lifecycle, activity status, value tier, and leak severity were combined into an intervention-priority framework.

Priority tiers:

- **P1 — Protect High Value**
- **P2 — Severe Leak**
- **P3 — Monitor**
- **Healthy**

High-value customers experiencing severe leakage are prioritized for intervention because they combine meaningful commercial value with high financial exposure.

## Validation

Week 4 models and business rules were validated using dbt.

Final build result:

```text
PASS=80
WARN=0
ERROR=0
SKIP=0
TOTAL=80cat > docs/week4_summary.md <<'MD'
# Week 4 — Customer Lifecycle & Revenue Leakage

## Objective

Extend revenue leakage analysis from product and operational drivers into customer behavior.

Week 4 evaluates whether leakage is concentrated among specific customer lifecycle stages, repeat-purchase behavior, acquisition sources, or high-value customer segments.

## Customer Lifecycle Model

Built `int_customer_lifecycle.sql` at the grain:

> 1 row = 1 customer

The model includes:

- first and last order timestamps
- lifetime orders and units
- realized revenue
- lifetime cost and gross margin
- average order value
- return and cancellation rates
- acquisition source
- first product category
- lifecycle stage
- activity status

Customer lifecycle and recency are modeled separately:

### Lifecycle Stage

- **New** — 1 lifetime order
- **Repeat** — 2–3 lifetime orders
- **Established** — 4+ lifetime orders

### Activity Status

- **Active** — last order within 90 days of the dataset anchor date
- **Dormant** — more than 90 days since last order

Using the dataset's latest order date instead of the current system date keeps the model reproducible.

## Analysis 1 — New vs Returning Customer Leakage

First purchases and subsequent purchases were classified independently at the order level.

Results:

- New-customer orders generated approximately **$1.72M** in direct revenue leakage from **$6.92M** in gross revenue.
- Returning-customer orders generated approximately **$951K** in direct leakage from **$3.84M** in gross revenue.
- Leak rates were approximately **24.9% for new customers** and **24.8% for returning customers**.

### Finding

Leakage rates are nearly identical between first and repeat purchases.

This indicates that leakage is not primarily a customer-acquisition problem and is more likely associated with broader product or operational factors.

## Analysis 2 — Customer Value × Leak Exposure

Traditional profitability segmentation was evaluated but rejected because the dataset contains no customer-level negative-margin customers and customer margin rates are tightly distributed.

Instead, customers were segmented using revenue value and direct leakage exposure.

Customer value is defined relative to the dataset:

- **High Value** — customer gross revenue at or above the 75th percentile
- **Core Value** — below the 75th percentile

Leak exposure:

- **No Leak**
- **Moderate Leak**
- **Severe Leak** — leak rate at or above the 75th percentile

Key results:

- **High Value / Severe Leak:** 4,820 customers and approximately **$1.26M** in direct leakage.
- **Core Value / Severe Leak:** 15,181 customers and approximately **$995K** in direct leakage.
- High-value customers with severe leakage form a small but financially important intervention group.

## Analysis 3 — Acquisition Cohorts

Customers were grouped by first-purchase month to evaluate repeat behavior over time.

Recent cohorts were separated from mature cohorts to avoid comparing customers with materially different observation windows.

Observed pattern:

- Mature cohorts from late 2024 and early 2025 generally showed repeat rates around **35–38%**.
- Later 2025 cohorts generally declined toward approximately **30–33%**.
- Mature 2026 cohorts were generally around **25–29%**.

### Finding

Repeat behavior appears weaker among newer mature cohorts.

This is a signal for further retention analysis, although recent cohorts require additional time before firm conclusions can be made.

## Analysis 4 — Acquisition Source Quality

Customer economics were compared across Search, Organic, Facebook, Email, and Display acquisition sources.

Repeat behavior and lifetime revenue were highly consistent across channels:

- repeat customer rates were approximately **37%**
- average lifetime orders were approximately **1.55–1.57**
- average lifetime revenue was approximately **$98–$103**

Leak rates were also relatively close:

- Display: **26.23%**
- Email: **24.96%**
- Facebook: **24.90%**
- Search: **24.89%**
- Organic: **24.30%**

### Finding

Display has the highest observed leak rate, but the overall range across channels is narrow.

The evidence does not support acquisition channel as the primary driver of revenue leakage. The problem is more likely occurring downstream in product or operational behavior.

## Analysis 5 — Lifecycle Leak Priority

Customer lifecycle, activity status, value tier, and leak severity were combined into an intervention-priority framework.

Priority tiers:

- **P1 — Protect High Value**
- **P2 — Severe Leak**
- **P3 — Monitor**
- **Healthy**

High-value customers experiencing severe leakage are prioritized for intervention because they combine meaningful commercial value with high financial exposure.

## Validation

Week 4 models and business rules were validated using dbt.

Final build result:

```text
PASS=80
WARN=0
ERROR=0
SKIP=0
TOTAL=80
