with customers as (

    select
        customer_id,
        acquisition_source,
        lifetime_orders,
        lifetime_revenue,
        lifetime_gross_margin
    from {{ ref('int_customer_lifecycle') }}

),

customer_leak as (

    select
        user_id as customer_id,

        sum(gross_revenue) as gross_revenue,
        sum(direct_leak_amount) as direct_leak_amount

    from {{ ref('fct_revenue_leak') }}

    where user_id is not null

    group by user_id

),

combined as (

    select
        c.customer_id,
        c.acquisition_source,
        c.lifetime_orders,
        c.lifetime_revenue,
        c.lifetime_gross_margin,

        l.gross_revenue,
        l.direct_leak_amount,

        safe_divide(
            l.direct_leak_amount,
            l.gross_revenue
        ) as customer_leak_rate

    from customers c

    inner join customer_leak l
        on c.customer_id = l.customer_id

),

summary as (

    select
        acquisition_source,

        count(*) as customers,

        countif(lifetime_orders >= 2) as repeat_customers,

        safe_divide(
            countif(lifetime_orders >= 2),
            count(*)
        ) as repeat_customer_rate,

        avg(lifetime_orders)
            as avg_orders_per_customer,

        avg(lifetime_revenue)
            as avg_lifetime_revenue,

        avg(lifetime_gross_margin)
            as avg_lifetime_margin,

        sum(gross_revenue)
            as gross_revenue,

        sum(direct_leak_amount)
            as direct_leak_amount,

        safe_divide(
            sum(direct_leak_amount),
            sum(gross_revenue)
        ) as source_leak_rate,

        countif(direct_leak_amount > 0)
            as leak_exposed_customers

    from combined

    group by acquisition_source

)

select
    acquisition_source,

    customers,
    repeat_customers,

    round(repeat_customer_rate * 100, 2)
        as repeat_customer_rate_pct,

    round(avg_orders_per_customer, 2)
        as avg_orders_per_customer,

    round(avg_lifetime_revenue, 2)
        as avg_lifetime_revenue,

    round(avg_lifetime_margin, 2)
        as avg_lifetime_margin,

    round(gross_revenue, 2)
        as gross_revenue,

    round(direct_leak_amount, 2)
        as direct_leak_amount,

    round(source_leak_rate * 100, 2)
        as source_leak_rate_pct,

    leak_exposed_customers,

    round(
        safe_divide(
            leak_exposed_customers,
            customers
        ) * 100,
        2
    ) as leak_exposed_customer_pct

from summary

order by direct_leak_amount desc
