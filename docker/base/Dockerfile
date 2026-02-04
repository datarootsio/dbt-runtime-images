FROM python:3.11-slim

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
