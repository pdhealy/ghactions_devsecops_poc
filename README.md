# Secure GitHub Actions PoC & GCP Cloud Run

This proof-of-concept demonstrates a secure, minimal GitHub Actions pipeline that builds a distroless Python service, scans it, attests provenance, and deploys to Cloud Run using keyless OIDC.

## Architecture

1. **App**: Flask API in `src/main.py`, served by Gunicorn.
2. **Container**: Multi-stage build with a distroless runtime and non-root execution.
3. **CI/CD**: Lint + SAST + tests → build + Trivy scan → push to GHCR + SLSA attestation → deploy to Cloud Run with OIDC.

## The "Critical 20%" GitHub Actions Concepts

1. **Events**: `push`, `pull_request`, and `workflow_dispatch` drives full CI coverage.
2. **Least privilege**: `permissions: {}` at the workflow level with per-job grants.
3. **Job orchestration**: `needs` creates a secure multi-stage pipeline.
4. **OIDC keyless auth**: GitHub OIDC for GHCR/GCP instead of long-lived secrets.
5. **Supply chain security**: Trivy vulnerability scanning + SLSA provenance attestation.

## Local Validation with `act` (inside the Dev Container)

The dev container installs `act` and Docker-in-Docker so you can test the pipeline locally.

```bash
# Lint + SAST + tests
act push -j lint-and-test

# Build + Trivy scan
act push -j build-and-scan
```

## GCP Workload Identity Federation (WIF) Provisioning

The workflow expects:

* **Secrets**: `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`
* **Vars**: `GCP_PROJECT_ID`, `GCP_REGION`, `CLOUD_RUN_SERVICE`

### Secure provisioning (bash template)

```bash
export PROJECT_ID="your-gcp-project-id"
export PROJECT_NUMBER="$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')"
export REGION="us-central1"
export SERVICE_ACCOUNT_NAME="gh-actions-cloudrun"
export SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
export POOL_ID="github-actions-pool"
export PROVIDER_ID="github-actions-provider"
export REPO="owner/repo"

gcloud iam workload-identity-pools create "${POOL_ID}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Actions Pool"

gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_ID}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="${POOL_ID}" \
  --display-name="GitHub Actions Provider" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
  --attribute-condition="assertion.repository=='${REPO}'"

gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
  --project="${PROJECT_ID}" \
  --display-name="GitHub Actions Cloud Run Deployer"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/run.admin"

gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}" \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/attribute.repository/${REPO}"
```

Then set:

* `GCP_WORKLOAD_IDENTITY_PROVIDER` to  
  `projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/providers/${PROVIDER_ID}`
* `GCP_SERVICE_ACCOUNT` to  
  `${SERVICE_ACCOUNT_EMAIL}`
