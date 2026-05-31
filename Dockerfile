# syntax=docker/dockerfile:1.7

FROM python:3.11-slim AS builder

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

RUN python -m venv "${VIRTUAL_ENV}" \
    && pip install --no-cache-dir uv

WORKDIR /app
COPY pyproject.toml uv.lock ./

RUN uv export --format requirements.txt \
        --output-file /tmp/requirements.txt \
        --no-dev \
        --no-editable \
        --frozen \
    && pip install --no-cache-dir --require-hashes -r /tmp/requirements.txt

COPY src ./src

FROM gcr.io/distroless/python3-debian12

ENV PYTHONUNBUFFERED=1
WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app/src /app/src

USER nonroot
ENTRYPOINT ["/opt/venv/bin/python", "-m", "gunicorn", "--bind", "0.0.0.0:8080", "src.main:app"]
