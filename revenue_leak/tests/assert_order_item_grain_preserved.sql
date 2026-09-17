with staging as (

    select
        count(*) as row_count,
        count(distinct order_item_id) as distinct_items
    from {{ ref('stg_thelook__order_items') }}

),

intermediate as (

    select
        count(*) as row_count,
        count(distinct order_item_id) as distinct_items
    from {{ ref('int_order_items_enriched') }}

)

select
    staging.row_count as staging_rows,
    intermediate.row_count as intermediate_rows,
    staging.distinct_items as staging_distinct_items,
    intermediate.distinct_items as intermediate_distinct_items

from staging
cross join intermediate

where staging.row_count != intermediate.row_count
   or staging.distinct_items != intermediate.distinct_items
