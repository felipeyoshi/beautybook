{{ config(materialized='table') }}

with base as (
  select distinct 
    service_name from {{ source(var('raw_source_name'), 'bookings') }} 
  where service_name is not null
),

services as (
  select
    {{ dbt_utils.generate_surrogate_key(['service_name']) }} as service_id,
    service_name
    
  from base
)

select * from services
