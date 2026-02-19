ARG BASE_IMAGE=dbt-runtime-base
FROM ${BASE_IMAGE}

ARG VERSION="dev"
ARG VCS_REF="unknown"
ARG BUILD_DATE="unknown"
ARG SOURCE="unknown"

LABEL org.opencontainers.image.title="dbt-runtime-core" \
      org.opencontainers.image.description="dbt-core runtime image with standardized entrypoint and profile rendering" \
      org.opencontainers.image.source=$SOURCE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$VERSION

ARG DBT_CORE_VERSION=1.8.0
RUN pip install --no-cache-dir "dbt-core==${DBT_CORE_VERSION}"

COPY --chown=dbtuser:dbtuser scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh /usr/local/bin/render_profiles/*.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--version"]
