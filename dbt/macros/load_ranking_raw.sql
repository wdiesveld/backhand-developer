{% macro load_ranking_raw(ranking_date) %}

{% set date_str = ranking_date|string %}
{% set date_sql = date_str[:4] ~ '-' ~ date_str[4:6] ~ '-' ~ date_str[6:8] %}

{{ log(msg="Loading ranking data from " ~ date_sql, info=True) }}

{% set query1 %}
put file://C:\projects\backhand-developer\data\rankings\rankings-{{ ranking_date }}.json @BACKHAND_DEVELOPER.DEV.RANKING_STAGE;
{% endset %}

{% set query2 %}
INSERT INTO
    dev.rankings_raw (date, rankings)
        SELECT
            '{{ date_sql }}',
            $1
        FROM
            @BACKHAND_DEVELOPER.DEV.RANKING_STAGE/rankings-{{ ranking_date }}.json
{% endset %}

{% do run_query(query1) %}
{% do run_query(query2) %}

{{ log(msg="Finished loading ranking data", info=True) }}

{% endmacro %}