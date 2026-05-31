output "service_name" {
  value       = google_cloud_run_v2_service.service.name
  description = "Full resource name of the Cloud Run service."
}

output "service_uri" {
  value       = google_cloud_run_v2_service.service.uri
  description = "Cloud Run service URL."
}

output "runtime_service_account_email" {
  value       = google_service_account.runtime.email
  description = "Service account email used by the Cloud Run runtime."
}
