# syntax=docker/dockerfile:1.7

FROM python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0 AS builder

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

RUN python -m pip install --no-cache-dir uv \
    && python -m venv "${VIRTUAL_ENV}"

WORKDIR /app
COPY pyproject.toml uv.lock ./

RUN uv export --format requirements.txt \
        --output-file /tmp/requirements.txt \
        --no-dev \
        --no-editable \
        --no-emit-project \
        --frozen \
    && pip install --no-cache-dir --require-hashes -r /tmp/requirements.txt \
    && python -m pip uninstall -y pip setuptools

COPY src ./src

FROM python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0

ENV PYTHONUNBUFFERED=1
WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app/src /app/src
COPY gunicorn.conf.py /app/gunicorn.conf.py

RUN python -m pip uninstall -y pip setuptools wheel \
    && apt-get purge -y --allow-remove-essential --auto-remove perl-base libncursesw6 \
    && dpkg --purge --force-depends libtinfo6 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --system --uid 65532 --create-home --shell /usr/sbin/nologin nonroot
USER nonroot
ENTRYPOINT ["/opt/venv/bin/gunicorn", "-c", "/app/gunicorn.conf.py", "src.main:app"]
