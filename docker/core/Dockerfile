ARG BASE_IMAGE=dbt-runtime-base
FROM ${BASE_IMAGE}

ARG DBT_CORE_VERSION=1.8.0
RUN pip install --no-cache-dir "dbt-core==${DBT_CORE_VERSION}"

COPY --chown=dbtuser:dbtuser scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--version"]
