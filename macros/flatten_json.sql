{% macro flatten_json(model_name, json_column) %}

{% set json_column_flatten %}

SELECT DISTINCT 
    json.key as column_name

FROM {{ model_name }},

lateral flatten(input=>{{ json_column }}) json
{% endset %}

{% set results = run_query(json_column_flatten) %}


{% if execute %}
{% set results_list = results.columns[0].values() %}
{% else %}
{% set results_list = [] %}
{% endif %}

SELECT
*,

{% for column_name in results_list %}
{{ json_column }}:{{column_name}} as {{column_name}}{% if not loop.last %},{% endif %}
{% endfor %}

FROM {{ model_name }}

{% endmacro %}