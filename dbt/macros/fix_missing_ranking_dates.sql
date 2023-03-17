{% macro fix_missing_ranking_dates() %}

MERGE INTO
    {{ source('dev', 'rankings_raw') }} AS T
USING (
    SELECT
        m.date_week as date,
        r.rankings
    FROM
        {{ ref('missing_ranking_dates') }} AS m
        JOIN {{ source('dev', 'rankings_raw') }} AS r ON r.date = (
            SELECT 
                MAX(r2.date)
            FROM 
                dev.rankings_raw as r2
            WHERE
                r2.date < m.date_week AND
                r2.rankings:total::int > 0 AND
                (r2.date < '1990-01-01' OR r2.rankings:rows[0]:points::int != 0)
        )
) AS S ON 
    T.date = S.date
WHEN MATCHED THEN
    UPDATE SET T.rankings = S.rankings

{% endmacro %}