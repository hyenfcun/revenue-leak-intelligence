with source as (

    select *
    from {{ source('thelook', 'events') }}

),

renamed as (

    select
        id as event_id,
        user_id,
        sequence_number,
        session_id,
        created_at as event_created_at,
        city,
        state,
        browser,
        traffic_source,
        uri,
        event_type

    from source

)

select *
from renamed
