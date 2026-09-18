# Revenue Leak Intelligence — Executive Report Story

## Slide 1 — Title
**Revenue Leak Intelligence**
Where is the business losing money, why is it happening, and where should intervention start?

BigQuery → dbt → SQL Analytics → Executive Recommendations

---

## Slide 2 — Executive Summary
### $2.67M+ in direct revenue leakage identified

Key findings:
- Cancellation is the dominant leakage mechanism across high-impact categories.
- Outerwear & Coats and Jeans account for approximately $635K in direct leakage.
- 4,820 High Value / Severe Leak customers are associated with approximately $1.26M in leakage.
- The top 5 distribution centers account for approximately 61.7% of total leakage.
- Leakage dollars are increasing as business volume scales, while normalized leakage rates remain broadly stable.

Executive implication:
The primary opportunity is not a system-wide deterioration in leakage rate. The business should prioritize high-dollar customer, product, and fulfillment segments where existing leakage rates create the greatest financial exposure.

---

## Slide 3 — Data & Analytical Approach
### From raw ecommerce transactions to decision-ready leakage metrics

Dataset:
- TheLook Ecommerce
- 180K+ order-item transactions
- Customer, order, product, fulfillment, lifecycle, and acquisition dimensions

Analytics stack:
- BigQuery
- dbt
- Advanced SQL
- Automated data-quality testing
- Python-generated reporting visuals
- Git / GitHub

Analytical layers:
Raw Sources
→ Staging
→ Enriched Order Items
→ Customer Lifecycle
→ Revenue Leakage
→ Root Cause Analysis
→ Executive Reporting

---

## Slide 4 — Product Leakage
### Leakage is concentrated in high-value product categories

Visuals:
- top10_category_leakage.png
- top10_leakage_causes.png

Key findings:
- Outerwear & Coats: ~$326.8K direct leakage
- Jeans: ~$308.6K direct leakage
- Combined exposure: ~$635K
- Cancellation contributes more leakage than returns across most high-impact categories.

Implication:
Prioritize cancellation reduction in the highest-dollar categories rather than applying broad interventions across the entire catalog.

---

## Slide 5 — Customer Lifecycle Risk
### A relatively small high-value customer segment represents outsized financial exposure

Key finding:
- High Value / Severe Leak customers: 4,820
- Associated leakage: approximately $1.26M

Business interpretation:
These customers combine high economic value with severe leakage behavior, making them the highest-priority segment for retention and leakage-prevention interventions.

Recommended priority:
Protect high-value customers first rather than optimizing solely for customer count.

---

## Slide 6 — Fulfillment Concentration
### 61.7% of leakage is concentrated in five distribution centers

Visual:
- distribution_center_leakage.png

Top exposure:
- Houston
- Memphis
- Chicago
- Mobile
- Philadelphia

Important interpretation:
Leakage rates across distribution centers remain relatively similar.

Therefore:
High leakage at these locations is primarily driven by financial exposure and transaction volume, not clear evidence of uniquely poor operational performance.

---

## Slide 7 — Leakage at Scale
### Leakage dollars are rising with business growth, not because leakage rates are deteriorating

Visual:
- monthly_leakage_trend.png

Recent pattern:
- Direct leakage rises substantially during 2026.
- Gross sales and transaction volume rise at the same time.
- Revenue leakage rate remains broadly around the mid-20% range.

Implication:
Even a stable leakage rate becomes increasingly expensive as the business scales.

Reducing leakage by a few percentage points becomes more financially valuable as transaction volume grows.

---

## Slide 8 — Recommended Actions
### Prioritize interventions by financial exposure

1. Reduce cancellations in Outerwear & Coats and Jeans.
2. Target High Value / Severe Leak customers with retention and recovery actions.
3. Prioritize high-volume distribution centers for operational investigation.
4. Track leakage rate alongside absolute leakage dollars to separate scale effects from process deterioration.
5. Treat traffic source primarily as an exposure dimension, not a demonstrated root cause of leakage.

### Decision principle
Focus first where:
**High Value × High Leakage × High Volume**
creates the largest recoverable business opportunity.
