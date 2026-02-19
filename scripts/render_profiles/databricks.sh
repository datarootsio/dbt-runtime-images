#!/usr/bin/env bash
set -euo pipefail

: "${DBT_PROFILES_DIR:?Missing DBT_PROFILES_DIR}"
: "${DBT_TARGET:?Missing DBT_TARGET}"

: "${DATABRICKS_HOST:?Missing DATABRICKS_HOST}"
: "${DATABRICKS_HTTP_PATH:?Missing DATABRICKS_HTTP_PATH}"
: "${DATABRICKS_SCHEMA:?Missing DATABRICKS_SCHEMA}"

DBX_THREADS="${DBT_THREADS:-4}"
DBX_CATALOG="${DATABRICKS_CATALOG:-}"

# Modern defaults:
# - Prefer OAuth (M2M) where available.
# - Fall back to PAT token when needed.
#
# Supported by dbt-databricks:
#  - token (PAT): token: ...
#  - OAuth: auth_type: oauth + client_id/client_secret (AWS/GCP) or azure_client_id/azure_client_secret (Azure) citeturn2view0
DATABRICKS_AUTH_TYPE="${DATABRICKS_AUTH_TYPE:-auto}"

use_oauth="false"
use_pat="false"

if [[ "${DATABRICKS_AUTH_TYPE}" == "oauth" ]]; then
  use_oauth="true"
elif [[ "${DATABRICKS_AUTH_TYPE}" == "token" ]]; then
  use_pat="true"
else
  # auto
  if [[ -n "${DATABRICKS_AZURE_CLIENT_ID:-}" || -n "${DATABRICKS_AZURE_CLIENT_SECRET:-}" || -n "${DATABRICKS_CLIENT_ID:-}" || -n "${DATABRICKS_CLIENT_SECRET:-}" ]]; then
    use_oauth="true"
  elif [[ -n "${DATABRICKS_TOKEN:-}" ]]; then
    use_pat="true"
  else
    echo "ERROR: No Databricks auth configured. Provide one of:" >&2
    echo "  - OAuth: DATABRICKS_AUTH_TYPE=oauth + (DATABRICKS_AZURE_CLIENT_ID + DATABRICKS_AZURE_CLIENT_SECRET) OR (DATABRICKS_CLIENT_ID + DATABRICKS_CLIENT_SECRET)" >&2
    echo "  - PAT:   DATABRICKS_AUTH_TYPE=token + DATABRICKS_TOKEN" >&2
    exit 2
  fi
fi

cat > "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
default:
  target: ${DBT_TARGET}
  outputs:
    ${DBT_TARGET}:
      type: databricks
      host: ${DATABRICKS_HOST}
      http_path: ${DATABRICKS_HTTP_PATH}
      schema: ${DATABRICKS_SCHEMA}
      threads: ${DBX_THREADS}
EOP

if [[ -n "${DBX_CATALOG}" ]]; then
  cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      catalog: ${DBX_CATALOG}
EOP
fi

if [[ "${use_oauth}" == "true" ]]; then
  cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      auth_type: oauth
EOP

  # Azure Databricks uses azure_client_id / azure_client_secret keys. citeturn2view0
  if [[ -n "${DATABRICKS_AZURE_CLIENT_ID:-}" || -n "${DATABRICKS_AZURE_CLIENT_SECRET:-}" ]]; then
    : "${DATABRICKS_AZURE_CLIENT_ID:?Missing DATABRICKS_AZURE_CLIENT_ID}"
    : "${DATABRICKS_AZURE_CLIENT_SECRET:?Missing DATABRICKS_AZURE_CLIENT_SECRET}"
    cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      azure_client_id: ${DATABRICKS_AZURE_CLIENT_ID}
      azure_client_secret: ${DATABRICKS_AZURE_CLIENT_SECRET}
EOP
  else
    : "${DATABRICKS_CLIENT_ID:?Missing DATABRICKS_CLIENT_ID}"
    : "${DATABRICKS_CLIENT_SECRET:?Missing DATABRICKS_CLIENT_SECRET}"
    cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      client_id: ${DATABRICKS_CLIENT_ID}
      client_secret: ${DATABRICKS_CLIENT_SECRET}
EOP
  fi

else
  : "${DATABRICKS_TOKEN:?Missing DATABRICKS_TOKEN}"
  cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      token: ${DATABRICKS_TOKEN}
EOP
fi
