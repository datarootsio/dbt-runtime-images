#!/usr/bin/env bash
set -euo pipefail

: "${DBT_PROFILES_DIR:?Missing DBT_PROFILES_DIR}"
: "${DBT_TARGET:?Missing DBT_TARGET}"

: "${BIGQUERY_PROJECT:?Missing BIGQUERY_PROJECT}"
: "${BIGQUERY_DATASET:?Missing BIGQUERY_DATASET}"

BQ_THREADS="${DBT_THREADS:-4}"
BIGQUERY_METHOD="${BIGQUERY_METHOD:-auto}"

# Modern defaults:
# - Prefer OAuth / federated identity (ADC) when available.
# - Avoid long-lived service account keys unless you must.
#
# Supported (dbt-bigquery):
#   method: oauth                 (ADC via gcloud / metadata server)
#   method: oauth-secrets         (refresh_token+client_id+client_secret OR token)
#   method: service-account       (keyfile path)
#   method: service-account-json  (keyfile_json object)

resolve_method() {
  if [[ "${BIGQUERY_METHOD}" != "auto" ]]; then
    echo "${BIGQUERY_METHOD}"
    return
  fi

  if [[ -n "${BIGQUERY_KEYFILE_JSON:-}" ]]; then
    echo "service-account-json"
  elif [[ -n "${BIGQUERY_KEYFILE_PATH:-}" ]]; then
    echo "service-account"
  elif [[ -n "${BIGQUERY_TOKEN:-}" ]]; then
    echo "oauth-secrets"
  elif [[ -n "${BIGQUERY_REFRESH_TOKEN:-}" && -n "${BIGQUERY_CLIENT_ID:-}" && -n "${BIGQUERY_CLIENT_SECRET:-}" && -n "${BIGQUERY_TOKEN_URI:-}" ]]; then
    echo "oauth-secrets"
  else
    # Default to ADC OAuth
    echo "oauth"
  fi
}

method="$(resolve_method)"

cat > "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
default:
  target: ${DBT_TARGET}
  outputs:
    ${DBT_TARGET}:
      type: bigquery
      method: ${method}
      project: ${BIGQUERY_PROJECT}
      dataset: ${BIGQUERY_DATASET}
      threads: ${BQ_THREADS}
EOP

if [[ "${method}" == "service-account" ]]; then
  : "${BIGQUERY_KEYFILE_PATH:?Missing BIGQUERY_KEYFILE_PATH}"
  cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      keyfile: ${BIGQUERY_KEYFILE_PATH}
EOP

elif [[ "${method}" == "service-account-json" ]]; then
  : "${BIGQUERY_KEYFILE_JSON:?Missing BIGQUERY_KEYFILE_JSON}"
  # Write as YAML block. Expect env var contains raw JSON string.
    python - <<'PY'
import os, json
obj = json.loads(os.environ["BIGQUERY_KEYFILE_JSON"])
print("      keyfile_json:")
def emit(d, indent="        "):  # 8 spaces under keyfile_json
    for k, v in d.items():
        if isinstance(v, dict):
            print(f"{indent}{k}:")
            emit(v, indent + "  ")
        else:
            if isinstance(v, str):
                # Quote only when needed
                if ":" in v or "\n" in v or v.strip() != v:
                    v = '"' + v.replace('"','\"') + '"'
            print(f"{indent}{k}: {v}")
if not isinstance(obj, dict):
    raise SystemExit("BIGQUERY_KEYFILE_JSON must be a JSON object")
emit(obj)
PYPY >> "${DBT_PROFILES_DIR}/profiles.yml"

elif [[ "${method}" == "oauth-secrets" ]]; then
  # Two modes:
  #  - token only (short-lived), set BIGQUERY_TOKEN
  #  - refresh token flow, set BIGQUERY_REFRESH_TOKEN + client fields
  if [[ -n "${BIGQUERY_TOKEN:-}" ]]; then
    cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      token: ${BIGQUERY_TOKEN}
EOP
  else
    : "${BIGQUERY_REFRESH_TOKEN:?Missing BIGQUERY_REFRESH_TOKEN}"
    : "${BIGQUERY_CLIENT_ID:?Missing BIGQUERY_CLIENT_ID}"
    : "${BIGQUERY_CLIENT_SECRET:?Missing BIGQUERY_CLIENT_SECRET}"
    : "${BIGQUERY_TOKEN_URI:?Missing BIGQUERY_TOKEN_URI}"
    cat >> "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
      refresh_token: ${BIGQUERY_REFRESH_TOKEN}
      client_id: ${BIGQUERY_CLIENT_ID}
      client_secret: ${BIGQUERY_CLIENT_SECRET}
      token_uri: ${BIGQUERY_TOKEN_URI}
EOP
  fi
fi
