resource "google_api_gateway_gateway" "gateway" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.gateway.id
  gateway_id = "my-gateway"
  project    = var.project
  region     = "europe-west2"
}

resource "google_api_gateway_api" "gateway" {
  provider = google-beta
  api_id   = "my-api"
  project  = var.project
}

resource "google_api_gateway_api_config" "gateway" {
  provider      = google-beta
  api           = google_api_gateway_api.gateway.api_id
  api_config_id = "my-config"
  project       = var.project

  openapi_documents {
    document {
      path     = "${path.module}/config/openapi-spec.yaml"
      contents = base64encode(templatefile("${path.module}/config/openapi-spec.tpl", {
        api_gateway_id  = "api-gateway"
        region          = var.region
        project         = var.project
        service_address = module.nginx_gateway.service_self_link
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

## file
#resource "local_file" "openapi_spec" {
#  filename = "${path.module}/openapi-spec.yaml"
#  content  = templatefile("${path.module}/config/openapi-spec.tpl", {
#    api_gateway_id  = "api-gateway"
#    region          = var.region
#    project         = var.project
#    service_address = module.nginx_gateway.service_self_link
#  })
#}

#data "local_file" "openapi_spec" {
#  filename = "openapi-spec.yaml"
#}
