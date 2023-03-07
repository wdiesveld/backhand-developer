WITH

rankings AS (
    SELECT * FROM {{ ref('int_rankings_normalized') }}
),

semi_final AS (
    SELECT
        ranking_date,
        ARRAY_AGG(
            OBJECT_CONSTRUCT(
                'player_id', player_id,
                'player_name', player_name,
                'player_rank', player_rank,
                'player_points_normalized', player_points_normalized
            )
        ) WITHIN GROUP (
            ORDER BY player_id
        ) AS rankings
    FROM
        rankings
    GROUP BY
        ranking_date
    ORDER BY
        ranking_date
),

final AS (
    SELECT
        ARRAY_AGG(
            OBJECT_CONSTRUCT(
                'ranking_date', ranking_date,
                'rankings', rankings
            )
        ) WITHIN GROUP (
            ORDER BY ranking_date
        ) AS ranking_data
    FROM
        semi_final
)

SELECT * FROM final
