#!/usr/bin/env bash
set -euo pipefail
python -c "import dbt.adapters.fabric; print('ok')"
