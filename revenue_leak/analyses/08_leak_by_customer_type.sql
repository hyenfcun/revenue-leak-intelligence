with leak as (

    select *
    from {{ ref('fct_revenue_leak') }}

),

orders as (

    select distinct
        user_id,
        order_id,
        order_created_at
    from leak
    where user_id is not null

),

ranked_orders as (

    select
        user_id,
        order_id,
        row_number() over (
            partition by user_id
            order by order_created_at, order_id
        ) as customer_order_number
    from orders

),

classified_items as (

    select
        l.*,

        r.customer_order_number,

        case
            when r.customer_order_number = 1
                then 'New Customer'
            else 'Returning Customer'
        end as customer_type

    from leak l

    left join ranked_orders r
        on l.user_id = r.user_id
       and l.order_id = r.order_id

),

customer_type_summary as (

    select
        customer_type,

        count(distinct user_id) as customers,
        count(distinct order_id) as orders,
        count(*) as order_items,

        sum(gross_revenue) as gross_revenue,
        sum(direct_leak_amount) as direct_leak_amount,

        countif(has_direct_leak) as leaked_items,

        safe_divide(
            countif(has_direct_leak),
            count(*)
        ) as leaked_item_rate,

        safe_divide(
            sum(direct_leak_amount),
            sum(gross_revenue)
        ) as leak_rate

    from classified_items
    group by customer_type

),

final as (

    select
        *,

        safe_divide(
            direct_leak_amount,
            sum(direct_leak_amount) over ()
        ) as leak_share,

        safe_divide(
            direct_leak_amount,
            orders
        ) as avg_leak_per_order

    from customer_type_summary

)

select
    customer_type,
    customers,
    orders,
    order_items,

    round(gross_revenue, 2) as gross_revenue,
    round(direct_leak_amount, 2) as direct_leak_amount,

    leaked_items,

    round(leaked_item_rate * 100, 2) as leaked_item_rate_pct,
    round(leak_rate * 100, 2) as leak_rate_pct,
    round(leak_share * 100, 2) as leak_share_pct,
    round(avg_leak_per_order, 2) as avg_leak_per_order

from final
order by direct_leak_amount desc
