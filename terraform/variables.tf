variable "project_id" {
  type        = string
  description = "GCP project ID hosting the Cloud Run service."
}

variable "region" {
  type        = string
  description = "GCP region for Cloud Run."
}

variable "service_name" {
  type        = string
  description = "Cloud Run service name."
}

variable "image" {
  type        = string
  description = "Container image URI to deploy."
}

variable "invoker_service_account" {
  type        = string
  description = "Service account email granted the Cloud Run invoker role."
}
