#!/usr/bin/env bash
set -euo pipefail

: "${SNOWFLAKE_ACCOUNT:?Missing SNOWFLAKE_ACCOUNT}"
: "${SNOWFLAKE_USER:?Missing SNOWFLAKE_USER}"
: "${SNOWFLAKE_PASSWORD:?Missing SNOWFLAKE_PASSWORD}"
: "${SNOWFLAKE_ROLE:?Missing SNOWFLAKE_ROLE}"
: "${SNOWFLAKE_DATABASE:?Missing SNOWFLAKE_DATABASE}"
: "${SNOWFLAKE_WAREHOUSE:?Missing SNOWFLAKE_WAREHOUSE}"
: "${SNOWFLAKE_SCHEMA:?Missing SNOWFLAKE_SCHEMA}"

cat > "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
default:
  target: ${DBT_TARGET}
  outputs:
    ${DBT_TARGET}:
      type: snowflake
      account: ${SNOWFLAKE_ACCOUNT}
      user: ${SNOWFLAKE_USER}
      password: ${SNOWFLAKE_PASSWORD}
      role: ${SNOWFLAKE_ROLE}
      database: ${SNOWFLAKE_DATABASE}
      warehouse: ${SNOWFLAKE_WAREHOUSE}
      schema: ${SNOWFLAKE_SCHEMA}
      threads: ${DBT_THREADS:-4}
EOP
