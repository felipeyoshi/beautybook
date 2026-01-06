{{ config(
    materialized='incremental',
    unique_key='booking_id'
) }}

with base as (
  select * from {{ source(var('raw_source_name'), 'bookings') }}
),

enriched as (
  select
    booking_id,
    pro_id as professional_id,
    client_id,
    service_name,
    booking_status,
    booking_created_at,
    cast(booking_created_at as date) as booking_created_date,
    extract(hour from booking_created_at) as booking_created_hour,
    appointment_date,
    appointment_start_time,
    appointment_end_time,
    booking_amount,
    tip_amount,
    payment_status,
    cancellation_reason,
    is_first_time_client
  from base
)

select * from enriched

{% if is_incremental() %}
where booking_created_at >= dateadd(day, -{{ var('incremental_lookback_days') }}, (select max(booking_created_at) from {{ this }}))
{% endif %}