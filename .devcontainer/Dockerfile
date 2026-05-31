# syntax=docker/dockerfile:1.7
FROM mcr.microsoft.com/devcontainers/python:3.11-slim

# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        zstd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
