with order_items as (

    select *
    from {{ ref('int_order_items_enriched') }}

),

dataset_anchor as (

    select
        max(order_created_at) as analysis_timestamp
    from order_items

),

customer_rollup as (

    select
        user_id as customer_id,

        min(order_created_at) as first_order_at,
        max(order_created_at) as last_order_at,

        count(distinct order_id) as lifetime_orders,
        count(*) as lifetime_units,

        countif(is_cancelled) as cancelled_units,
        countif(is_returned) as returned_units,
        countif(is_delivered) as delivered_units,

        sum(sale_price) as lifetime_gross_sales,

        sum(
            case
                when not is_cancelled
                    and not is_returned
                then sale_price
                else 0
            end
        ) as lifetime_revenue,

        sum(
            case
                when not is_cancelled
                    and not is_returned
                then inventory_cost
                else 0
            end
        ) as lifetime_cost,

        sum(
            case
                when not is_cancelled
                    and not is_returned
                then gross_margin
                else 0
            end
        ) as lifetime_gross_margin,

        safe_divide(
            countif(is_returned),
            count(*)
        ) as return_rate,

        safe_divide(
            countif(is_cancelled),
            count(*)
        ) as cancellation_rate,

        any_value(traffic_source) as acquisition_source,

        array_agg(
            product_category ignore nulls
            order by order_created_at, order_item_created_at
            limit 1
        )[safe_offset(0)] as first_product_category

    from order_items
    where user_id is not null
    group by user_id

),

final as (

    select
        c.customer_id,

        c.first_order_at,
        c.last_order_at,

        c.lifetime_orders,
        c.lifetime_units,

        c.cancelled_units,
        c.returned_units,
        c.delivered_units,

        c.lifetime_gross_sales,
        c.lifetime_revenue,
        c.lifetime_cost,
        c.lifetime_gross_margin,

        safe_divide(
            c.lifetime_revenue,
            c.lifetime_orders
        ) as avg_order_value,

        safe_divide(
            c.lifetime_gross_margin,
            c.lifetime_orders
        ) as avg_gross_margin_per_order,

        c.return_rate,
        c.cancellation_rate,

        date_diff(
            date(c.last_order_at),
            date(c.first_order_at),
            day
        ) as customer_tenure_days,

        date_diff(
            date(a.analysis_timestamp),
            date(c.last_order_at),
            day
        ) as days_since_last_order,

        c.acquisition_source,
        c.first_product_category,

        case
            when c.lifetime_orders = 1
                then 'New'
            when c.lifetime_orders between 2 and 3
                then 'Repeat'
            when c.lifetime_orders >= 4
                then 'Established'
            else 'Unknown'
        end as customer_lifecycle_stage,

        case
            when date_diff(
                date(a.analysis_timestamp),
                date(c.last_order_at),
                day
            ) > 90
                then 'Dormant'
            else 'Active'
        end as customer_activity_status

    from customer_rollup c
    cross join dataset_anchor a

)

select *
from final
