{#
    These are the column lists used as part of the upload macros - the order here should be the same
    as the order in each individual `upload_dataset` macro.
#}
{% macro get_column_name_list(dataset) -%}

    {% if dataset == "exposures" %}

        (
            command_invocation_id,
            node_id,
            run_started_at,
            name,
            type,
            owner,
            maturity,
            path,
            description,
            url,
            package_name,
            depends_on_nodes,
            tags,
            checksum,
            all_results,
            dbt_cloud_environment_name,
            dbt_cloud_environment_type
        )

    {% elif dataset == "invocations" %}

        (
            command_invocation_id,
            dbt_version,
            project_name,
            run_started_at,
            dbt_command,
            full_refresh_flag,
            target_profile_name,
            target_name,
            target_schema,
            target_threads,
            dbt_cloud_project_id,
            dbt_cloud_job_id,
            dbt_cloud_run_id,
            dbt_cloud_run_reason_category,
            dbt_cloud_run_reason,
            dbt_cloud_environment_name,
            dbt_cloud_environment_type,
            dbt_cloud_environment_id,
            dbt_cloud_account_id,
            env_vars,
            dbt_vars,
            invocation_args,
            dbt_custom_envs
        )

    {% elif dataset == "model_executions" %}

        (
            command_invocation_id,
            node_id,
            run_started_at,
            was_full_refresh,
            thread_id,
            status,
            compile_started_at,
            query_completed_at,
            total_node_runtime,
            rows_affected,
            {% if target.type == "bigquery" %} bytes_processed,
            {% endif %}
            materialization,
            {% if target.type == "sqlserver" %} "schema",
            {% else %} schema,
            {% endif %}
            name,
            alias,
            message,
            adapter_response
        )

    {% elif dataset == "models" %}

        (
            command_invocation_id,
            node_id,
            run_started_at,
            {% if target.type == "sqlserver" %} "database", "schema",
            {% else %} database, schema,
            {% endif %}
            name,
            depends_on_nodes,
            package_name,
            path,
            checksum,
            materialization,
            tags,
            meta,
            alias,
            all_results,
            dbt_cloud_environment_name,
            dbt_cloud_environment_type
        )

    {% elif dataset == "seed_executions" %}

        (
            command_invocation_id,
            node_id,
            run_started_at,
            was_full_refresh,
            thread_id,
            status,
            compile_started_at,
            query_completed_at,
            total_node_runtime,
            rows_affected,
            materialization,
            {% if target.type == "sqlserver" %} "schema",
            {% else %} schema,
            {% endif %}
            name,
            alias,
            message,
            adapter_response
        )

    {% elif dataset == "seeds" %}

        (
            command_invocation_id,
            node_id,
            run_started_at,
            {% if target.type == "sqlserver" %} "database", "schema",
            {% else %} database, schema,
            {% endif %}
            name,
            package_name,
            path,
            checksum,
            meta,
            alias,
            all_results,
            dbt_cloud_environment_name,
            dbt_cloud_environment_type 
        )

    {% elif dataset == "snapshot_executions" %}

        (
            command_invocation_id,
            node_id,
            run_started_at,
            was_full_refresh,
            thread_id,
            status,
            compile_started_at,
            query_completed_at,
            total_node_runtime,
            rows_affected,
            materialization,
            {% if target.type == "sqlserver" %} "schema",
            {% else %} schema,
            {% endif %}
            name,
            alias,
            message,
            adapter_response
        )

    {% elif dataset == "snapshots" %}

        (
            command_invocation_id,
            node_id,
            run_started_at,
            {% if target.type == "sqlserver" %} "database", "schema",
            {% else %} database, schema,
            {% endif %}
            name,
            depends_on_nodes,
            package_name,
            path,
            checksum,
            strategy,
            meta,
            alias,
            all_results,
            dbt_cloud_environment_name,
            dbt_cloud_environment_type
        )

    {% elif dataset == "sources" %}

        (
            command_invocation_id,
            node_id,
            run_started_at,
            {% if target.type == "sqlserver" %} "database", "schema",
            {% else %} database, schema,
            {% endif %}
            source_name,
            loader,
            name,
            identifier,
            loaded_at_field,
            freshness,
            checksum,
            all_results,
            dbt_cloud_environment_name,
            dbt_cloud_environment_type 
        )

    {% elif dataset == "test_executions" %}

        (
            command_invocation_id,
            node_id,
            run_started_at,
            was_full_refresh,
            thread_id,
            status,
            compile_started_at,
            query_completed_at,
            total_node_runtime,
            rows_affected,
            failures,
            message,
            adapter_response
        )

    {% elif dataset == "tests" %}

        (
            command_invocation_id,
            node_id,
            run_started_at,
            name,
            test_name,
            test_severity_config,
            column_names,
            test_type,
            depends_on_nodes,
            package_name,
            test_path,
            tags,
            all_results,
            dbt_cloud_environment_name,
            dbt_cloud_environment_type
        )

    {% else %}

    /* No column list available */
    {% endif %}

{%- endmacro %}

