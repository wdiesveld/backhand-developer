WITH

rankings_raw AS (
    SELECT * FROM {{ source('dev', 'rankings_raw') }}
),

final AS (
    SELECT
        r.date AS ranking_date,
        r2.value:name::varchar as player_name,
        r2.value:rank::int as player_rank,
        r2.value:points::double as player_points
    FROM
        rankings_raw r
        JOIN LATERAL flatten(r.rankings:rows) r2
)

SELECT * FROM final
