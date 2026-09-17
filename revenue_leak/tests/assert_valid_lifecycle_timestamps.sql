select *
from {{ ref('int_order_items_enriched') }}
where
    (shipped_at is not null and shipped_at < order_created_at)
    or
    (delivered_at is not null and delivered_at < order_created_at)
    or
    (
        returned_at is not null
        and delivered_at is not null
        and returned_at < delivered_at
    )
