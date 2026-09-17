select *
from {{ ref('int_customer_lifecycle') }}

where
    lifetime_gross_sales < 0

    or lifetime_revenue < 0

    or lifetime_cost < 0

    or lifetime_revenue > lifetime_gross_sales

    or lifetime_orders > lifetime_units

    or cancelled_units < 0

    or returned_units < 0

    or delivered_units < 0

    or abs(
        lifetime_gross_margin
        - (lifetime_revenue - lifetime_cost)
    ) > 0.01
