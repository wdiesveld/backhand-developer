WITH

rankings AS (
    SELECT * FROM {{ ref('int_rankings') }}
),

final AS (
    SELECT
        r.ranking_date,
        r.player_rank,
        r.player_name,
        r.player_points
    FROM
        rankings AS r
    WHERE
        r.ranking_date = (
            SELECT
                MAX(r2.ranking_date)
            FROM
                rankings AS r2
        )
    ORDER BY
        r.player_rank
)

SELECT * FROM final