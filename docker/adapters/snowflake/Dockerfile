ARG CORE_IMAGE=dbt-runtime-core
FROM ${CORE_IMAGE}

ARG DBT_SNOWFLAKE_VERSION=1.8.0
RUN pip install --no-cache-dir "dbt-snowflake==${DBT_SNOWFLAKE_VERSION}"
