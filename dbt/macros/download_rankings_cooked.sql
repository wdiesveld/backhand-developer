{% macro download_rankings_cooked() %}

{{ log(msg="Creating json file in stage", info=True) }}

{% set query1 %}
COPY INTO
    @BACKHAND_DEVELOPER.DEV.RANKING_STAGE/rankings-cooked.json
FROM
    (
        SELECT
            ranking_data
        FROM
            {{ ref('input_streamgraph') }}
        LIMIT
            1
    )
    OVERWRITE = TRUE
{% endset %}

{% do run_query(query1) %}


{{ log(msg="Downloading cooked ranking data from database", info=True) }}

{% set query2 %}
GET @BACKHAND_DEVELOPER.DEV.RANKING_STAGE/rankings-cooked.json file://..\data\rankings;
{% endset %}

{% do run_query(query2) %}

{% endmacro %}