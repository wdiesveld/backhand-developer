WITH

rankings AS (
    SELECT * FROM {{ ref('int_rankings') }}
),

final AS (
    SELECT
        *
    FROM
        rankings
    WHERE
        player_best_rank <= 10
)

SELECT * FROM final
