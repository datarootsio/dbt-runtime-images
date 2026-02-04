# Release & Version Policy (dbt runtime images)

## Scope
This repository publishes container images:
- dbt-runtime-base
- dbt-runtime-core
- dbt-runtime-<adapter> (e.g., snowflake, fabric)

## Versioning model
We version images primarily by **dbt-core version**.

### Image tags
For each image, publish:
- **Stable tag**: `<dbt_core_version>` (e.g., `1.8.0`)
- **Immutable tag**: `<dbt_core_version>-<git_sha>` (e.g., `1.8.0-a1b2c3d...`)

Production should use the immutable tag.

## When to bump versions
### 1) dbt-core bump (major/minor/patch)
Bump dbt-core when:
- a security update is needed
- bugfixes/features are required by projects
- adapter requires it (compatibility)

Process:
1) Update `config/versions.env`
2) Update compatibility matrix
3) Update CHANGELOG
4) Release via GitHub Actions on `main`

### 2) Adapter bump
Bump an adapter when:
- compatibility requires it (dbt-core minor alignment)
- critical adapter bugfix/security patch
- target platform requires it (e.g., API changes)

Adapters should generally align with dbt-core minor version when the adapter ecosystem supports it.

### 3) Base image/OS updates
Base OS updates (security patches) may be released without changing dbt-core version.
In that case:
- keep the stable `<dbt_core_version>` tag updated
- immutable tag captures exact build
- add a CHANGELOG entry under "Security/OS refresh"

## Support policy
- Support the **current** dbt-core minor and the **previous** minor (rolling window).
- Older versions remain available in GHCR but are not actively maintained.

## Promotion rules
- PRs: build + smoke tests only (no push)
- main: build + smoke tests + publish to GHCR
