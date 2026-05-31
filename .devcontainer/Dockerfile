# syntax=docker/dockerfile:1.x
FROM mcr.microsoft.com/devcontainers/python:3.11-slim

ARG ACT_VERSION=0.2.88
ARG ACT_SHA256=1eb9996682dfcc053ac8f3f90f2ec50376f0cdfc229712d82da03d673c63a2b3

# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        gh \
        git \
        nodejs \
        npm \
        python3-venv \
        zstd \
    && npm install -g @devcontainers/cli \
    && python3 -m pip install --no-cache-dir uv \
    && curl -LsSf -o /tmp/act.tar.gz https://github.com/nektos/act/releases/download/v${ACT_VERSION}/act_Linux_x86_64.tar.gz \
    && echo "${ACT_SHA256}  /tmp/act.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/act.tar.gz -C /usr/local/bin act \
    && chmod +x /usr/local/bin/act \
    && rm /tmp/act.tar.gz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
