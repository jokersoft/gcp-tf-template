resource "google_api_gateway_gateway" "gateway" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.gateway.id
  gateway_id = var.gateway_name
  project    = var.project
  region     = var.region
}

resource "google_api_gateway_api" "gateway" {
  provider = google-beta
  api_id   = var.gateway_name
  project  = var.project
}

resource "google_api_gateway_api_config" "gateway" {
  provider      = google-beta
  api           = google_api_gateway_api.gateway.api_id
  api_config_id = "${var.gateway_name}-config"
  project       = var.project

  openapi_documents {
    document {
      path     = "${path.module}/config/openapi-spec.yaml"
      contents = base64encode(templatefile("${path.module}/config/openapi-spec.tpl", {
        api_gateway_id  = "api-gateway"
        region          = var.region
        project         = var.project
        service_1_address = data.terraform_remote_state.service_1.outputs.app_self_ink
      }))
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "google_iam_policy" "admin" {
  provider = google-beta
  binding {
    role    = "roles/apigateway.viewer"
    members = [
      "serviceAccount:${google_service_account.gateway.email}",
    ]
  }
}

resource "google_api_gateway_gateway_iam_policy" "policy" {
  provider    = google-beta
  project     = google_api_gateway_gateway.gateway.project
  region      = google_api_gateway_gateway.gateway.region
  gateway     = google_api_gateway_gateway.gateway.gateway_id
  policy_data = data.google_iam_policy.admin.policy_data
}
