ARG CORE_IMAGE=dbt-runtime-core
FROM ${CORE_IMAGE}

ARG VERSION="dev"
ARG VCS_REF="unknown"
ARG BUILD_DATE="unknown"
ARG SOURCE="unknown"

LABEL org.opencontainers.image.title="dbt-runtime-databricks" \
      org.opencontainers.image.description="dbt runtime image with Databricks adapter" \
      org.opencontainers.image.source=$SOURCE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$VERSION

ARG DBT_DATABRICKS_VERSION=1.8.0
RUN pip install --no-cache-dir "dbt-databricks==${DBT_DATABRICKS_VERSION}"
