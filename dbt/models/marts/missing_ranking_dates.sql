{{ 
    config(
        materialized="ephemeral"
    )
}}

WITH

dates AS (
    SELECT * FROM {{ ref('stg_ranking_dates') }}
),

rankings AS (
    SELECT * FROM {{ ref('stg_rankings') }}
),

final AS (
    SELECT
        dates.*
    FROM
        dates
        LEFT JOIN rankings ON dates.date_week = rankings.ranking_date
    WHERE
        rankings.player_id IS NULL
)

SELECT * from final