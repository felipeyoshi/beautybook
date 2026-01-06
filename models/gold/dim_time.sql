{{ config(materialized='table') }}

with hours as (
  select 0 as hour_of_day union all
  select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all
  select 6 union all select 7 union all select 8 union all select 9 union all select 10 union all select 11 union all
  select 12 union all select 13 union all select 14 union all select 15 union all select 16 union all select 17 union all
  select 18 union all select 19 union all select 20 union all select 21 union all select 22 union all select 23
),

final as (
  select
    {{ dbt_utils.generate_surrogate_key(['hour_of_day']) }} as time_id,
    hour_of_day,
    case
      when hour_of_day between 5 and 11 then 'morning'
      when hour_of_day between 12 and 16 then 'afternoon'
      when hour_of_day between 17 and 21 then 'evening'
      else 'night'
    end as time_bucket
  from hours
)

select * from final
