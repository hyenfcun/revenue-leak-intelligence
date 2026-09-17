select *
from {{ ref('int_order_items_enriched') }}
where gross_margin_pct < 0
   or gross_margin_pct > 1
