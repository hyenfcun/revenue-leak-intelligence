# Week 6 — Executive Revenue Leakage Report

## Objective

Translate the project's validated dbt/SQL analysis into a concise executive report answering:

- Where is revenue leakage concentrated?
- What mechanisms drive the leakage?
- Which customers, products, and fulfillment nodes should be prioritized?
- Is leakage worsening operationally, or scaling with business volume?

## Deliverables

- 8-slide executive PowerPoint report
- Reproducible Python reporting visuals
- Exported analytical datasets used by the report
- Executive storyline and recommendations

## Key Findings

- Approximately **$2.65M** in direct revenue leakage was identified.
- **Outerwear & Coats + Jeans** account for approximately **24%** of total direct leakage.
- **Cancellation** is the dominant leakage mechanism across the highest-impact product categories.
- **4,820 High Value / Severe Leak customers** are associated with approximately **$1.26M** in leakage.
- The **top 5 distribution centers account for 61.7%** of total leakage.
- Distribution-center leakage rates remain broadly similar, suggesting dollar concentration is largely exposure-driven rather than evidence of uniquely poor operational performance.
- Direct leakage increased approximately **138% from Jan–Sep 2026**, while gross sales increased approximately **143%** and leakage rate remained broadly stable.
- Traffic source behaves primarily as an exposure dimension rather than a demonstrated root cause.

## Reporting Assets

Charts:

- `reports/charts/top10_category_leakage.png`
- `reports/charts/top10_leakage_causes.png`
- `reports/charts/distribution_center_leakage.png`
- `reports/charts/monthly_leakage_trend.png`

Executive report:

- `reports/revenue_leak_executive_report.pptx`

Reproducible chart generation:

- `scripts/build_report_charts.py`

## Business Recommendation

Prioritize intervention where:

**High Value × High Leakage × High Volume**

creates the greatest recoverable financial exposure.

The next analytical phase will quantify recoverable revenue under realistic intervention scenarios rather than assuming 100% leakage recovery.
