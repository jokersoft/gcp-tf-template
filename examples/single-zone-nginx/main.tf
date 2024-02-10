module "nginx_gateway" {
  source = "../../modules/compute-engine-zone-instance"

  app_name         = var.app_name
  project          = var.project
  region           = var.region
  zone             = var.zone
  logs_bucket_name = var.logs_bucket_name
}
