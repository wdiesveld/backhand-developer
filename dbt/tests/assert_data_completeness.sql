{{
    config(
        warn_if=">0",
        error_if=">100"
    )
}}

WITH

dates as (
    SELECT * FROM {{ ref('stg_ranking_dates') }}
),

rankings as (
    SELECT * FROM {{ ref('stg_rankings') }}
),

final as (
    SELECT
        dates.*
    FROM
        dates
        LEFT JOIN rankings ON dates.date_week = rankings.ranking_date
    WHERE
        rankings.player_id IS NULL
)

SELECT * from final
