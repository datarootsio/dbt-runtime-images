# Adding a New dbt Adapter Runtime

This document explains how to add a new adapter image (for example: Fabric, BigQuery, Postgres) to the dbt runtime image platform.



## Architecture Overview

The dbt runtime platform is structured in three layers:

* **Base image**: Operating system and shared tooling
* **Core image**: `dbt-core` plus runtime scripts
* **Adapter image**: Core image plus exactly **one** dbt adapter


## What Is Required for a New Adapter

To add support for a new adapter, the following components must be added or updated:

1. Adapter Dockerfile
2. Profile renderer script
3. Adapter dispatcher registration
4. Smoke test
5. CI build & publish integration
6. Documentation update


## 1. Adapter Dockerfile

**Location**

```
docker/adapters/<adapter>/Dockerfile
```

**Template**

```
FROM dbt-runtime-core

ARG DBT_<ADAPTER>_VERSION=1.8.0
RUN pip install --no-cache-dir "dbt-<adapter-package>==${DBT_<ADAPTER>_VERSION}"
```

**Notes**

* Each adapter must have its own image
* Always pin the adapter version


## 2. Profile Renderer Script

Each adapter requires a script to generate its dbt profile at runtime.

**Location**

```
scripts/render_profiles/<adapter>.sh
```

**Template**

```
#!/usr/bin/env bash
set -euo pipefail

: "${DBT_PROFILES_DIR:?Missing DBT_PROFILES_DIR}"
: "${DBT_TARGET:?Missing DBT_TARGET}"

cat > "${DBT_PROFILES_DIR}/profiles.yml" <<EOF
default:
  target: ${DBT_TARGET}
  outputs:
    ${DBT_TARGET}:
      type: <adapter>
      threads: ${DBT_THREADS:-4}
EOF
```

**Notes**

* Script must fail fast if required environment variables are missing
* No secrets should be embedded in scripts


## 3. Register Adapter Dispatcher

Register the adapter renderer in the main dispatcher script.

**File to update**

```
scripts/render_profiles.sh
```

**Example entry**

```
<adapter>)
  /usr/local/bin/render_profiles/<adapter>.sh
  ;;
```


## 4. Smoke Test

Each adapter must include a minimal smoke test to validate installation.

**Location**

```
tests/smoke/test_<adapter>_adapter.sh
```

**Test command**

```
python -c "import dbt.adapters.<adapter>; print('ok')"
```

## 5. CI Integration

The CI pipeline must be extended to:

* Build the adapter image
* Run the adapter smoke test
* Publish the image when running on the `main` branch


## Best Practices

* One adapter per image
* Pin all adapter versions explicitly
* Never include secrets in images or scripts
* Validate required environment variables early
* Keep adapter logic isolated from core runtime
