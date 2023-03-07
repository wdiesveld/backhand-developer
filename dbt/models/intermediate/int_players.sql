WITH

rankings AS (
    SELECT * from {{ ref('int_rankings') }}
),

final AS (
    SELECT
        player_id,
        player_name,
        player_best_rank,
        MIN(ranking_date) as first_ranking,
        MAX(ranking_date) as last_ranking
    FROM
        rankings
    GROUP BY
        player_id,
        player_name,
        player_best_rank
    ORDER BY
        3
)

SELECT * FROM final