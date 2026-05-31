resource "google_compute_network" "internal" {
  name                    = "${var.service_name}-network"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "frontend" {
  name          = "${var.service_name}-frontend-subnet"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.internal.id
  ip_cidr_range = var.frontend_subnet_cidr_range
}

resource "google_compute_subnetwork" "proxy_only" {
  name          = "${var.service_name}-proxy-only-subnet"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.internal.id
  ip_cidr_range = var.proxy_only_subnet_cidr_range
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_region_network_endpoint_group" "cloud_run" {
  name                  = "${var.service_name}-neg"
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.service.name
  }
}

resource "google_compute_region_backend_service" "cloud_run" {
  name                  = "${var.service_name}-backend"
  project               = var.project_id
  region                = var.region
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.cloud_run.id
  }
}

resource "google_compute_region_url_map" "cloud_run" {
  name            = "${var.service_name}-url-map"
  project         = var.project_id
  region          = var.region
  default_service = google_compute_region_backend_service.cloud_run.id
}

resource "google_compute_region_target_http_proxy" "cloud_run" {
  name    = "${var.service_name}-http-proxy"
  project = var.project_id
  region  = var.region
  url_map = google_compute_region_url_map.cloud_run.id
}

resource "google_compute_forwarding_rule" "cloud_run" {
  name                  = "${var.service_name}-ilb"
  project               = var.project_id
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  network               = google_compute_network.internal.id
  subnetwork            = google_compute_subnetwork.frontend.id
  ip_protocol           = "TCP"
  ports                 = ["80"]
  target                = google_compute_region_target_http_proxy.cloud_run.id
  allow_global_access   = false
}
