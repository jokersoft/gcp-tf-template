module "app" {
  source = "../../modules/compute-engine-zone-instance"

  app_name          = var.app_name
  project           = var.project
  region            = var.region
  zone              = var.zone
  managed_zone_name = var.managed_zone_name
  logs_bucket_name  = var.logs_bucket_name
}
