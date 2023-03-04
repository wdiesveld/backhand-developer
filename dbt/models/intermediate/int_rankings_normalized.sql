WITH

rankings AS (
    SELECT * FROM {{ ref('int_rankings_top_players') }}
),

rankings_total AS (
    SELECT
        ranking_date,
        SUM(player_points) AS total_points
    FROM
        rankings
    GROUP BY
        ranking_date
),

final AS (
    SELECT
        r.*,
        r.player_points / t.total_points AS player_points_normalized
    FROM
        rankings AS r
        JOIN rankings_total as t ON r.ranking_date = t.ranking_date
)

SELECT * FROM final