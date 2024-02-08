resource "google_service_account" "ops_agent_service_account" {
  account_id   = "${var.app_name}-ops-agent-account"
  display_name = "Ops Agent Service Account"
}

resource "google_project_iam_member" "log_writer" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.ops_agent_service_account.email}"
}

resource "google_project_iam_member" "metric_writer" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.ops_agent_service_account.email}"
}
