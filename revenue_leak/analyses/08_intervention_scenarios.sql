with leak_baseline as (

    select
        primary_leak_type,
        round(sum(direct_leak_amount), 2) as baseline_leakage

    from {{ ref('fct_revenue_leak') }}

    where has_direct_leak = true

    group by primary_leak_type

),

scenario_rates as (

    select 0.05 as reduction_rate
    union all
    select 0.10
    union all
    select 0.20

),

scenarios as (

    select
        primary_leak_type,
        baseline_leakage,
        reduction_rate,

        round(
            baseline_leakage * reduction_rate,
            2
        ) as estimated_recoverable_revenue,

        round(
            baseline_leakage * (1 - reduction_rate),
            2
        ) as remaining_leakage

    from leak_baseline

    cross join scenario_rates

)

select
    concat(
        cast(round(reduction_rate * 100) as string),
        '% ',
        primary_leak_type,
        ' Reduction'
    ) as scenario_name,

    primary_leak_type,
    baseline_leakage,

    round(
        reduction_rate * 100,
        0
    ) as reduction_rate_pct,

    estimated_recoverable_revenue,
    remaining_leakage

from scenarios

order by
    primary_leak_type,
    reduction_rate
