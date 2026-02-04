# Adding a New dbt Adapter – Step-by-Step Guide

This document describes the standard process for adding a new dbt adapter
(e.g. Fabric, BigQuery, Postgres, Databricks) to the dbt runtime image platform.

Follow these steps in order. Do not skip steps.



## 1. Create the adapter Dockerfile

Create a new folder and Dockerfile:

docker/adapters/<adapter>/Dockerfile

Template:

```dockerfile
ARG CORE_IMAGE=dbt-runtime-core
FROM ${CORE_IMAGE}

ARG DBT_<ADAPTER>_VERSION=1.8.0
RUN pip install --no-cache-dir "dbt-<adapter-package>==${DBT_<ADAPTER>_VERSION}"
```

Notes:
- One adapter per image
- Pin adapter versions
- Do NOT add secrets



## 2. Add the profile renderer script

Create:

scripts/render_profiles/<adapter>.sh

Template:

```bash
#!/usr/bin/env bash
set -euo pipefail

: "${DBT_PROFILES_DIR:?Missing DBT_PROFILES_DIR}"
: "${DBT_TARGET:?Missing DBT_TARGET}"

# Validate adapter-specific env vars here

cat > "${DBT_PROFILES_DIR}/profiles.yml" <<EOP
default:
  target: ${DBT_TARGET}
  outputs:
    ${DBT_TARGET}:
      type: <adapter-type>
      threads: ${DBT_THREADS:-4}
EOP
```

Requirements:
- Fail fast if required env vars are missing
- Never print secrets
- Always write profiles.yml to DBT_PROFILES_DIR



## 3. Register the adapter in the dispatcher

Update:

scripts/render_profiles.sh

Add a new case:

```bash
<adapter>)
  /usr/local/bin/render_profiles/<adapter>.sh
  ;;
```



## 4. Add adapter version to versions.env

Update:

config/versions.env

Add:

```env
DBT_<ADAPTER>_VERSION=1.8.0
```

This file is the single source of truth for versions.



## 5. Add a smoke test

Create:

tests/smoke/test_<adapter>_adapter.sh

Content:

```bash
#!/usr/bin/env bash
set -e
python -c "import dbt.adapters.<adapter>; print('ok')"
```

Make it executable:

```bash
chmod +x tests/smoke/test_<adapter>_adapter.sh
```



## 6. Update CI workflow

In .github/workflows/ci.yml:

- Build the new adapter image
- Run the smoke test
- Do NOT publish images in PRs

Follow the same pattern used for Snowflake.



## 7. Update publish workflow

In `.github/workflows/publish-ghcr.yml`, add:

- a **build & push** step for `dbt-runtime-<adapter>`
- use **build arguments** and the same tags (`<dbt-core>`, `<dbt-core>-<sha>`)


## 8. Update documentation

Update the following files:
- docs/compatibility-matrix.md
- docs/usage.md
- docs/add-adapter.md (optional adapter notes)



## 9. Update CHANGELOG

Under [Unreleased] in CHANGELOG.md, add:

- Added: dbt-runtime-<adapter> image



## 10. Test locally (recommended)

Build locally:

```bash
docker build   -f docker/adapters/<adapter>/Dockerfile   --build-arg CORE_IMAGE=dbt-runtime-core:local   --build-arg DBT_<ADAPTER>_VERSION=<version>   -t dbt-runtime-<adapter>:local .
```

Test adapter import:

```bash
docker run --rm --entrypoint bash dbt-runtime-<adapter>:local -lc   'python -c "import dbt.adapters.<adapter>; print(\"ok\")"'
```



## Checklist

- [ ] Dockerfile added
- [ ] Profile renderer added
- [ ] Dispatcher updated
- [ ] versions.env updated
- [ ] Smoke test added
- [ ] CI updated
- [ ] Publish workflow updated
- [ ] Docs updated
- [ ] Changelog updated
- [ ] Local test passed



## Important rules

- Never install multiple adapters in one image
- Never commit secrets
- Never bake dbt projects into images
- Always pin versions
- Always test locally before PR

