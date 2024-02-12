output "gateway_default_hostname" {
  value = google_api_gateway_gateway.gateway.default_hostname
}

output "service_1_address" {
  value = data.terraform_remote_state.service_1.outputs.app_self_ink
}
