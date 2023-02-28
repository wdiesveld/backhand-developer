{% macro fix_missing_ranking_dates() %}

    {% set fix_query %}
        MERGE INTO
            {{ source('dev', 'rankings_raw') }} AS T
        USING (
            SELECT
                m.date_week as date,
                r.rankings
            FROM
                {{ ref('missing_ranking_dates') }} AS m
                JOIN {{ source('dev', 'rankings_raw') }} AS r ON m.date_week = DATEADD(day, 7, r.date)
        ) AS S ON 
            T.date = S.date
        WHEN MATCHED THEN
            UPDATE SET T.rankings = S.rankings
    {% endset %}

    {% set result = run_query(fix_query) %}

    {{ log(result, info=True) }}

{% endmacro %}