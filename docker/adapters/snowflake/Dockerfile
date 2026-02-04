ARG CORE_IMAGE=dbt-runtime-core
FROM ${CORE_IMAGE}

ARG VERSION="dev"
ARG VCS_REF="unknown"
ARG BUILD_DATE="unknown"
ARG SOURCE="unknown"

LABEL org.opencontainers.image.title="dbt-runtime-snowflake" \
      org.opencontainers.image.description="dbt runtime image with Snowflake adapter" \
      org.opencontainers.image.source=$SOURCE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$VERSION

ARG DBT_SNOWFLAKE_VERSION=1.8.0
RUN pip install --no-cache-dir "dbt-snowflake==${DBT_SNOWFLAKE_VERSION}"
