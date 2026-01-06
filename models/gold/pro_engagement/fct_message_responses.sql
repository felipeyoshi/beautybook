{{ config(
    materialized='incremental',
    unique_key='client_message_id'
) }}

with msgs as (
  select
    message_id,
    professional_id,
    client_id,
    thread_id,
    sender_type,
    message_sent_at
  from {{ ref('fct_messages') }}

  {% if is_incremental() %}
  where message_sent_at >= dateadd(day, -{{ var('incremental_lookback_days') }}, (select coalesce(max(client_message_sent_at), '1900-01-01') from {{ this }}))
  {% endif %}
),

sequenced as (
  select
    *,
    lead(message_id) over (partition by thread_id order by message_sent_at) as next_message_id,
    lead(sender_type) over (partition by thread_id order by message_sent_at) as next_sender_type,
    lead(message_sent_at) over (partition by thread_id order by message_sent_at) as next_message_sent_at
  from msgs
),

responses as (
  select
    professional_id,
    client_id,
    thread_id,
    message_id as client_message_id,
    message_sent_at as client_message_sent_at,
    next_message_id as pro_reply_message_id,
    next_message_sent_at as pro_reply_sent_at,
    {{ time_diff_seconds('message_sent_at', 'next_message_sent_at') }} as response_time_seconds,
    cast(message_sent_at as date) as response_date,
    extract(hour from message_sent_at) as response_hour
  from sequenced
  where sender_type = 'client'
    and next_sender_type = 'pro'
    and next_message_sent_at is not null
)

select * from responses
