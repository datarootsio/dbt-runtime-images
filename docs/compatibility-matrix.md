# Compatibility Matrix

This matrix defines the supported combinations of dbt-core and adapters published by this repository.

| dbt-core | Adapter | Adapter package | Adapter version | Status | Notes |
|---------:|---------|-----------------|-----------------|--------|------|
| 1.8.0    | snowflake | dbt-snowflake | 1.8.0 | Supported | baseline |
| 1.8.0    | databricks | dbt-databricks | 1.8.0 | Supported | added |
| 1.8.0    | bigquery | dbt-bigquery | 1.8.0 | Supported | added |
| 1.8.0    | postgres | dbt-postgres | 1.8.0 | Supported | added |
| 1.8.0    | fabric | TBD | TBD | Planned | adapter strategy pending |

Notes:
- We aim to align adapter minor versions with dbt-core minor versions when possible.
- Production environments should pin immutable tags: `<dbt-core>-<git_sha>`.
