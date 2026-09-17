with customers as (

    select
        customer_id,
        first_order_at,
        lifetime_orders
    from {{ ref('int_customer_lifecycle') }}

),

customer_economics as (

    select
        user_id as customer_id,

        sum(gross_revenue) as gross_revenue,
        sum(direct_leak_amount) as direct_leak_amount

    from {{ ref('fct_revenue_leak') }}

    where user_id is not null

    group by user_id

),

dataset_anchor as (

    select
        max(order_created_at) as analysis_timestamp
    from {{ ref('fct_revenue_leak') }}

),

customer_cohorts as (

    select
        c.customer_id,

        date_trunc(
            date(c.first_order_at),
            month
        ) as acquisition_cohort,

        c.lifetime_orders,

        e.gross_revenue,
        e.direct_leak_amount,

        date_diff(
            date(a.analysis_timestamp),
            date_trunc(date(c.first_order_at), month),
            day
        ) as cohort_age_days

    from customers c

    inner join customer_economics e
        on c.customer_id = e.customer_id

    cross join dataset_anchor a

),

cohort_summary as (

    select
        acquisition_cohort,

        max(cohort_age_days) as cohort_age_days,

        count(*) as customers,

        countif(lifetime_orders >= 2) as repeat_customers,

        safe_divide(
            countif(lifetime_orders >= 2),
            count(*)
        ) as repeat_rate,

        sum(gross_revenue) as gross_revenue,

        sum(direct_leak_amount) as direct_leak_amount,

        safe_divide(
            sum(direct_leak_amount),
            sum(gross_revenue)
        ) as leak_rate,

        avg(gross_revenue) as avg_revenue_per_customer,

        avg(direct_leak_amount) as avg_leak_per_customer

    from customer_cohorts

    group by acquisition_cohort

)

select
    acquisition_cohort,
    cohort_age_days,

    case
        when cohort_age_days >= 90
            then 'Mature'
        else 'Recent'
    end as cohort_maturity,

    customers,
    repeat_customers,

    round(repeat_rate * 100, 2)
        as repeat_rate_pct,

    round(gross_revenue, 2)
        as gross_revenue,

    round(direct_leak_amount, 2)
        as direct_leak_amount,

    round(leak_rate * 100, 2)
        as leak_rate_pct,

    round(avg_revenue_per_customer, 2)
        as avg_revenue_per_customer,

    round(avg_leak_per_customer, 2)
        as avg_leak_per_customer

from cohort_summary

order by acquisition_cohort desc
