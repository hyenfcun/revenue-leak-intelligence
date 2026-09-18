select *
from {{ ref('mart_leak_priority') }}
where priority_score < 0
   or priority_score > 100
