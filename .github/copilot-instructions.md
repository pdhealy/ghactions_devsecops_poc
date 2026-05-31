# Copilot instructions

## Build, test, lint
- Install dev deps: `uv sync --frozen --extra dev` (creates `.venv`)
- Lint: `.venv/bin/ruff check .`
- SAST: `.venv/bin/bandit -r src`
- Tests: `.venv/bin/pytest`
- Single test: `.venv/bin/pytest tests/test_unit.py::test_root_endpoint`
- Container build (CI): `docker build -t $IMAGE_NAME:$IMAGE_TAG .`
- Local CI (dev container): `act push -j lint-and-test` and `act push -j build-and-scan`

## Architecture (big picture)
- Flask API in `src/main.py`; Gunicorn serves `src.main:app` in the container.
- Multi-stage container build uses `uv.lock` to export pinned prod requirements and runs on distroless Python (non-root).
- GitHub Actions pipeline: lint/SAST/tests → build + Trivy scan → push to GHCR + SLSA attestation → deploy to Cloud Run with OIDC (main branch only).

## Key conventions
- Dependencies live in `pyproject.toml` with locks in `uv.lock`; CI installs via `uv sync --frozen --extra dev`, so keep the lockfile current.
- Tests import from the `src` package and live in `tests/`; coverage threshold is enforced via `pytest.ini` (`--cov-fail-under=80`).
- Runtime port comes from `PORT` with a default of `8080`, which matches Cloud Run expectations.
- Deploy job expects secrets `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` and vars `GCP_PROJECT_ID`, `GCP_REGION`, `CLOUD_RUN_SERVICE`.
