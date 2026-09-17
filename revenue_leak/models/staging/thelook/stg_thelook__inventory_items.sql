with source as (

    select *
    from {{ source('thelook', 'inventory_items') }}

),

renamed as (

    select
        id as inventory_item_id,
        product_id,
        created_at as inventory_created_at,
        sold_at as inventory_sold_at,
        cast(cost as numeric) as inventory_cost,
        product_category,
        product_name,
        product_brand,
        cast(product_retail_price as numeric) as product_retail_price,
        product_department,
        product_sku,
        product_distribution_center_id as distribution_center_id

    from source

)

select *
from renamed
