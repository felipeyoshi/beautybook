{% macro time_diff_seconds(start_ts, end_ts) %}
  {{ adapter.dispatch('time_diff_seconds', 'beautybook_dbt')(start_ts, end_ts) }}
{% endmacro %}

{% macro default__time_diff_seconds(start_ts, end_ts) %}
  -- If your adapter errors, override with an adapter-specific macro.
  datediff(second, {{ start_ts }}, {{ end_ts }})
{% endmacro %}
