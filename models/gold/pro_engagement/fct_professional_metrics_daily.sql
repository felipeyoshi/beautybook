{{ config(
    materialized='incremental',
    unique_key=['professional_id','date_day']
) }}

with session_daily as (
  select
    professional_id,
    session_start_date as date_day,
    count(*) as sessions_count,
    sum(session_duration_seconds) as session_duration_seconds_total,
    avg(session_duration_seconds) as session_duration_seconds_avg
  from {{ ref('fct_sessions') }}
  group by 1,2
),

message_daily as (
  select
    professional_id,
    message_sent_date as date_day,
    count(*) as messages_count,
    sum(case when sender_type = 'pro' then 1 else 0 end) as pro_messages_sent_count,
    sum(case when sender_type = 'client' then 1 else 0 end) as client_messages_sent_count
  from {{ ref('fct_messages') }}
  group by 1,2
),

response_daily as (
  select
    professional_id,
    response_date as date_day,
    sum(response_time_seconds) as total_response_time_seconds,
    avg(response_time_seconds) as avg_response_time_seconds,
    percentile_cont(0.5) within group (order by response_time_seconds) as median_response_time_seconds,
    sum(case when response_time_seconds <= 300 then 1 else 0 end) as responses_within_5m,
    count(*) as responses_count
  from {{ ref('fct_message_responses') }}
  group by 1,2
),

booking_daily as (
  select
    professional_id,
    booking_created_date as date_day,
    count(*) as bookings_created_count,
    sum(case when lower(booking_status) in ('completed') then 1 else 0 end) as bookings_success_count
  from {{ ref('fct_bookings') }}
  group by 1,2
),

base as (
  select
    coalesce(s.professional_id, m.professional_id, r.professional_id, b.professional_id) as professional_id,
    coalesce(s.date_day, m.date_day, r.date_day, b.date_day) as date_day
  from session_daily s
  full outer join message_daily m
    on s.professional_id = m.professional_id and s.date_day = m.date_day
  full outer join response_daily r
    on coalesce(s.professional_id,m.professional_id) = r.professional_id and coalesce(s.date_day,m.date_day) = r.date_day
  full outer join booking_daily b
    on coalesce(s.professional_id,m.professional_id,r.professional_id) = b.professional_id and coalesce(s.date_day,m.date_day,r.date_day) = b.date_day
),

final as (
  select
    base.professional_id,
    base.date_day,

    coalesce(s.sessions_count, 0) as sessions_count,
    coalesce(s.session_duration_seconds_total, 0) as session_duration_seconds_total,
    s.session_duration_seconds_avg,

    coalesce(m.messages_count, 0) as messages_count,
    coalesce(m.pro_messages_sent_count, 0) as pro_messages_sent_count,
    coalesce(m.client_messages_sent_count, 0) as client_messages_sent_count,

    r.total_response_time_seconds,
    r.avg_response_time_seconds,
    r.median_response_time_seconds,
    coalesce(r.responses_within_5m, 0) as responses_within_5m,
    coalesce(r.responses_count, 0) as responses_count,

    coalesce(b.bookings_created_count, 0) as bookings_created_count,
    coalesce(b.bookings_success_count, 0) as bookings_success_count,

    case
      when coalesce(b.bookings_created_count,0) = 0 then null
      else b.bookings_success_count * 1.0 / b.bookings_created_count
    end as conversion_rate_created_to_success
  from base
  left join session_daily s on base.professional_id=s.professional_id and base.date_day=s.date_day
  left join message_daily m on base.professional_id=m.professional_id and base.date_day=m.date_day
  left join response_daily r on base.professional_id=r.professional_id and base.date_day=r.date_day
  left join booking_daily b on base.professional_id=b.professional_id and base.date_day=b.date_day
)

select * from final

{% if is_incremental() %}
where date_day >= dateadd(day, -{{ var('incremental_lookback_days') }}, (select max(date_day) from {{ this }}))
{% endif %}
