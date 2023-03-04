WITH

rankings AS (
    SELECT * from {{ ref('int_rankings') }}
),

final AS (
    SELECT
        player_id,
        player_name,
        MIN(player_rank) as player_rank_max,
        MIN(ranking_date) as first_ranking,
        MAX(ranking_date) as last_ranking
    FROM
        rankings
    GROUP BY
        player_id,
        player_name
    ORDER BY
        3
)

SELECT * FROM final