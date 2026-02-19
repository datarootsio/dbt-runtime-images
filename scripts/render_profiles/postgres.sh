#!/usr/bin/env bash
set -euo pipefail

: "${DBT_PROFILES_DIR:?Missing DBT_PROFILES_DIR}"
: "${DBT_TARGET:?Missing DBT_TARGET}"

: "${PG_HOST:?Missing PG_HOST}"
: "${PG_USER:?Missing PG_USER}"
: "${PG_DATABASE:?Missing PG_DATABASE}"
: "${PG_SCHEMA:?Missing PG_SCHEMA}"

PG_PORT="${PG_PORT:-5432}"
PG_THREADS="${DBT_THREADS:-4}"
PG_AUTH_METHOD="${PG_AUTH_METHOD:-auto}"

# Modern defaults:
# - Prefer short-lived tokens or client certs over long-lived static passwords.
# - dbt-postgres still needs a "user". The difference is how we authenticate (token/cert vs static password).
#
# Supported:
# 1) Client certificate (passwordless): set PG_SSL_CERT + PG_SSL_KEY (+ optional PG_SSL_ROOTCERT)
# 2) Token-based: set PG_ACCESS_TOKEN (e.g., IAM/AAD generated token)
# 3) Password fallback: set PG_PASSWORD

use_cert="false"
use_token="false"
use_password="false"

if [[ "${PG_AUTH_METHOD}" == "cert" ]]; then
  use_cert="true"
elif [[ "${PG_AUTH_METHOD}" == "token" ]]; then
  use_token="true"
elif [[ "${PG_AUTH_METHOD}" == "password" ]]; then
  use_password="true"
else
  # auto
  if [[ -n "${PG_SSL_CERT:-}" && -n "${PG_SSL_KEY:-}" ]]; then
    use_cert="true"
  elif [[ -n "${PG_ACCESS_TOKEN:-}" ]]; then
    use_token="true"
  elif [[ -n "${PG_PASSWORD:-}" ]]; then
    use_password="true"
  else
    echo "ERROR: No Postgres auth configured. Provide one of:" >&2
    echo "  - Client cert: PG_SSL_CERT + PG_SSL_KEY (+ optional PG_SSL_ROOTCERT)" >&2
    echo "  - Token:       PG_ACCESS_TOKEN" >&2
    echo "  - Password:    PG_PASSWORD" >&2
    exit 2
  fi
fi

# SSL defaults (safe-by-default)
PG_SSLMODE="${PG_SSLMODE:-prefer}"

cat > "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
default:
  target: ${DBT_TARGET}
  outputs:
    ${DBT_TARGET}:
      type: postgres
      host: ${PG_HOST}
      user: ${PG_USER}
      port: ${PG_PORT}
      dbname: ${PG_DATABASE}
      schema: ${PG_SCHEMA}
      threads: ${PG_THREADS}
      sslmode: ${PG_SSLMODE}
EOP

if [[ "${use_cert}" == "true" ]]; then
  : "${PG_SSL_CERT:?Missing PG_SSL_CERT for cert auth}"
  : "${PG_SSL_KEY:?Missing PG_SSL_KEY for cert auth}"
  # Recommend verify-full if you provide root cert, otherwise require at least.
  if [[ "${PG_SSLMODE}" == "prefer" ]]; then
    echo "WARN: PG_SSLMODE is 'prefer' while using client certs. Consider PG_SSLMODE=verify-full." >&2
  fi

  cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      sslcert: ${PG_SSL_CERT}
      sslkey: ${PG_SSL_KEY}
EOP

  if [[ -n "${PG_SSL_ROOTCERT:-}" ]]; then
    cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      sslrootcert: ${PG_SSL_ROOTCERT}
EOP
  fi

elif [[ "${use_token}" == "true" ]]; then
  : "${PG_ACCESS_TOKEN:?Missing PG_ACCESS_TOKEN for token auth}"
  # dbt-postgres expects a "password" field; tokens are passed there.
  cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      password: ${PG_ACCESS_TOKEN}
EOP

else
  : "${PG_PASSWORD:?Missing PG_PASSWORD for password auth}"
  cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      password: ${PG_PASSWORD}
EOP
fi
