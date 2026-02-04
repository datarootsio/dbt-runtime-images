# dbt Runtime Images — Usage Guide

This document explains how to use the standardized dbt runtime images provided by this repository.



## What This Image Provides

Each dbt runtime image is designed to be:

* Bundled with **dbt Core + a single adapter** (for example: Snowflake)
* Configured with **standardized runtime behavior**
* **Versioned and reproducible**, ensuring consistent execution across environments


## Image Naming Convention

Images are published to **GitHub Container Registry (GHCR)** using the following format:

```
ghcr.io/<ORG>/dbt-runtime-<adapter>:<version>
```

**Example**

```
ghcr.io/datarootsio/dbt-runtime-snowflake:1.8.0
```



## Prerequisites

Before using the runtime images, ensure you have:

* Docker installed and running
* A local dbt project
* Access to GitHub Container Registry (GHCR)

If required, authenticate once:

```
docker login ghcr.io
```



## Minimal dbt Project Structure

At minimum, your dbt project should contain:

```
dbt_project.yml
models/
```

The project directory will be mounted into the container at runtime.



## Running dbt Locally (Example: Snowflake)

Example command to run dbt using the Snowflake runtime image:

```
docker run --rm \
  -v "$PWD:/app" \
  -e DBT_ADAPTER=snowflake \
  -e DBT_TARGET=dev \
  -e DBT_PROFILES_DIR=/profiles \
  -e SNOWFLAKE_ACCOUNT=dummy \
  -e SNOWFLAKE_USER=dummy \
  -e SNOWFLAKE_PASSWORD=dummy \
  -e SNOWFLAKE_ROLE=dummy \
  -e SNOWFLAKE_DATABASE=dummy \
  -e SNOWFLAKE_WAREHOUSE=dummy \
  -e SNOWFLAKE_SCHEMA=dummy \
  ghcr.io/<ORG>/dbt-runtime-snowflake:1.8.0 \
  parse
```

This command:

* Mounts the local dbt project into the container
* Injects credentials via environment variables
* Executes a dbt command (`parse` in this example)



## Profiles Handling

* `profiles.yml` is **generated at runtime** inside the container
* Configuration is derived entirely from environment variables
* **No secrets are committed** to Git repositories

This ensures security and environment portability.



## Best Practices

* Always use the standardized runtime image instead of local dbt installs
* Never commit credentials or `profiles.yml`
* Use **immutable image tags** (no `latest`) in production
* Keep adapter versions aligned with your dbt project requirements
