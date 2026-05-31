# Master Project Blueprint: Secure GitHub Actions PoC & GCP Deployment

## Context for the AI Agent

You are an expert Principal Software Engineer and DevSecOps Architect. Your task is to implement a proof-of-concept project designed to teach the critical 20% of GitHub Actions required for 80% functional mastery (The Pareto Principle). 

You must follow this phased plan sequentially. Ensure all code adheres strictly to Google-grade production engineering and software security best practices (least-privilege, SLSA provenance, strict dependency locking, OIDC keyless authentication, and distroless containers).

---

## Current Repo State (Baseline)

*   `.devcontainer/` already exists with a custom `devcontainer.json` and `.devcontainer/Dockerfile` based on `mcr.microsoft.com/devcontainers/base:2.1.8-ubuntu24.04`, plus features for Copilot CLI, Ollama, and Claude. It does **not** include docker-in-docker.
*   No root `Dockerfile` exists (only `.devcontainer/Dockerfile`).
*   No `src/` directory or application code exists.
*   No `pyproject.toml`, `uv.lock`, or test suite is present.
*   No `README.md` exists.
*   `.github/` exists but contains no workflows (only `dependabot.yml`, `hooks/`, `logs/`).
*   `docs/` directory exists but is empty.

---

## Phase 1: Local Development Environment Setup (Dev Container)

**Goal:** Create a secure, isolated, and highly capable local development environment using VS Code Dev Containers.
**Directives:**
1.  **Directory Structure:** `.devcontainer` already exists; update it to meet these requirements rather than creating from scratch.
2.  **Configuration (`devcontainer.json`):**
    *   Use the base image: `mcr.microsoft.com/devcontainers/python:3.11-slim`.
    *   Include the `docker-in-docker` feature (required to build containers and run `act` locally).
    *   Install tools via `postCreateCommand`: Install `uv` (for Python dependency management) and `act` (for local GitHub Actions testing).
    *   **SSH Auth:** Ensure no keys are copied into the container. Rely natively on VS Code's SSH agent forwarding so the host machine's GitHub SSH keys authenticate `git push` commands.
    *   Configure VS Code extensions: Python, Pytest, Ruff, and Docker.

## Phase 2: Application Codebase & Dependency Management (`uv`)

**Goal:** Build a lightweight, GCP-style Python HTTP server with strict, secure dependency management.
**Directives:**
1.  **App Structure:** Create `src/main.py`.
2.  **Framework:** Use `Flask` to create a simple HTTP API. It must include:
    *   A root endpoint (`/`) returning a simple JSON response (e.g., `{"status": "success", "message": "Hello from Google Cloud Run!"}`).
    *   A health check endpoint (`/health`).
    *   It must read the `$PORT` environment variable (defaulting to `8080` if unset) and bind to `0.0.0.0`.
3.  **Dependency Management (`uv`):**
    *   Create a `pyproject.toml` file defining dependencies (Flask, Gunicorn).
    *   Define development dependencies (`pytest`, `pytest-cov`, `ruff`, `bandit`).
    *   Generate a strict `uv.lock` file to guarantee deterministic, secure builds.

## Phase 3: Testing Strategy (Pytest)

**Goal:** Implement comprehensive test coverage using `pytest`.
**Directives:**
1.  **Test Directory:** Create a `tests/` directory at the root.
2.  **Unit Tests (`tests/test_unit.py`):** Mock the Flask client. Test the JSON responses of the `/` and `/health` endpoints.
3.  **Integration Tests (`tests/test_integration.py`):** Simulate the application initialization and environment variable injection (`PORT`).
4.  **Configuration:** Create a `pytest.ini` and configure coverage reporting to fail if test coverage falls below 80%.

## Phase 4: Containerization (Distroless Multi-Stage Build)

**Goal:** Create a zero-vulnerability, minimal-attack-surface container image.
**Directives:**
1.  **Dockerfile Creation:** Create `Dockerfile` in the root directory (do not modify `.devcontainer/Dockerfile`).
2.  **Stage 1: Builder:**
    *   Use `python:3.11-slim`.
    *   Install `uv`.
    *   Create a virtual environment (`/opt/venv`) and install production dependencies from `uv.lock` securely.
3.  **Stage 2: Runtime (Distroless):**
    *   Use `gcr.io/distroless/python3-debian12` as the final base image.
    *   Copy the virtual environment and application source code (`src/`) from the builder stage.
    *   **Security:** Run as a non-root user (using Distroless's built-in `nonroot` user).
    *   Set the `ENTRYPOINT` to execute the application using the virtual environment's Python binary (e.g., `["/opt/venv/bin/python", "-m", "gunicorn", "--bind", "0.0.0.0:8080", "src.main:app"]`).

## Phase 5: The GitHub Actions CI/CD Pipeline (The Core Pareto 20%)
**Goal:** Implement a Google-grade CI/CD pipeline mastering Events, Permissions, Multi-stage Jobs, and OIDC.
**Directives:**
1.  **Workflow File:** Create `.github/workflows/main.yml`.
2.  **Events:** Trigger on `push` to `main`, `pull_request` to `main`, and `workflow_dispatch`.
3.  **Global Permissions:** Set top-level `permissions: {}` (deny all by default).
4.  **Job 1: Lint & SAST (`lint-and-test`)**
    *   *Permissions:* `contents: read`
    *   Run `ruff` for linting.
    *   Run `bandit` for Python security scanning.
    *   Run `pytest` for unit/integration tests with coverage.
5.  **Job 2: Build & Scan (`build-and-scan`)**
    *   *Needs:* `lint-and-test`
    *   Build the Docker image locally (do not push yet).
    *   Run Aqua Security `trivy` action against the built image. Fail the pipeline on `CRITICAL` or `HIGH` CVEs.
6.  **Job 3: Push & Attest (`push-to-ghcr`)**
    *   *Needs:* `build-and-scan`
    *   *Permissions:* `contents: read`, `packages: write`, `id-token: write` (Required for SLSA).
    *   Authenticate to GitHub Container Registry using `${{ secrets.GITHUB_TOKEN }}`.
    *   Push the Distroless image.
    *   Use `actions/attest-build-provenance` to generate SLSA Level 3 provenance for the container.
7.  **Job 4: Keyless Deployment to GCP (`deploy-to-cloudrun`)**
    *   *Needs:* `push-to-ghcr`
    *   *Permissions:* `contents: read`, `id-token: write` (Required for GCP Workload Identity Federation).
    *   Use `google-github-actions/auth` utilizing OIDC (Workload Identity Provider) to authenticate to GCP without service account keys.
    *   Use `google-github-actions/deploy-cloudrun` to deploy the GHCR container image to Google Cloud Run.

## Phase 6: Documentation & Local Validation Strategy
**Goal:** Provide the necessary configuration to validate the pipeline locally before pushing, and outline GCP provisioning.
**Directives:**
1.  **Generate `README.md`:** 
    *   Explain the architecture and the "Critical 20%" GitHub Actions concepts applied.
    *   Provide explicit instructions on how to use `act` inside the Dev Container to test the `lint-and-test` and `build-and-scan` jobs locally (e.g., `act push -j lint-and-test`).
    *   Provide a secure bash script template or gcloud commands in the README demonstrating how to provision the GCP Workload Identity Pool and Provider, and how to grant it `roles/run.admin` and `roles/iam.serviceAccountUser` access to a specific GitHub repository.

---
**Execution Instructions for the AI Agent:** 
Please begin execution. Start with Phase 1 and output the file contents for the `.devcontainer` configuration, then proceed phase-by-phase asking for my confirmation before moving to the next phase.