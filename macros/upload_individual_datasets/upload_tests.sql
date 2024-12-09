{% macro upload_tests(tests) -%}
    {{ return(adapter.dispatch("get_tests_dml_sql", "dbt_artifacts")(tests)) }}
{%- endmacro %}

{% macro default__get_tests_dml_sql(tests) -%}

    {% if tests != [] %}
        {% set test_values %}
        select
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(1) }},
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(2) }},
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(3) }},
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(4) }},
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(5) }},
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(6) }},
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(7) }},
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(8) }},
            {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(9)) }},
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(10) }},
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(11) }},
            {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(12)) }},
            {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(13) }},
            {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(14)) }},
            nullif({{ adapter.dispatch('column_identifier', 'dbt_artifacts')(15) }}, ''),
            nullif({{ adapter.dispatch('column_identifier', 'dbt_artifacts')(16) }}, '')
        from ( values
        {% for test in tests -%}
            {%- set test_name = '' -%}
            {%- set test_type =  '' -%}
            {%- set column_name = '' -%}

            {%- if test.test_metadata is defined -%}
                {%- set test_name = test.test_metadata.name -%}
                {%- set test_type = 'generic' -%}
                
                {%- if test_name == 'relationships' -%}
                    {%- set column_name = test.test_metadata.kwargs.field ~ ',' ~ test.test_metadata.kwargs.column_name -%}
                {%- else -%}
                    {%- set column_name = test.test_metadata.kwargs.column_name -%}
                {%- endif -%}
            {%- elif test.name is defined -%}
                {%- set test_name = test.name -%}
                {%- set test_type = 'singular' -%}
            {%- endif %}
            (
                '{{ invocation_id }}', {# command_invocation_id #}
                '{{ test.unique_id }}', {# node_id #}
                '{{ run_started_at }}', {# run_started_at #}
                '{{ test.name }}', {# name #}
                '{{ test_name }}',  {# test_name #}
                '{{ test.config.severity }}', {# test_severity_config #}
                '{{ column_name|escape }}', {# column_names #}
                '{{ test_type }}', {# test_type #}
                '{{ tojson(test.depends_on.nodes) }}', {# depends_on_nodes #}
                '{{ test.package_name }}', {# package_name #}
                '{{ test.original_file_path | replace('\\', '\\\\') }}', {# test_path #}
                '{{ tojson(test.tags) }}', {# tags #}
                '{{ test.unique_id }}'||'|'||'{{ test.name }}'||'|'||'{{ tojson(test.depends_on.nodes) }}'||'|'||'{{ test.package_name }}'||'|'||'{{ test.original_file_path | replace('\\', '\\\\') }}'||'|'||'{{ tojson(test.tags) }}'{% if var('dbt_artifacts_environment_aware', false) %}||'|'||'{{ env_var('DBT_CLOUD_ENVIRONMENT_NAME', '') }}'||'|'||'{{ env_var('DBT_CLOUD_ENVIRONMENT_TYPE', '') }}'{% endif %}, {# checksum #}
                {% if var('dbt_artifacts_exclude_all_results', false) %}
                    null
                {% else %}
                    '{{ tojson(test) | replace("\\", "\\\\") | replace("'","\\'") | replace('"', '\\"') }}' {# all_results #}
                {% endif %}
                {% if var('dbt_artifacts_environment_aware', false) %}
                    , '{{ env_var('DBT_CLOUD_ENVIRONMENT_NAME', '') }}' {# dbt_cloud_environment_name #}
                    , '{{ env_var('DBT_CLOUD_ENVIRONMENT_TYPE', '') }}' {# dbt_cloud_environment_type #}
                {% else %}
                    , null
                    , null
                {% endif %}
            )
            {%- if not loop.last %},{%- endif %}
        {%- endfor %}
        ) a
        where $13 not in (select checksum from {{ dbt_artifacts.get_relation('tests') }})
        {% endset %}
        {{ test_values }}
    {% else %} {{ return("") }}
    {% endif %}
{% endmacro -%}

{% macro bigquery__get_tests_dml_sql(tests) -%}
    {% if tests != [] %}
        {% set test_values %}
            {% for test in tests -%}
                (
                    '{{ invocation_id }}', {# command_invocation_id #}
                    '{{ test.unique_id }}', {# node_id #}
                    '{{ run_started_at }}', {# run_started_at #}
                    '{{ test.name }}', {# name #}
                    {{ tojson(test.depends_on.nodes) }}, {# depends_on_nodes #}
                    '{{ test.package_name }}', {# package_name #}
                    '{{ test.original_file_path | replace('\\', '\\\\') }}', {# test_path #}
                    {{ tojson(test.tags) }}, {# tags #}
                    {% if var('dbt_artifacts_exclude_all_results', false) %}
                        null
                    {% else %}
                        {{ adapter.dispatch('parse_json', 'dbt_artifacts')(tojson(test) | replace("\\", "\\\\") | replace("'","\\'") | replace('"', '\\"')) }} {# all_fields #}
                    {% endif %}
                )
                {%- if not loop.last %},{%- endif %}
            {%- endfor %}
        {% endset %}
        {{ test_values }}
    {% else %} {{ return("") }}
    {% endif %}
{%- endmacro %}

{% macro postgres__get_tests_dml_sql(tests) -%}
    {% if tests != [] %}
        {% set test_values %}
            {% for test in tests -%}
                (
                    '{{ invocation_id }}', {# command_invocation_id #}
                    '{{ test.unique_id }}', {# node_id #}
                    '{{ run_started_at }}', {# run_started_at #}
                    '{{ test.name }}', {# name #}
                    $${{ tojson(test.depends_on.nodes) }}$$, {# depends_on_nodes #}
                    '{{ test.package_name }}', {# package_name #}
                    '{{ test.original_file_path | replace('\\', '\\\\') }}', {# test_path #}
                    $${{ tojson(test.tags) }}$$, {# tags #}
                    {% if var('dbt_artifacts_exclude_all_results', false) %}
                        null
                    {% else %}
                        $${{ tojson(test) }}$$ {# all_results #}
                    {% endif %}
                )
                {%- if not loop.last %},{%- endif %}
            {%- endfor %}
        {% endset %}
        {{ test_values }}
    {% else %} {{ return("") }}
    {% endif %}
{%- endmacro %}


{% macro sqlserver__get_tests_dml_sql(tests) -%}

    {% if tests != [] %}
        {% set test_values %}
        select
            "1", "2", "3", "4", "5", "6", "7", "8", "9"
        from ( values
        {% for test in tests -%}
            (
                '{{ invocation_id }}', {# command_invocation_id #}
                '{{ test.unique_id }}', {# node_id #}
                '{{ run_started_at }}', {# run_started_at #}
                '{{ test.name }}', {# name #}
                '{{ tojson(test.depends_on.nodes) }}', {# depends_on_nodes #}
                '{{ test.package_name }}', {# package_name #}
                '{{ test.original_file_path }}', {# test_path #}
                '{{ tojson(test.tags) }}', {# tags #}
                {% if var('dbt_artifacts_exclude_all_results', false) %}
                    null
                {% else %}
                    '{{ tojson(test) | replace("'","''") }}' {# all_fields #}
                {% endif %}
            )
            {%- if not loop.last %},{%- endif %}
        {%- endfor %}
        ) v ("1", "2", "3", "4", "5", "6", "7", "8", "9")
        {% endset %}
        {{ test_values }}
    {% else %} {{ return("") }}
    {% endif %}
{% endmacro -%}

