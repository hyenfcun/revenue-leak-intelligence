select
    product_category,

    round(sum(direct_leak_amount), 2) as total_direct_leakage,

    round(sum(cancelled_revenue), 2) as cancellation_leakage,

    round(sum(returned_revenue), 2) as return_leakage,

    round(sum(margin_leakage), 2) as margin_leakage,

    round(
        100 * safe_divide(
            sum(cancelled_revenue),
            sum(direct_leak_amount)
        ),
        2
    ) as cancellation_share_pct,

    round(
        100 * safe_divide(
            sum(returned_revenue),
            sum(direct_leak_amount)
        ),
        2
    ) as return_share_pct,

    round(
        100 * safe_divide(
            sum(margin_leakage),
            sum(direct_leak_amount)
        ),
        2
    ) as margin_leak_share_pct

from {{ ref('fct_revenue_leak') }}

where product_category in (
    'Outerwear & Coats',
    'Jeans'
)

group by product_category

order by total_direct_leakage desc
