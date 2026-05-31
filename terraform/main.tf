terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.30"
    }
  }

  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account = google_service_account.runtime.email

    containers {
      image = var.image

      resources {
        limits = {
          cpu    = var.container_cpu
          memory = var.container_memory
        }
      }
    }

    scaling {
      min_instance_count = var.min_instance_count
      max_instance_count = var.max_instance_count
    }

    max_instance_request_concurrency = var.max_instance_request_concurrency
    timeout                          = var.timeout
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}

resource "google_service_account" "runtime" {
  account_id   = var.runtime_service_account_id
  display_name = "Cloud Run runtime for ${var.service_name}"
  project      = var.project_id
}

resource "google_cloud_run_v2_service_iam_member" "invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.invoker_service_account}"
}

resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  # The internal load balancer proxies requests without end-user IAM auth.
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
