{{ 
    config(
        materialized="view"
    )
}}

WITH

dates AS (
    SELECT * FROM {{ ref('ranking_dates') }}
),

rankings AS (
    SELECT * FROM {{ ref('stg_rankings') }}
),

final AS (
    SELECT
        dates.date_week
    FROM
        dates
        LEFT JOIN rankings ON dates.date_week = rankings.ranking_date
    WHERE
        rankings.player_id IS NULL OR
        (rankings.ranking_date >= '1990-01-01' AND rankings.player_points = 0 AND rankings.player_rank = 1)
    ORDER BY
        1
)

SELECT * from final