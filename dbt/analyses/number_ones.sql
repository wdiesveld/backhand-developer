WITH 

rankings AS (
    SELECT * FROM {{ ref('int_rankings') }}
),

final AS (
    SELECT
        ranking_date,
        player_name
    FROM
        rankings
    WHERE
        player_rank = 1
    ORDER BY
        ranking_date
)

SELECT * FROM final
