resource "google_logging_project_sink" "sink" {
  name                   = "${var.app_name}-log-sink"
  destination            = "storage.googleapis.com/${var.logs_bucket_name}"
  filter                 = "resource.type=gce_instance AND logName=projects/${var.project}/logs/nginx_access"
  unique_writer_identity = true
}

data "google_storage_bucket" "logs_bucket" {
  name = var.logs_bucket_name
}

resource "google_project_iam_binding" "gcs-bucket-writer" {
  project = var.project
  role    = "roles/storage.objectCreator"

  members = [
    google_logging_project_sink.sink.writer_identity,
  ]
}

# log format can be adjusted: https://gist.github.com/dirkjonker/679622b9e6fc713165d35aa3b79a882f
