WITH

rankings AS (
    SELECT * FROM {{ ref('int_rankings_normalized') }}
),

final AS (
    SELECT
        OBJECT_CONSTRUCT(
            'ranking_date', ranking_date,
            'rankings', ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'player_id', player_id,
                    'player_name', player_name,
                    'player_rank', player_rank,
                    'player_points_normalized', player_points_normalized
                )
            ) WITHIN GROUP (ORDER BY player_id)
        )
    FROM
        rankings
    GROUP BY
        ranking_date
    ORDER BY
        ranking_date
)

SELECT * FROM final
