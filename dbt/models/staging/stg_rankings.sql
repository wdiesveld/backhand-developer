{{
    config(
        materialized="incremental",
        unique_key="id"
    )
}}

WITH

rankings_raw AS (
    SELECT * FROM {{ source('dev', 'rankings_raw') }}
),

semi_final AS (
    SELECT
        r.date || '-' || r2.value:playerId::string as id,
        r.date AS ranking_date,
        r2.value:playerId::int as player_id,
        r2.value:name::varchar as player_name,
        r2.value:rank::int as player_rank,
        r2.value:bestRank::int as player_best_rank,
        -- make up player points for period before 1990
        CASE WHEN
            r.date < '1990-01-01' AND r2.value:points::double = 0
        THEN
            1 / r2.value:rank::int
        ELSE
            r2.value:points::double
        END AS player_points
    FROM
        rankings_raw r
        JOIN LATERAL flatten(r.rankings:rows) r2
{% if is_incremental() %}
    WHERE
        r.date > (SELECT MAX(ranking_date) FROM {{ this }})
{% endif %}
),

final AS (
    SELECT
        id,
        ranking_date,
        player_id,
        player_name,
        player_rank,
        player_best_rank,
        -- fix for player_points being 0 because of inactive ranking weeks
        CASE WHEN
            player_points = 0
        THEN
            LAG(player_points, 1) OVER (PARTITION BY player_id ORDER BY ranking_date)
        ELSE
            player_points
        END AS player_points
    FROM
        semi_final
)

SELECT * FROM final
