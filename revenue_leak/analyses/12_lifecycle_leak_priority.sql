with customer_lifecycle as (

    select
        customer_id,
        customer_lifecycle_stage,
        customer_activity_status
    from {{ ref('int_customer_lifecycle') }}

),

customer_economics as (

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

classified as (

    select
        e.customer_id,
        l.customer_lifecycle_stage,
        l.customer_activity_status,

        e.lifetime_orders,
        e.gross_revenue,
        e.direct_leak_amount,
        e.leak_rate,

        case
            when e.gross_revenue >= t.p75_revenue
                then 'High Value'
            else 'Core Value'
        end as value_tier,

        case
            when e.direct_leak_amount = 0
                then 'No Leak'

            when e.leak_rate >= t.p75_leak_rate
                then 'Severe Leak'

            else 'Moderate Leak'
        end as leak_tier

    from customer_economics e

    inner join customer_lifecycle l
        on e.customer_id = l.customer_id

    cross join thresholds t

),

summary as (

    select
        customer_lifecycle_stage,
        customer_activity_status,
        value_tier,
        leak_tier,

        count(*) as customers,

        sum(lifetime_orders) as orders,

        sum(gross_revenue) as gross_revenue,

        sum(direct_leak_amount) as direct_leak_amount,

        safe_divide(
            sum(direct_leak_amount),
            sum(gross_revenue)
        ) as segment_leak_rate,

        avg(direct_leak_amount)
            as avg_leak_per_customer

    from classified

    group by
        customer_lifecycle_stage,
        customer_activity_status,
        value_tier,
        leak_tier

),

final as (

    select
        *,

        safe_divide(
            customers,
            sum(customers) over ()
        ) as customer_share,

        safe_divide(
            direct_leak_amount,
            sum(direct_leak_amount) over ()
        ) as leak_share,

        case
            when value_tier = 'High Value'
                and leak_tier = 'Severe Leak'
                then 'P1 - Protect High Value'

            when value_tier = 'Core Value'
                and leak_tier = 'Severe Leak'
                then 'P2 - Severe Leak'

            when leak_tier = 'Moderate Leak'
                then 'P3 - Monitor'

            else 'Healthy'
        end as priority_tier

    from summary

)

select
    dense_rank() over (
        order by direct_leak_amount desc
    ) as leak_priority_rank,

    customer_lifecycle_stage,
    customer_activity_status,
    value_tier,
    leak_tier,
    priority_tier,

    customers,
    orders,

    round(gross_revenue, 2)
        as gross_revenue,

    round(direct_leak_amount, 2)
        as direct_leak_amount,

    round(segment_leak_rate * 100, 2)
        as segment_leak_rate_pct,

    round(avg_leak_per_customer, 2)
        as avg_leak_per_customer,

    round(customer_share * 100, 2)
        as customer_share_pct,

    round(leak_share * 100, 2)
        as leak_share_pct

from final

order by direct_leak_amount desc
