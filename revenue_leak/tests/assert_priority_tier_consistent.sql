select *
from {{ ref('mart_leak_priority') }}
where
    (priority_score >= 75
        and priority_tier != 'P1 - Critical Intervention')

    or (priority_score >= 50
        and priority_score < 75
        and priority_tier != 'P2 - High Priority')

    or (priority_score >= 25
        and priority_score < 50
        and priority_tier != 'P3 - Monitor')

    or (priority_score < 25
        and priority_tier != 'Low Priority')
