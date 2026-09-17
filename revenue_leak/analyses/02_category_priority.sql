with category_summary as (

    select
        product_category,

        count(*) as total_items,

        round(sum(gross_revenue), 2) as gross_sales_value,

        countif(has_direct_leak) as leak_items,

        round(sum(direct_leak_amount), 2) as direct_leak_amount,

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

benchmarked as (

    select
        *,

        round(
            avg(revenue_leak_rate_pct) over (),
            2
        ) as avg_category_leak_rate_pct,

        rank() over (
            order by direct_leak_amount desc
        ) as amount_rank,

        rank() over (
            order by revenue_leak_rate_pct desc
        ) as rate_rank

    from category_summary

),

prioritized as (

    select
        *,

        case
            when amount_rank <= 5
                 and revenue_leak_rate_pct > avg_category_leak_rate_pct
                then 'P1 - High Amount / High Rate'

            when amount_rank <= 5
                then 'P2 - High Amount'

            when revenue_leak_rate_pct > avg_category_leak_rate_pct
                then 'P3 - High Rate'

            else 'Monitor'
        end as priority_tier

    from benchmarked

)

select
    product_category,
    total_items,
    gross_sales_value,
    direct_leak_amount,
    leak_item_rate_pct,
    revenue_leak_rate_pct,
    avg_category_leak_rate_pct,
    amount_rank,
    rate_rank,
    priority_tier

from prioritized

order by
    case priority_tier
        when 'P1 - High Amount / High Rate' then 1
        when 'P2 - High Amount' then 2
        when 'P3 - High Rate' then 3
        else 4
    end,
    direct_leak_amount desc

