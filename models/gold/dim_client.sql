{{ config(materialized='table') }}

with base_bookings as (
  select * from {{ source(var('raw_source_name'), 'bookings') }}
),

base_messages as (
  select * from {{ source(var('raw_source_name'), 'messages') }}
),

clients as (
  select distinct client_id
  from base_bookings
  where client_id is not null

  union

  select distinct client_id
  from base_messages
  where client_id is not null
)

select
  *
from clients
