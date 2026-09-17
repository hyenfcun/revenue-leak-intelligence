with category_summary as (

    select
        product_category,

        count(*) as total_items,

        round(sum(gross_revenue), 2) as gross_sales_value,

        countif(has_direct_leak) as leak_items,

        round(sum(direct_leak_amount), 2) as direct_leak_amount,

        round(sum(cancelled_revenue), 2) as cancellation_leakage,

        round(sum(returned_revenue), 2) as return_leakage,

        round(sum(margin_leakage), 2) as margin_leakage,

        round(
            100 * safe_divide(
                countif(has_direct_leak),
                count(*)
            ),
            2
        ) as leak_item_rate_pct,

        round(
            100 * safe_divide(
                sum(direct_leak_amount),
                sum(gross_revenue)
            ),
            2
        ) as revenue_leak_rate_pct

    from {{ ref('fct_revenue_leak') }}

    group by product_category

),

ranked as (

    select
        *,

        rank() over (
            order by direct_leak_amount desc
        ) as leakage_rank,

        round(
            100 * safe_divide(
                direct_leak_amount,
                sum(direct_leak_amount) over ()
            ),
            2
        ) as leak_share_pct

    from category_summary

),

pareto as (

    select
        *,

        round(
            sum(leak_share_pct) over (
                order by direct_leak_amount desc
                rows between unbounded preceding and current row
            ),
            2
        ) as cumulative_leak_share_pct

    from ranked

)

select
    *
from pareto
order by direct_leak_amount desc

