with p1_categories as (

    select product_category
    from {{ ref('mart_leak_priority') }}
    where priority_tier = 'P1 - Critical Intervention'

),

dc_summary as (

    select
        f.product_category,
        f.distribution_center_name,

        count(*) as total_items,
        countif(f.has_direct_leak) as leaking_items,

        round(sum(f.gross_revenue), 2) as gross_revenue,
        round(sum(f.direct_leak_amount), 2) as direct_leak_amount,

        round(sum(f.cancelled_revenue), 2) as cancellation_leakage,
        round(sum(f.returned_revenue), 2) as return_leakage,

        round(
            100 * safe_divide(
                countif(f.has_direct_leak),
                count(*)
            ),
            2
        ) as leaking_item_pct

    from {{ ref('fct_revenue_leak') }} f

    inner join p1_categories p
        on f.product_category = p.product_category

    group by
        f.product_category,
        f.distribution_center_name

),

ranked as (

    select
        *,

        rank() over (
            partition by product_category
            order by direct_leak_amount desc
        ) as dc_leak_rank,

        round(
            100 * safe_divide(
                direct_leak_amount,
                sum(direct_leak_amount) over (
                    partition by product_category
                )
            ),
            2
        ) as category_leak_share_pct

    from dc_summary

)

select *
from ranked
order by
    product_category,
    dc_leak_rank
