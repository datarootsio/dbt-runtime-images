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
  *)
    echo "Unsupported DBT_ADAPTER" >&2
    exit 1
    ;;
esac
