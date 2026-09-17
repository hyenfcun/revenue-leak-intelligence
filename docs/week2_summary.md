# Week 2 — dbt Modeling and Data Quality

## Objective

Build a reproducible analytics engineering layer in dbt + BigQuery for the Revenue Leak Intelligence project.

## Architecture

bigquery-public-data.thelook_ecommerce
→ dbt sources
→ staging views
→ intermediate enriched order-item model
→ automated data tests

## Source Layer

Defined 7 BigQuery source tables:

- orders
- order_items
- products
- users
- inventory_items
- events
- distribution_centers

## Staging Layer

Built 7 dbt staging views:

- stg_thelook__orders
- stg_thelook__order_items
- stg_thelook__products
- stg_thelook__users
- stg_thelook__inventory_items
- stg_thelook__events
- stg_thelook__distribution_centers

Unnecessary customer PII was excluded from the analytics staging layer.

## Analytical Grain

Primary revenue grain:

1 row = 1 order item

Validated:

- 180,858 order-item rows
- 180,858 distinct order_item_id values
- 0 missing inventory joins
- 0 missing product joins
- 0 missing customer joins
- 0 missing distribution-center joins

## Intermediate Model

Built int_order_items_enriched combining:

- transaction revenue
- inventory cost
- gross margin
- gross margin percentage
- product attributes
- customer attributes
- acquisition source
- fulfillment lifecycle
- distribution-center context

## Lifecycle Modeling

Fulfillment timing is anchored to orders.created_at.

Validation confirmed:

- 0 shipments before order creation
- 0 deliveries before order creation
- 0 negative shipment durations
- 0 negative delivery durations
- 0 negative return durations

An initial modeling issue using order_items.created_at as the fulfillment anchor was identified through validation and corrected.

## Profitability Quality

Validated:

- 0 null gross margin values
- 0 negative gross margin values
- 0 invalid gross margin percentages

## Automated Data Quality

Implemented dbt tests covering:

- uniqueness
- not-null constraints
- accepted values
- referential integrity
- order-item grain preservation
- lifecycle timestamp validity
- gross-margin validity

Final dbt build:

PASS=68
WARN=0
ERROR=0
SKIP=0
TOTAL=68

## Week 2 Outcome

The project now has a tested, reproducible analytical foundation for Week 3 revenue-leak analysis.
