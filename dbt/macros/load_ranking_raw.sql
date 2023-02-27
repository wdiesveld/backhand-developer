{% macro load_ranking_raw(ranking_date) %}

{{ log(msg="Loading ranking data from " ~ ranking_date, info=True) }}

{% set query1 %}
put file://C:\projects\backhand-developer\data\rankings\rankings-{{ ranking_date }}.json @BACKHAND_DEVELOPER.DEV.RANKING_STAGE;
{% endset %}

{% set query2 %}
INSERT INTO
    dev.rankings_raw (date, rankings)
        SELECT
            '{{ ranking_date }}',
            $1
        FROM
            @BACKHAND_DEVELOPER.DEV.RANKING_STAGE/rankings-{{ ranking_date }}.json
{% endset %}

{% do run_query(query1) %}
{% do run_query(query2) %}

{{ log(msg="Finished loading ranking data", info=True) }}

{% endmacro %}