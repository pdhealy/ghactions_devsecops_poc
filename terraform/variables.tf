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

variable "frontend_subnet_cidr_range" {
  type        = string
  description = "CIDR range for the internal load balancer frontend subnet."
  default     = "10.10.0.0/24"
}

variable "proxy_only_subnet_cidr_range" {
  type        = string
  description = "CIDR range for the proxy-only subnet used by the internal load balancer."
  default     = "10.10.1.0/24"
}

variable "runtime_service_account_id" {
  type        = string
  description = "Service account ID for the Cloud Run runtime."
  default     = "cloud-run-runtime"
}

variable "container_cpu" {
  type        = string
  description = "CPU limit for the container."
  default     = "1"
}

variable "container_memory" {
  type        = string
  description = "Memory limit for the container."
  default     = "512Mi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.container_memory))
    error_message = "The container_memory value must be a valid format, like '512Mi' or '1Gi'."
  }
}

variable "min_instance_count" {
  type        = number
  description = "Minimum number of Cloud Run instances."
  default     = 0
}

variable "max_instance_count" {
  type        = number
  description = "Maximum number of Cloud Run instances."
  default     = 3
}

variable "max_instance_request_concurrency" {
  type        = number
  description = "Maximum concurrent requests per container."
  default     = 80
}

variable "timeout" {
  type        = string
  description = "Request timeout duration (for example, 300s)."
  default     = "300s"
}
