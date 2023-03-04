WITH

rankings AS (
    SELECT * FROM {{ ref('int_rankings_normalized') }}
),

final AS (
    SELECT
        ranking_date,
        player_id,
        player_name,
        player_rank,
        player_points_normalized
    FROM
        rankings
    ORDER BY
        ranking_date,
        player_id
)

SELECT * FROM final
