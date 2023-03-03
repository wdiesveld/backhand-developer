WITH

rankings AS (
    SELECT * from {{ ref('int_rankings') }}
),

final AS (
    SELECT
        player_name,
        COUNT(*) AS weeks_at_number_one
    FROM
        rankings
    WHERE
        player_rank = 1
    GROUP BY
        player_id,
        player_name
    ORDER BY
        2 DESC
)

SELECT * FROM final