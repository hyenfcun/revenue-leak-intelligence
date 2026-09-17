with customer_economics as (

    select
        user_id as customer_id,

        count(distinct order_id) as lifetime_orders,

        sum(gross_revenue) as gross_revenue,

        sum(direct_leak_amount) as direct_leak_amount,

        safe_divide(
            sum(direct_leak_amount),
            sum(gross_revenue)
        ) as leak_rate

    from {{ ref('fct_revenue_leak') }}

    where user_id is not null

    group by user_id

),

thresholds as (

    select
        approx_quantiles(gross_revenue, 100)[offset(75)]
            as p75_revenue,

        approx_quantiles(leak_rate, 100)[offset(75)]
            as p75_leak_rate

    from customer_economics

),

segmented as (

    select
        c.*,

        case
            when c.gross_revenue >= t.p75_revenue
                then 'High Value'
            else 'Core Value'
        end as value_tier,

        case
            when c.direct_leak_amount = 0
                then 'No Leak'

            when c.leak_rate >= t.p75_leak_rate
                then 'Severe Leak'

            else 'Moderate Leak'
        end as leak_tier

    from customer_economics c

    cross join thresholds t

),

summary as (

    select
        value_tier,
        leak_tier,

        count(*) as customers,

        sum(lifetime_orders) as orders,

        sum(gross_revenue) as gross_revenue,

        sum(direct_leak_amount) as direct_leak_amount,

        avg(gross_revenue) as avg_revenue_per_customer,

        avg(direct_leak_amount) as avg_leak_per_customer,

        safe_divide(
            sum(direct_leak_amount),
            sum(gross_revenue)
        ) as segment_leak_rate

    from segmented

    group by
        value_tier,
        leak_tier

)

select
    value_tier,
    leak_tier,

    customers,
    orders,

    round(gross_revenue, 2)
        as gross_revenue,

    round(direct_leak_amount, 2)
        as direct_leak_amount,

    round(avg_revenue_per_customer, 2)
        as avg_revenue_per_customer,

    round(avg_leak_per_customer, 2)
        as avg_leak_per_customer,

    round(segment_leak_rate * 100, 2)
        as segment_leak_rate_pct,

    round(
        safe_divide(
            customers,
            sum(customers) over ()
        ) * 100,
        2
    ) as customer_share_pct,

    round(
        safe_divide(
            direct_leak_amount,
            sum(direct_leak_amount) over ()
        ) * 100,
        2
    ) as leak_share_pct

from summary

order by
    direct_leak_amount desc
