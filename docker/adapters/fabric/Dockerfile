ARG CORE_IMAGE=dbt-runtime-core
FROM ${CORE_IMAGE}

ARG DBT_FABRIC_VERSION=1.8.0

USER root

# Install Microsoft ODBC Driver 18 + unixODBC runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    unixodbc \
  && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg \
  && curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && apt-get update \
  && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
  && rm -rf /var/lib/apt/lists/*

USER dbtuser

RUN pip install --no-cache-dir "dbt-fabric==${DBT_FABRIC_VERSION}"

