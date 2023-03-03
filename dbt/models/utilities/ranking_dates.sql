{{
    config(materialized="table")
}}

WITH

omitted AS (
    SELECT * FROM {{ ref('ranking_dates_omitted') }}
),

date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="week",
        start_date="cast('" ~ var('start_date') ~ "' as date)",
        end_date="cast(DATEADD(day, 7, CURRENT_DATE()) as date)"
    )
    }}
),

final AS (
    SELECT
        *
    FROM
        date_spine
    WHERE
        date_week NOT IN (
            SELECT ranking_date_omit from omitted
        )
)

SELECT * FROM final