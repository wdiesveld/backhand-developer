WITH

rankings AS (
    SELECT * FROM {{ ref('int_rankings') }}
),

players AS (
    SELECT * FROM {{ ref('int_players') }}
),

final AS (
    SELECT
        *
    FROM
        rankings
    WHERE
        player_id IN (
            SELECT 
                player_id 
            FROM
                players
            WHERE
                player_rank_max <= 10
        )    
)

SELECT * FROM final
