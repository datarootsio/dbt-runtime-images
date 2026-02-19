#!/usr/bin/env bash
set -euo pipefail

: "${DBT_PROFILES_DIR:?Missing DBT_PROFILES_DIR}"
: "${DBT_TARGET:?Missing DBT_TARGET}"

: "${FABRIC_SERVER:?Missing FABRIC_SERVER}"
: "${FABRIC_DATABASE:?Missing FABRIC_DATABASE}"
: "${FABRIC_SCHEMA:?Missing FABRIC_SCHEMA}"

FABRIC_DRIVER="${FABRIC_DRIVER:-ODBC Driver 18 for SQL Server}"
FABRIC_PORT="${FABRIC_PORT:-1433}"

# Modern auth first.
# Supported values are the ones documented by dbt-fabric:
#   ServicePrincipal (recommended for automation)
#   auto | environment | CLI (token-based / identity-based, avoids static secrets when available)
# Fallback (interactive):
#   ActiveDirectoryPassword (requires FABRIC_USER + FABRIC_PASSWORD)
FABRIC_AUTHENTICATION="${FABRIC_AUTHENTICATION:-ServicePrincipal}"

auth_block=""
case "${FABRIC_AUTHENTICATION}" in
  ServicePrincipal)
    : "${FABRIC_TENANT_ID:?Missing FABRIC_TENANT_ID}"
    : "${FABRIC_CLIENT_ID:?Missing FABRIC_CLIENT_ID}"
    : "${FABRIC_CLIENT_SECRET:?Missing FABRIC_CLIENT_SECRET}"
    auth_block=$(cat <<EOF
      authentication: ServicePrincipal
      tenant_id: ${FABRIC_TENANT_ID}
      client_id: ${FABRIC_CLIENT_ID}
      client_secret: ${FABRIC_CLIENT_SECRET}
EOF
)
    ;;
  auto|environment|CLI)
    auth_block=$(cat <<EOF
      authentication: ${FABRIC_AUTHENTICATION}
EOF
)
    ;;
  ActiveDirectoryPassword)
    : "${FABRIC_USER:?Missing FABRIC_USER}"
    : "${FABRIC_PASSWORD:?Missing FABRIC_PASSWORD}"
    auth_block=$(cat <<EOF
      authentication: ActiveDirectoryPassword
      user: ${FABRIC_USER}
      password: ${FABRIC_PASSWORD}
EOF
)
    ;;
  *)
    echo "Unsupported FABRIC_AUTHENTICATION: ${FABRIC_AUTHENTICATION}" >&2
    exit 1
    ;;
esac

# Connection encryption defaults to encrypt=true, trust_cert=false (as per dbt-fabric docs with ODBC Driver 18).
FABRIC_ENCRYPT="${FABRIC_ENCRYPT:-true}"
FABRIC_TRUST_CERT="${FABRIC_TRUST_CERT:-false}"

cat > "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
default:
  target: ${DBT_TARGET}
  outputs:
    ${DBT_TARGET}:
      type: fabric
      driver: '${FABRIC_DRIVER}'
      server: ${FABRIC_SERVER}
      port: ${FABRIC_PORT}
      database: ${FABRIC_DATABASE}
      schema: ${FABRIC_SCHEMA}
${auth_block}
      encrypt: ${FABRIC_ENCRYPT}
      trust_cert: ${FABRIC_TRUST_CERT}
      threads: ${DBT_THREADS:-4}
EOP
