{% macro surrogate_key(field_list) %}
    {% set fields = [] %}
    {% for field in field_list %}
        {% do fields.append("COALESCE(CAST(" ~ field ~ " AS VARCHAR), '')") %}
    {% endfor %}
    {% set fields_csv = fields | join(', ') %}
    MD5({{ fields_csv }})
{% endmacro %}