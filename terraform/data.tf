data "google_compute_zones" "available" {
  region  = var.region
  project = var.project
  status = "UP"
}

data "google_compute_image" "debian_image" {
  family  = "debian-11"
  project = "debian-cloud"
}
