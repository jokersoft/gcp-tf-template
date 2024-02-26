data "google_secret_manager_secret_version" "atlantis_secrets" {
  secret      = "atlantis"
  version     = "latest"
}

locals {
  atlantis_secrets = jsondecode(data.google_secret_manager_secret_version.atlantis_secrets.secret_data)
}
