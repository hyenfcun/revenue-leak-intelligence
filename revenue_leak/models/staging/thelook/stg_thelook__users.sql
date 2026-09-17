with source as (

    select *
    from {{ source('thelook', 'users') }}

),

renamed as (

    select
        id as user_id,
        age,
        gender,
        city,
        state,
        country,
        postal_code,
        latitude,
        longitude,
        traffic_source,
        created_at as user_created_at

    from source

)

select *
from renamed
