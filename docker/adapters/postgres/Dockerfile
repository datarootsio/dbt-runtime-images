ARG CORE_IMAGE=dbt-runtime-core
FROM ${CORE_IMAGE}

ARG VERSION="dev"
ARG VCS_REF="unknown"
ARG BUILD_DATE="unknown"
ARG SOURCE="unknown"

LABEL org.opencontainers.image.title="dbt-runtime-postgres" \
      org.opencontainers.image.description="dbt runtime image with Postgres adapter" \
      org.opencontainers.image.source=$SOURCE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$VERSION

USER root
RUN set -eux; \
  if command -v apt-get >/dev/null 2>&1; then \
    apt-get update; \
    apt-get install -y --no-install-recommends gcc build-essential libpq-dev python3-dev; \
    rm -rf /var/lib/apt/lists/*; \
  elif command -v apk >/dev/null 2>&1; then \
    apk add --no-cache gcc musl-dev postgresql-dev python3-dev; \
  else \
    echo "Unsupported base image: no apt-get or apk found"; exit 1; \
  fi

USER dbtuser

ARG DBT_POSTGRES_VERSION=1.8.0
RUN pip install --no-cache-dir "dbt-postgres==${DBT_POSTGRES_VERSION}"