select *
from {{ ref('int_customer_lifecycle') }}

where
    lifetime_orders < 1

    or lifetime_units < 1

    or first_order_at > last_order_at

    or days_since_last_order < 0

    or (
        lifetime_orders = 1
        and customer_lifecycle_stage != 'New'
    )

    or (
        lifetime_orders between 2 and 3
        and customer_lifecycle_stage != 'Repeat'
    )

    or (
        lifetime_orders >= 4
        and customer_lifecycle_stage != 'Established'
    )

    or (
        days_since_last_order > 90
        and customer_activity_status != 'Dormant'
    )

    or (
        days_since_last_order <= 90
        and customer_activity_status != 'Active'
    )
