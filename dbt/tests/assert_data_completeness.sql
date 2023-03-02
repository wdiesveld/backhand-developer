{{
    config(
        warn_if=">0",
        error_if=">100",
        store_failures=True,
        schema="failed_tests"
    )
}}

WITH

missing_ranking_dates as (
    SELECT * FROM {{ ref('missing_ranking_dates') }}
)

SELECT * from missing_ranking_dates
