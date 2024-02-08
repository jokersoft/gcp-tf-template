data "google_compute_zones" "available" {
  region  = var.region
  project = var.project
  status  = "UP"
}

data "google_compute_image" "debian_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "null_resource" "recreate_trigger" {
  triggers = {
    always_recreate = timestamp()
  }
}

resource "random_string" "stateless_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true

  keepers = {
    always_recreate = null_resource.recreate_trigger.id
  }
}
