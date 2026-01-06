{{ config(materialized='table') }}

with spine as (
  {{ dbt_utils.date_spine(
      datepart="day",
      start_date="cast('" ~ var('date_spine_start') ~ "' as date)",
      end_date="cast('" ~ var('date_spine_end') ~ "' as date)"
  ) }}
),

final as (
  select
    {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_id,
    cast(date_day as date) as date_day,
    extract(year from date_day) as year,
    extract(month from date_day) as month,
    extract(day from date_day) as day,
    extract(dow from date_day) as day_of_week,
    case extract(dow from date_day)
      when 0 then 'Sunday'
      when 1 then 'Monday'
      when 2 then 'Tuesday'
      when 3 then 'Wednesday'
      when 4 then 'Thursday'
      when 5 then 'Friday'
      when 6 then 'Saturday'
    end as day_name,
    date_trunc('week', date_day) as week_start_date,
    date_trunc('month', date_day) as month_start_date,
    case when extract(dow from date_day) in (0,6) then true else false end as is_weekend
  from spine
)

select * from final
