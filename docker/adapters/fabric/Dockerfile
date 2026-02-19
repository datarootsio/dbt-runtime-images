ARG CORE_IMAGE=dbt-runtime-core
FROM ${CORE_IMAGE}

ARG DBT_FABRIC_VERSION=1.8.0

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

RUN pip install --no-cache-dir "dbt-fabric==${DBT_FABRIC_VERSION}"

