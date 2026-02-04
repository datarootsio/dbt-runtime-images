FROM python:3.11-slim

ARG VERSION="dev"
ARG VCS_REF="unknown"
ARG BUILD_DATE="unknown"
ARG SOURCE="unknown"

LABEL org.opencontainers.image.title="dbt-runtime-base" \
      org.opencontainers.image.description="Base layer for dbt runtime images (OS + minimal tooling)" \
      org.opencontainers.image.source=$SOURCE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    git \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 10001 dbtuser \
  && mkdir -p /profiles \
  && chown -R dbtuser:dbtuser /profiles

ENV PATH="/home/dbtuser/.local/bin:${PATH}"

USER dbtuser
WORKDIR /app
