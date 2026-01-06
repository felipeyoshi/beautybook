
{{ config(materialized='table') }}

with base as (
  select * from {{ source(var('raw_source_name'), 'pros') }}
),

derived as (
  select
    pro_id as professional_id,
    email,
    first_name,
    last_name,
    business_name,
    service_category,
    city,
    state,
    zip_code,
    signup_date,
    datediff(day, signup_date, current_date) as tenure_days,
    case
      when signup_date is not null and year(signup_date) between 2021 and 2025
        then year(signup_date)
      else null
    end as cohort,
    subscription_tier,
    is_active,
    profile_completeness_pct,
    avg_rating,
    total_reviews
  from base
)

select * from derived
