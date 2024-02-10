resource "google_storage_bucket" "logs_bucket" {
  name     = var.logs_bucket_name
  location = var.region
  storage_class = "REGIONAL"
}
