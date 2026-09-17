with source as (

    select *
    from {{ source('thelook', 'products') }}

),

renamed as (

    select
        id as product_id,
        cast(cost as numeric) as product_cost,
        category as product_category,
        name as product_name,
        brand as product_brand,
        cast(retail_price as numeric) as retail_price,
        department,
        sku,
        distribution_center_id

    from source

)

select *
from renamed
