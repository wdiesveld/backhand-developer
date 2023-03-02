{{
    config(
        materialized="incremental",
        unique_key="id"
    )
}}

WITH

rankings_raw AS (
    SELECT * FROM {{ source('dev', 'rankings_raw') }}
),

final AS (
    SELECT
        r.date || '-' || r2.value:playerId::string as id,
        r.date AS ranking_date,
        r2.value:playerId::int as player_id,
        r2.value:name::varchar as player_name,
        r2.value:rank::int as player_rank,
        r2.value:points::double as player_points
    FROM
        rankings_raw r
        JOIN LATERAL flatten(r.rankings:rows) r2
{% if is_incremental() %}
    WHERE
        r.date > (SELECT MAX(ranking_date) FROM {{ this }})
{% endif %}
)

SELECT * FROM final
