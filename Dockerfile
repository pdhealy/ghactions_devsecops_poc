# syntax=docker/dockerfile:1.7

FROM python:3.11-slim AS builder

WORKDIR /app
COPY pyproject.toml uv.lock ./

RUN python -m pip install --no-cache-dir uv

RUN uv export --format requirements.txt \
        --output-file /tmp/requirements.txt \
        --no-dev \
        --no-editable \
        --no-emit-project \
        --frozen \
    && pip install --no-cache-dir --require-hashes -r /tmp/requirements.txt --target=/app/deps

FROM gcr.io/distroless/python3-debian12

ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app/deps
WORKDIR /app

COPY --from=builder /app/deps /app/deps
COPY src ./src
COPY gunicorn.conf.py ./gunicorn.conf.py

USER nonroot
ENTRYPOINT ["python3", "/app/deps/bin/gunicorn", "-c", "/app/gunicorn.conf.py", "src.main:app"]
