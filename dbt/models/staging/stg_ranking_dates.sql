{{
    config(materialized="table")
}}

{{ dbt_utils.date_spine(
    datepart="week",
    start_date="cast('2012-01-02' as date)",
    end_date="cast(DATEADD(day, 7, CURRENT_DATE()) as date)"
   )
}}