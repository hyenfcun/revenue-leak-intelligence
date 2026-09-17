with order_items as (

    select *
    from {{ ref('stg_thelook__order_items') }}

),

inventory_items as (

    select *
    from {{ ref('stg_thelook__inventory_items') }}

),

products as (

    select *
    from {{ ref('stg_thelook__products') }}

),

orders as (

    select *
    from {{ ref('stg_thelook__orders') }}

),

users as (

    select *
    from {{ ref('stg_thelook__users') }}

),

distribution_centers as (

    select *
    from {{ ref('stg_thelook__distribution_centers') }}

),

enriched as (

    select
        oi.order_item_id,
        oi.order_id,
        oi.user_id,
        oi.product_id,
        oi.inventory_item_id,

        oi.item_status,
        o.order_status,

        o.created_at as order_created_at,
        oi.created_at as order_item_created_at,
        oi.shipped_at,
        oi.delivered_at,
        oi.returned_at,

        case
            when oi.item_status = 'Cancelled' then true
            else false
        end as is_cancelled,

        case
            when oi.returned_at is not null then true
            else false
        end as is_returned,

        case
            when oi.shipped_at is not null then true
            else false
        end as is_shipped,

        case
            when oi.delivered_at is not null then true
            else false
        end as is_delivered,

        timestamp_diff(
            oi.shipped_at,
            o.created_at,
            hour
        ) as hours_to_ship,

        timestamp_diff(
            oi.delivered_at,
            o.created_at,
            hour
        ) as hours_to_delivery,

        timestamp_diff(
            oi.returned_at,
            oi.delivered_at,
            hour
        ) as hours_to_return,

        oi.sale_price,
        ii.inventory_cost,

        oi.sale_price - ii.inventory_cost as gross_margin,

        safe_divide(
            oi.sale_price - ii.inventory_cost,
            oi.sale_price
        ) as gross_margin_pct,

        p.product_category,
        p.product_name,
        p.product_brand,
        p.department,
        p.sku,

        u.age as customer_age,
        u.gender as customer_gender,
        u.city as customer_city,
        u.state as customer_state,
        u.country as customer_country,
        u.traffic_source,

        dc.distribution_center_id,
        dc.distribution_center_name

    from order_items oi

    left join inventory_items ii
        on oi.inventory_item_id = ii.inventory_item_id

    left join products p
        on oi.product_id = p.product_id

    left join orders o
        on oi.order_id = o.order_id

    left join users u
        on oi.user_id = u.user_id

    left join distribution_centers dc
        on ii.distribution_center_id = dc.distribution_center_id

)

select *
from enriched
