with product_summary as (

    select
        product_id,
        product_name,

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

    where product_category = 'Swim'
      and product_brand = 'Quiksilver'

    group by
        product_id,
        product_name

),

eligible_products as (

    select *
    from product_summary
    where total_items >= 10

),

ranked as (

    select
        *,

        rank() over (
            order by direct_leak_amount desc
        ) as leak_amount_rank,

        rank() over (
            order by revenue_leak_rate_pct desc
        ) as leak_rate_rank,

        round(
            100 * safe_divide(
                direct_leak_amount,
                sum(direct_leak_amount) over ()
            ),
            2
        ) as brand_leak_share_pct

    from eligible_products

),

pareto as (

    select
        *,

        round(
            sum(brand_leak_share_pct) over (
                order by direct_leak_amount desc
                rows between unbounded preceding and current row
            ),
            2
        ) as cumulative_brand_leak_share_pct

    from ranked

)

select *
from pareto
order by direct_leak_amount desc

