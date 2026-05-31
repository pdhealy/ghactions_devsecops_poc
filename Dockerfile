# syntax=docker/dockerfile:1.7

FROM python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0 AS builder

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
        --no-emit-project \
        --frozen \
    && pip install --no-cache-dir --require-hashes -r /tmp/requirements.txt

COPY src ./src

FROM gcr.io/distroless/python3-debian12@sha256:2fdb05402a2cf21cf78fdb3ba4c5db167241e9e498140f5bf689d7efb773731f

ENV PYTHONUNBUFFERED=1
WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app/src /app/src
COPY gunicorn.conf.py /app/gunicorn.conf.py

USER nonroot
ENTRYPOINT ["/opt/venv/bin/gunicorn", "-c", "/app/gunicorn.conf.py", "src.main:app"]
