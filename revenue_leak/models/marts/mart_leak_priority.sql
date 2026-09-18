{{ config(
    materialized='table'
) }}

with base as (

    select
        product_category,
        order_item_id,
        gross_revenue,
        gross_margin,
        direct_leak_amount,
        has_direct_leak
    from {{ ref('fct_revenue_leak') }}

),

category_metrics as (

    select
        product_category,

        count(*) as total_items,

        countif(has_direct_leak) as leaking_items,

        sum(gross_revenue) as gross_revenue,

        sum(direct_leak_amount) as direct_leak_amount,

        sum(greatest(gross_margin, 0)) as positive_margin_exposure,

        safe_divide(
            countif(has_direct_leak),
            count(*)
        ) as leaking_item_rate,

        safe_divide(
            sum(direct_leak_amount),
            sum(gross_revenue)
        ) as revenue_leak_rate

    from base
    group by 1

),

shares as (

    select
        *,

        safe_divide(
            direct_leak_amount,
            sum(direct_leak_amount) over ()
        ) as leakage_share,

        safe_divide(
            positive_margin_exposure,
            sum(positive_margin_exposure) over ()
        ) as margin_exposure_share,

        safe_divide(
            total_items,
            sum(total_items) over ()
        ) as volume_share

    from category_metrics

),

normalized as (

    select
        *,

        safe_divide(
            leakage_share,
            max(leakage_share) over ()
        ) as leakage_burden_score,

        safe_divide(
            margin_exposure_share,
            max(margin_exposure_share) over ()
        ) as margin_exposure_score,

        safe_divide(
            volume_share,
            max(volume_share) over ()
        ) as volume_score,

        safe_divide(
            leaking_item_rate,
            max(leaking_item_rate) over ()
        ) as leak_rate_score

    from shares

),

scored as (

    select
        *,

        round(
            100 * (
                0.50 * leakage_burden_score
                + 0.20 * margin_exposure_score
                + 0.20 * volume_score
                + 0.10 * leak_rate_score
            ),
            2
        ) as priority_score

    from normalized

)

select
    *,

    case
        when priority_score >= 75
            then 'P1 - Critical Intervention'
        when priority_score >= 50
            then 'P2 - High Priority'
        when priority_score >= 25
            then 'P3 - Monitor'
        else 'Low Priority'
    end as priority_tier

from scored

