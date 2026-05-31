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

output "internal_load_balancer_ip" {
  value       = google_compute_forwarding_rule.cloud_run.ip_address
  description = "IP address of the internal Application Load Balancer."
}
