{{ config(
    materialized='table'
) }}

with source as (

    select *
    from {{ ref('int_order_items_enriched') }}

),

leak_components as (

    select
        *,

        -- Revenue basis
        sale_price as gross_revenue,

        -- Canonical WK3 leakage flags
        case
            when item_status = 'Cancelled' then true
            else false
        end as leak_is_cancelled,

        case
            when item_status = 'Returned' then true
            else false
        end as leak_is_returned,

        case
            when gross_margin < 0 then true
            else false
        end as leak_is_negative_margin,

        -- Individual leakage components
        case
            when item_status = 'Cancelled'
                then sale_price
            else 0
        end as cancelled_revenue,

        case
            when item_status = 'Returned'
                then sale_price
            else 0
        end as returned_revenue,

        case
            when gross_margin < 0
                then abs(gross_margin)
            else 0
        end as margin_leakage

    from source

),

reconciled as (

    select
        *,

        cast(leak_is_cancelled as int64)
        + cast(leak_is_returned as int64)
        + cast(leak_is_negative_margin as int64)
            as leak_signal_count,

        -- Reconciled financial loss:
        -- cancellation/return revenue takes precedence over margin loss
        -- so one order item is not counted twice.
        case
            when leak_is_cancelled
                then cancelled_revenue

            when leak_is_returned
                then returned_revenue

            when leak_is_negative_margin
                then margin_leakage

            else 0
        end as direct_leak_amount,

        case
            when leak_is_cancelled
                then 'Cancellation'

            when leak_is_returned
                then 'Return'

            when leak_is_negative_margin
                then 'Negative Margin'

            else 'No Direct Leak'
        end as primary_leak_type

    from leak_components

)

select
    *,

    direct_leak_amount > 0 as has_direct_leak,

    leak_signal_count > 1 as has_overlapping_leak_signals,

    safe_divide(
        direct_leak_amount,
        gross_revenue
    ) as item_leak_rate

from reconciled

