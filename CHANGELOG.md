
## Unreleased

- Add Databricks, BigQuery and Postgres runtime images (Dockerfiles, profile renderers, smoke tests, CI publish).

# Changelog

All notable changes to the dbt runtime images are documented in this file.

This project follows a **dbt-core–centric versioning model**:
- Image versions are aligned with dbt-core versions
- Immutable tags include the git SHA for traceability
- Stable tags (e.g. `1.8.0`) always point to the latest compatible build

---

## [Unreleased]

### Added
- 

### Changed
- 

### Fixed
- 

### Security
- 

---

## [1.8.2] - 2026-02-04

### Added
- Initial standardized dbt runtime images
- Layered image architecture:
  - base image (OS + tooling)
  - core image (dbt-core runtime)
  - Snowflake adapter image
- Non-root execution for all images
- Runtime profile rendering via environment variables
- GitHub Actions CI for build and smoke testing
- Publishing images to GitHub Container Registry (GHCR)
- Adapter extension mechanism and documentation
- Initial usage and adapter documentation

### Changed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Security
- No credentials stored in images
- Secrets injected only at runtime
- Minimal base image with pinned dependencies

### Images
- ghcr.io/datarootsio/dbt-runtime-base:1.8.0
- ghcr.io/datarootsio/dbt-runtime-core:1.8.0
- ghcr.io/datarootsio/dbt-runtime-snowflake:1.8.0
