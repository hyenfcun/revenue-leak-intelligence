# Week 7 Summary — Revenue Leakage Intervention Simulator

## Objective

Convert descriptive revenue leakage analysis into a decision-support framework that estimates potential recovery and prioritizes intervention opportunities.

## Work Completed

- Built dbt intervention scenario analysis on top of `fct_revenue_leak`
- Simulated 5%, 10%, and 20% reductions in cancellation and return leakage
- Built a Python simulator to execute BigQuery scenario logic and export structured outputs
- Generated CSV and JSON intervention datasets
- Developed a category-level intervention prioritization model
- Classified 26 product categories into four priority tiers
- Identified six Tier 1 categories with both high leakage magnitude and high leakage rates
- Generated two recruiter-viewable intervention charts
- Documented intervention recommendations, assumptions, and limitations
- Added automated Week 7 validation checks

## Key Findings

- Total modeled direct leakage: approximately **$2.65M**
- Cancellation leakage: approximately **$1.59M**
- Return leakage: approximately **$1.05M**
- Simulated 10% combined improvement: approximately **$264.7K potential recovery**
- Six Tier 1 categories account for approximately **$1.03M in direct leakage**
- Tier 1 categories represent approximately **$103.4K in modeled recovery opportunity at a 10% improvement level**
- All six Tier 1 categories are cancellation-dominant

## Recommended Action

Prioritize cancellation reduction within the six Tier 1 product categories:

- Jeans
- Sweaters
- Suits & Sport Coats
- Sleep & Lounge
- Dresses
- Intimates

These categories combine elevated leakage magnitude with above-median leakage rates and represent the strongest immediate intervention opportunity identified by the analysis.

## Validation

Week 7 automated validation result:

`PASS=18 ERROR=0 TOTAL=18`

## Outputs

### Analysis
- `revenue_leak/analyses/08_intervention_scenarios.sql`

### Python
- `scripts/simulate_interventions.py`
- `scripts/build_intervention_priority.py`
- `scripts/create_intervention_charts.py`
- `scripts/validate_week7.py`

### Data
- `reports/data/intervention_scenarios.csv`
- `reports/data/intervention_scenarios.json`
- `reports/data/intervention_priority.csv`

### Charts
- `reports/charts/intervention_recovery_scenarios.png`
- `reports/charts/intervention_priority_matrix.png`

### Documentation
- `docs/week7_intervention_strategy.md`
- `docs/week7_summary.md`
