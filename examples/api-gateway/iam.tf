# Gateway SA
resource "google_service_account" "gateway" {
  account_id   = "${var.gateway_name}-sa"
  display_name = "gateway SA account"
}

resource "google_project_iam_member" "apigateway_admin" {
  project = var.project
  role    = "roles/apigateway.admin"
  member  = "serviceAccount:${google_service_account.gateway.email}"
}

resource "google_project_iam_member" "network_admin" {
  project = var.project
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.gateway.email}"
}

resource "google_project_iam_member" "service_account_user" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.gateway.email}"
}

resource "google_project_iam_member" "log_writer" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gateway.email}"
}

resource "google_project_iam_member" "metric_writer" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gateway.email}"
}
