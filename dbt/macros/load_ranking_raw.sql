{% macro load_ranking_raw(ranking_date) %}

{{ log(msg="Uploading ranking data from " ~ ranking_date, info=True) }}

{% set query1 %}
PUT file://C:\projects\backhand-developer\data\rankings\rankings-{{ ranking_date }}.json @BACKHAND_DEVELOPER.DEV.RANKING_STAGE OVERWRITE=TRUE;
{% endset %}

{% set query2 %}
DELETE FROM {{ source('dev', 'rankings_raw') }} WHERE date = '{{ ranking_date }}'
{% endset %}

{% set query3 %}
INSERT INTO
    {{ source('dev', 'rankings_raw') }} (date, rankings)
        SELECT
            '{{ ranking_date }}',
            $1
        FROM
            @BACKHAND_DEVELOPER.DEV.RANKING_STAGE/rankings-{{ ranking_date }}.json
{% endset %}

{% do run_query(query1) %}

{{ log(msg="Loading data into rankings_raw", info=True) }}

{% do run_query(query2) %}
{% do run_query(query3) %}

{{ log(msg="Finished loading ranking data", info=True) }}

{% endmacro %}