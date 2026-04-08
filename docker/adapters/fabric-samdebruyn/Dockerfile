ARG CORE_IMAGE=dbt-runtime-core
FROM ${CORE_IMAGE}

ARG DBT_FABRIC_SAMDEBRUYN_VERSION=1.10.0

# Install Microsoft ODBC Driver 18 + unixODBC runtime (Debian/Ubuntu)
USER root
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    ca-certificates \
    unixodbc \
  ; \
  mkdir -p /usr/share/keyrings; \
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg; \
  curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list; \
  apt-get update; \
  ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18; \
  rm -rf /var/lib/apt/lists/*
USER dbtuser

ARG VERSION="dev"
ARG VCS_REF="unknown"
ARG BUILD_DATE="unknown"
ARG SOURCE="unknown"

LABEL org.opencontainers.image.title="dbt-runtime-fabric-samdebruyn" \
      org.opencontainers.image.description="dbt runtime image with dbt-fabric-samdebruyn adapter" \
      org.opencontainers.image.source=$SOURCE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$VERSION

RUN pip install --no-cache-dir "dbt-fabric-samdebruyn==${DBT_FABRIC_SAMDEBRUYN_VERSION}"

