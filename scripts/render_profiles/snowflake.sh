#!/usr/bin/env bash
set -euo pipefail

: "${DBT_PROFILES_DIR:?Missing DBT_PROFILES_DIR}"
: "${DBT_TARGET:?Missing DBT_TARGET}"

: "${SNOWFLAKE_ACCOUNT:?Missing SNOWFLAKE_ACCOUNT}"
: "${SNOWFLAKE_DATABASE:?Missing SNOWFLAKE_DATABASE}"
: "${SNOWFLAKE_WAREHOUSE:?Missing SNOWFLAKE_WAREHOUSE}"
: "${SNOWFLAKE_SCHEMA:?Missing SNOWFLAKE_SCHEMA}"

# Auth method (modern defaults)
#   keypair (recommended for automation)  -> SNOWFLAKE_PRIVATE_KEY_PATH (+ optional SNOWFLAKE_PRIVATE_KEY_PASSPHRASE)
#   oauth                                -> SNOWFLAKE_OAUTH_CLIENT_ID, SNOWFLAKE_OAUTH_CLIENT_SECRET, SNOWFLAKE_OAUTH_REFRESH_TOKEN
#   externalbrowser (interactive dev)     -> SNOWFLAKE_USER
#   password (legacy fallback)            -> SNOWFLAKE_USER, SNOWFLAKE_PASSWORD
SNOWFLAKE_AUTH_METHOD="${SNOWFLAKE_AUTH_METHOD:-keypair}"

# Role is optional (but recommended)
SNOWFLAKE_ROLE="${SNOWFLAKE_ROLE:-}"

auth_block=""
case "${SNOWFLAKE_AUTH_METHOD}" in
  keypair)
    : "${SNOWFLAKE_USER:?Missing SNOWFLAKE_USER}"
    : "${SNOWFLAKE_PRIVATE_KEY_PATH:?Missing SNOWFLAKE_PRIVATE_KEY_PATH}"
    auth_block=$(cat <<EOF
      user: ${SNOWFLAKE_USER}
      private_key_path: ${SNOWFLAKE_PRIVATE_KEY_PATH}
EOF
)
    if [[ -n "${SNOWFLAKE_PRIVATE_KEY_PASSPHRASE:-}" ]]; then
      auth_block="${auth_block}"$'\n'"      private_key_passphrase: ${SNOWFLAKE_PRIVATE_KEY_PASSPHRASE}"
    fi
    ;;
  oauth)
    : "${SNOWFLAKE_OAUTH_CLIENT_ID:?Missing SNOWFLAKE_OAUTH_CLIENT_ID}"
    : "${SNOWFLAKE_OAUTH_CLIENT_SECRET:?Missing SNOWFLAKE_OAUTH_CLIENT_SECRET}"
    : "${SNOWFLAKE_OAUTH_REFRESH_TOKEN:?Missing SNOWFLAKE_OAUTH_REFRESH_TOKEN}"
    # In dbt-snowflake, OAuth uses authenticator=oauth + client id/secret + refresh token in `token`
    auth_block=$(cat <<EOF
      authenticator: oauth
      oauth_client_id: ${SNOWFLAKE_OAUTH_CLIENT_ID}
      oauth_client_secret: ${SNOWFLAKE_OAUTH_CLIENT_SECRET}
      token: ${SNOWFLAKE_OAUTH_REFRESH_TOKEN}
EOF
)
    # user is not required for oauth in dbt docs examples
    if [[ -n "${SNOWFLAKE_USER:-}" ]]; then
      auth_block="${auth_block}"$'\n'"      user: ${SNOWFLAKE_USER}"
    fi
    ;;
  externalbrowser)
    : "${SNOWFLAKE_USER:?Missing SNOWFLAKE_USER}"
    auth_block=$(cat <<EOF
      user: ${SNOWFLAKE_USER}
      authenticator: externalbrowser
EOF
)
    ;;
  password)
    : "${SNOWFLAKE_USER:?Missing SNOWFLAKE_USER}"
    : "${SNOWFLAKE_PASSWORD:?Missing SNOWFLAKE_PASSWORD}"
    auth_block=$(cat <<EOF
      user: ${SNOWFLAKE_USER}
      password: ${SNOWFLAKE_PASSWORD}
EOF
)
    ;;
  *)
    echo "Unsupported SNOWFLAKE_AUTH_METHOD: ${SNOWFLAKE_AUTH_METHOD}" >&2
    exit 1
    ;;
esac

role_line=""
if [[ -n "${SNOWFLAKE_ROLE}" ]]; then
  role_line="      role: ${SNOWFLAKE_ROLE}"
fi

cat > "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
default:
  target: ${DBT_TARGET}
  outputs:
    ${DBT_TARGET}:
      type: snowflake
      account: ${SNOWFLAKE_ACCOUNT}
${auth_block}
${role_line}
      database: ${SNOWFLAKE_DATABASE}
      warehouse: ${SNOWFLAKE_WAREHOUSE}
      schema: ${SNOWFLAKE_SCHEMA}
      threads: ${DBT_THREADS:-4}
EOP
