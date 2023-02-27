WITH

rankings AS (
    SELECT * from {{ ref('stg_rankings') }}
),

final AS (
    SELECT
        player_id,
        player_name,
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