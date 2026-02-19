#!/usr/bin/env bash
set -euo pipefail

export DBT_PROJECT_DIR="${DBT_PROJECT_DIR:-/app}"
export DBT_PROFILES_DIR="${DBT_PROFILES_DIR:-/profiles}"
export DBT_TARGET="${DBT_TARGET:-dev}"
export DBT_RENDER_PROFILES="${DBT_RENDER_PROFILES:-0}"

if [[ "$DBT_RENDER_PROFILES" == "1" ]]; then
  /usr/local/bin/render_profiles.sh
fi

cd "$DBT_PROJECT_DIR"
exec dbt "$@"
