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
        player_best_rank <= 1
)

SELECT * FROM final
