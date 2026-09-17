select *
from {{ ref('fct_revenue_leak') }}
where
    (primary_leak_type = 'Cancellation'
        and direct_leak_amount != cancelled_revenue)

    or

    (primary_leak_type = 'Return'
        and direct_leak_amount != returned_revenue)

    or

    (primary_leak_type = 'Negative Margin'
        and direct_leak_amount != margin_leakage)

    or

    (primary_leak_type = 'No Direct Leak'
        and direct_leak_amount != 0)

