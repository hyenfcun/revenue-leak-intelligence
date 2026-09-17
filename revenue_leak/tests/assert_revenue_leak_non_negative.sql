select *
from {{ ref('fct_revenue_leak') }}
where direct_leak_amount < 0

