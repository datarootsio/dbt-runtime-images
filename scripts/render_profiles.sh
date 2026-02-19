#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${DBT_PROFILES_DIR}"

case "${DBT_ADAPTER:-snowflake}" in
  snowflake)
    /usr/local/bin/render_profiles/snowflake.sh
    ;;
  fabric)
    /usr/local/bin/render_profiles/fabric.sh
    ;;
  databricks)
    /usr/local/bin/render_profiles/databricks.sh
    ;;
  bigquery)
    /usr/local/bin/render_profiles/bigquery.sh
    ;;
  postgres)
    /usr/local/bin/render_profiles/postgres.sh
    ;;
  *)
    echo "Unsupported DBT_ADAPTER" >&2
    exit 1
    ;;
esac
