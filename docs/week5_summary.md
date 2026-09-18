# Week 5 — Revenue Leakage Root Cause & Prioritization

## Objective

Identify the highest-value revenue leakage intervention areas, determine the primary leakage mechanisms, and distinguish structural business problems from isolated product or operational anomalies.

## Priority Model

Built `mart_leak_priority` to rank product categories using a business-weighted intervention score:

- 50% direct leakage burden
- 20% margin exposure
- 20% transaction volume
- 10% leaking-item rate

The model prioritizes financial exposure while retaining leakage frequency as a supporting signal.

## Priority Categories

The two P1 intervention categories were:

| Category | Direct Leakage | Leakage Share | Priority Score |
|---|---:|---:|---:|
| Outerwear & Coats | $320,364.31 | 11.98% | 93.20 |
| Jeans | $303,426.26 | 11.35% | 91.40 |

Together, these categories represent more than $623K in direct revenue leakage.

## Root-Cause Findings

### Outerwear & Coats

Outerwear & Coats generated $320,364.31 in direct leakage.

- Cancellation leakage: $198,159.52
- Return leakage: $122,204.79
- Cancellation share: 61.85%
- Return share: 38.15%
- Negative-margin leakage: $0

Carhartt was the largest brand-level contributor with approximately $23.3K of leakage, representing 7.28% of category leakage.

### Jeans

Jeans generated $303,426.26 in direct leakage.

- Cancellation leakage: $181,595.59
- Return leakage: $121,830.67
- Cancellation share: 59.85%
- Return share: 40.15%
- Negative-margin leakage: $0

7 For All Mankind was the largest brand-level contributor with approximately $35.0K of leakage, representing 11.54% of category leakage.

## Operational Diagnostic

Distribution-center leakage was normalized against revenue exposure using:

`leakage over-index = leakage share / revenue share`

Observed values were approximately 0.88–1.10 across P1 categories.

This indicates no distribution center materially over-indexed on leakage. High absolute leakage at locations such as Houston or Philadelphia was largely explained by higher revenue exposure rather than abnormal operational performance.

## Product-Level Diagnostic

SKU-level leakage was fragmented.

Top products generally had small sample sizes and individually represented only a small share of brand leakage. Therefore, individual products were not treated as statistically or commercially defensible root causes.

## Business Interpretation

The evidence suggests that the primary issue is not negative margin, a single SKU, or an isolated distribution center.

The strongest intervention opportunity is a broader cancellation-and-return problem within the highest-exposure categories.

Recommended next-step interventions should therefore focus on reducing cancellation and return behavior within Outerwear & Coats and Jeans, with brand-level monitoring used to prioritize investigation.

## Validation

`mart_leak_priority` passed:

- schema and integrity tests
- accepted-value tests
- priority-score range validation
- priority-tier consistency validation

All dedicated priority tests completed with zero warnings and zero errors.

## Week 5 Deliverables

- `models/marts/mart_leak_priority.sql`
- `tests/assert_priority_score_valid.sql`
- `tests/assert_priority_tier_consistent.sql`
- `analyses/13_p1_brand_root_cause.sql`
- `analyses/14_p1_product_root_cause.sql`
- `analyses/15_p1_distribution_center_root_cause.sql`
- `analyses/16_p1_leakage_mechanism.sql`
- `docs/week5_summary.md`
