# Week 7 — Revenue Leakage Intervention Strategy

## Objective

Translate the revenue leakage analysis into actionable intervention scenarios by estimating potential revenue recovery and identifying the product categories that should receive the highest operational attention.

## Baseline Leakage

The current analytical baseline identifies approximately **$2.65M in direct revenue leakage**:

- **Cancellation leakage:** $1,592,590
- **Return leakage:** $1,054,692

Cancellation represents the larger intervention opportunity and accounts for roughly 60% of the modeled direct leakage.

## Intervention Scenarios

A scenario simulator was developed to estimate potential revenue recovery under hypothetical reductions in cancellation and return leakage.

| Reduction Scenario | Cancellation Recovery | Return Recovery | Combined Recovery |
|---|---:|---:|---:|
| 5% | $79,630 | $52,735 | $132,364 |
| 10% | $159,259 | $105,469 | $264,728 |
| 20% | $318,518 | $210,938 | $529,456 |

Under a **10% simulated reduction**, the business could potentially recover approximately **$264.7K** across cancellation and return leakage.

These values represent scenario-based opportunity estimates rather than causal forecasts or guaranteed realized revenue.

## Category Prioritization

Twenty-six product categories were evaluated using two evidence-based dimensions:

1. **Absolute direct leakage**
2. **Revenue leakage rate**

Categories above the median on both dimensions were classified as **Tier 1 — Act Now**.

Six categories met this threshold:

| Product Category | Direct Leakage | Leak Rate | Dominant Leak Type | Potential Recovery at 10% |
|---|---:|---:|---|---:|
| Jeans | $308,592 | 25.15% | Cancellation | $30,859 |
| Sweaters | $199,511 | 24.67% | Cancellation | $19,951 |
| Suits & Sport Coats | $153,620 | 24.63% | Cancellation | $15,362 |
| Sleep & Lounge | $141,925 | 24.90% | Cancellation | $14,192 |
| Dresses | $118,340 | 24.75% | Cancellation | $11,834 |
| Intimates | $112,302 | 25.04% | Cancellation | $11,230 |

Together, these six Tier 1 categories represent approximately **$1.03M in direct leakage** and approximately **$103.4K in potential recovery under a 10% reduction scenario**.

## Recommended Intervention Priority

### 1. Prioritize cancellation reduction

Cancellation is the largest modeled leakage source at approximately **$1.59M**, compared with approximately **$1.05M from returns**.

Additionally, cancellation is the dominant leakage type across all six Tier 1 product categories.

### 2. Focus first on Tier 1 categories

Operational investigation should begin with:

- Jeans
- Sweaters
- Suits & Sport Coats
- Sleep & Lounge
- Dresses
- Intimates

These categories combine both high absolute leakage and above-median leakage rates, making them stronger intervention candidates than categories selected solely by revenue volume.

### 3. Use a staged intervention approach

A practical approach would be to test cancellation-reduction initiatives within the highest-priority categories first, measure realized improvement, and expand successful interventions to additional categories.

The **10% scenario** provides a reasonable planning benchmark for opportunity sizing without assuming that the entire leakage amount is recoverable.

## Decision Summary

The analysis indicates that the most concentrated near-term opportunity is not simply reducing leakage across the entire business.

Instead, the evidence supports a targeted strategy:

> **Prioritize cancellation reduction within the six Tier 1 product categories, which collectively represent approximately $1.03M in direct leakage and $103.4K in modeled recovery opportunity at a 10% improvement level.**

This approach concentrates intervention effort where both leakage magnitude and leakage rate are elevated.

## Assumptions and Limitations

- Recovery estimates are scenario simulations, not causal forecasts.
- The model assumes recovery scales proportionally with the selected reduction percentage.
- Implementation cost is not available in the source dataset and is therefore not included in prioritization.
- Priority tiers use observed leakage magnitude and leakage rate rather than subjective operational-complexity assumptions.
- Actual realized recovery would require controlled intervention measurement and post-implementation validation.
