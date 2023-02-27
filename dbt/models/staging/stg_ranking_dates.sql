{{
    config(materialized="table")
}}

{{ dbt_utils.date_spine(
    datepart="week",
    start_date="cast('2015-01-05' as date)",
    end_date="cast('2022-12-26' as date)"
   )
}}