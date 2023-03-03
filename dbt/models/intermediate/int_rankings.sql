WITH 

rankings AS (
    SELECT * FROM {{ ref('stg_rankings') }}
),

ranking_dates AS (
    SELECT * FROM {{ ref('ranking_dates') }}
),

final AS (
    SELECT
        r.*
    FROM
        rankings AS r 
        JOIN ranking_dates as d ON r.ranking_date = d.date_week
)

SELECT * FROM final