# Week 3 Summary — Revenue Leakage Analytics

## Objective

Week 3 transformed the validated dbt foundation into an order-item-level revenue leakage analytics layer.

The objective was to quantify measurable leakage, separate realized leakage from revenue-at-risk signals, and identify the business segments contributing most to loss.

---

## Revenue Leakage Definition

The analysis distinguishes between:

- Direct leakage
- Operational risk
- Customer revenue risk

Direct leakage includes:

1. Cancellation leakage
2. Return leakage
3. Negative-margin leakage

Operational and customer risk signals are intentionally excluded from direct leakage unless a measurable financial loss can be demonstrated.

---

## Analytical Grain

Primary grain:

**1 row = 1 order item**

Validated mart:

`fct_revenue_leak`

Validation result:

- 180,858 rows
- 180,858 unique order items
- Grain preserved successfully

---

## Core Financial Results

Gross sales value:

**$10,754,928.60**

Cancellation leakage:

**$1,607,268.71**

Return leakage:

**$1,066,160.87**

Reconciled direct leakage:

**$2,673,429.58**

Overall revenue leak rate:

**24.86%**

Leak-affected order items:

**45,179**

Cancellation share of direct leakage:

**60.12%**

Return share of direct leakage:

**39.88%**

No negative-margin items were identified in the current dataset.

---

## Category Analysis

Largest categories by absolute leakage:

1. Outerwear & Coats — $320,364.31
2. Jeans — $303,426.26
3. Sweaters — $209,763.32
4. Swim — $161,455.99
5. Suits & Sport Coats — $160,132.58

Absolute leakage alone was not used for prioritization because larger categories naturally generate larger loss amounts.

Swim was the strongest category-level priority because it combined:

- high absolute leakage
- 25.61% revenue leak rate
- top-5 leakage-rate ranking

This suggests stronger normalized leakage than the larger volume-driven categories.

---

## Brand and Product Drill-Down

Within Swim, Speedo generated the largest absolute leakage, but its normalized leakage rate was relatively low.

Quiksilver was more notable because it combined:

- $10,504.59 direct leakage
- 28.76% revenue leak rate

At the SKU level, several products showed high leakage rates, but sample sizes were small.

Therefore, SKU-level concentration is treated as a diagnostic signal rather than a confirmed root cause.

---

## Distribution Center Analysis

Top distribution centers generated large absolute leakage, but normalized leakage rates were tightly clustered:

- Houston TX — 24.45%
- Memphis TN — 24.31%
- Chicago IL — 24.78%
- Mobile AL — 25.04%
- Philadelphia PA — 25.36%

This suggests distribution center is not currently a strong structural driver of leakage.

Most DC-level leakage appears driven by transaction volume rather than abnormal loss rates.

---

## Traffic Source Analysis

Search generated 70.10% of total leakage, but its 24.89% leak rate was close to the overall baseline.

Display had the highest channel leakage rate at 26.23%, but represented only 4.23% of total leakage.

Interpretation:

- Search is a scale-driven leakage source
- Display is a high-rate / low-volume watchlist
- Acquisition channel is not currently the strongest structural root cause

---

## Monthly Trend Analysis

Completed historical period analyzed:

**January 2019 through August 2026**

Completed months:

**92**

Average monthly leak rate:

**24.15%**

Leak-rate standard deviation:

**2.63 percentage points**

Maximum historical monthly leak rate:

**29.13%**

Highest-rate months included:

- Jul 2020 — 29.13%
- Aug 2021 — 29.08%
- Sep 2021 — 29.04%
- Jul 2024 — 28.35%

Several early high-rate months had relatively small sample sizes.

July 2024 is a more credible spike because it contained 2,456 order items.

The time-series evidence does not currently show a sustained deterioration trend.

Instead, leakage appears to behave as a persistent baseline issue with occasional monthly spikes.

---

## Key Business Findings

1. The business shows approximately **$2.67M in reconciled direct leakage** across the analyzed order-item population.

2. Cancellations are the largest direct leakage component, contributing approximately **60%** of total direct leakage.

3. Most absolute segment-level leakage is driven by business volume rather than extreme normalized leakage rates.

4. Swim is the strongest current category-level investigation candidate because it combines substantial economic burden with an elevated leakage rate.

5. Quiksilver within Swim shows elevated normalized leakage, but SKU-level evidence remains sample-limited.

6. Distribution centers do not currently show a strong structural leakage anomaly.

7. Display traffic shows an elevated leakage rate, but its economic exposure remains small.

8. Leakage appears persistent over time rather than driven by a single recent deterioration event.

---

## SQL Techniques Demonstrated

Week 3 analysis uses:

- Common Table Expressions
- Conditional aggregation
- SAFE_DIVIDE
- RANK
- LAG
- Window functions
- Cumulative contribution analysis
- Pareto analysis
- Rate normalization
- Multi-level drill-down analysis

---

## Data Quality and Validation

The revenue leakage mart passed all dbt validation tests.

Validation included:

- order-item uniqueness
- non-null financial metrics
- accepted leakage classifications
- non-negative leakage
- leakage not exceeding sales value
- reconciliation between primary leak type and component metrics

Result:

**10 / 10 tests passed**

---

## Analytical Limitation

The project uses gross sales value associated with cancelled and returned items as a measurable leakage proxy.

This should not be interpreted as audited accounting revenue recognition.

The metric is designed for analytical prioritization rather than financial reporting.

Small-sample product-level findings are not treated as confirmed root causes.

---

## Week 3 Outcome

Week 3 established a defensible revenue leakage fact model and identified where further root-cause analysis should focus.

The strongest current investigation path is:

**Cancellation leakage → Swim → Quiksilver → operational/customer lifecycle drivers**

Week 4 will move from descriptive leakage measurement into customer lifecycle and behavioral analysis.

