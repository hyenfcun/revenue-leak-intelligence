with monthly_summary as (

    select
        date_trunc(date(order_created_at), month) as order_month,

        count(*) as total_items,

        round(sum(gross_revenue), 2) as gross_sales_value,

        countif(has_direct_leak) as leak_items,

        round(sum(direct_leak_amount), 2) as direct_leak_amount,

        round(sum(cancelled_revenue), 2) as cancellation_leakage,

        round(sum(returned_revenue), 2) as return_leakage,

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

    group by order_month

),

trend as (

    select
        *,

        lag(revenue_leak_rate_pct) over (
            order by order_month
        ) as prior_month_leak_rate_pct,

        round(
            revenue_leak_rate_pct
            - lag(revenue_leak_rate_pct) over (
                order by order_month
            ),
            2
        ) as leak_rate_change_pp,

        rank() over (
            order by revenue_leak_rate_pct desc
        ) as leak_rate_rank

    from monthly_summary

)

select *
from trend
order by order_month

