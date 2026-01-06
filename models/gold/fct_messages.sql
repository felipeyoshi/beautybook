{{ config(
    materialized='incremental',
    unique_key='message_id'
) }}

with base as (
  select * from {{ source(var('raw_source_name'), 'messages') }}
),

enriched as (
  select
    message_id,
    pro_id as professional_id,
    client_id,
    thread_id,
    lower(sender_type) as sender_type,
    message_type,
    has_attachment,
    booking_id,
    message_sent_at,
    message_read_at,
    cast(message_sent_at as date) as message_sent_date,
    extract(hour from message_sent_at) as message_sent_hour
  from base
)

select * from enriched

{% if is_incremental() %}
where message_sent_at >= dateadd(day, -{{ var('incremental_lookback_days') }}, (select max(message_sent_at) from {{ this }}))
{% endif %}
