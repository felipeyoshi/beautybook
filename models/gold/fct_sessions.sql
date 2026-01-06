{{ config(
    materialized='incremental',
    unique_key='session_id'
) }}

with base as (
  select * from {{ source(var('raw_source_name'), 'sessions') }}
),

enriched as (
  select
    session_id,
    pro_id as professional_id,
    session_start_at,
    session_end_at,
    cast(session_start_at as date) as session_start_date,
    extract(hour from session_start_at) as session_start_hour,
    platform,
    device_type,
    pages_viewed,
    calendar_views,
    messages_opened,
    profile_edits,
    photos_uploaded,
    {{ time_diff_seconds('session_start_at', 'session_end_at') }} as session_duration_seconds
  from base
)

select * from enriched

{% if is_incremental() %}
where session_start_at >= dateadd(day, -{{ var('incremental_lookback_days') }}, (select max(session_start_at) from {{ this }}))
{% endif %}
