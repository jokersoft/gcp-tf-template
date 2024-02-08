resource "google_bigquery_dataset" "log_dataset" {
  dataset_id                  = "${replace(var.app_name, "-", "_")}_logs"
  location                    = "EU"
  default_table_expiration_ms = 3600000
}

resource "google_logging_project_sink" "bigquery_sink" {
  name                   = "${var.app_name}-log-sink"
  destination            = "bigquery.googleapis.com/projects/${var.project}/datasets/${google_bigquery_dataset.log_dataset.dataset_id}"
  filter                 = "resource.type=gce_instance AND logName=projects/${var.project}/logs/nginx-access"
  unique_writer_identity = true
}
