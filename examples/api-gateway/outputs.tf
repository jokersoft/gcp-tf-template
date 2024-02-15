output "gateway_default_hostname" {
  value = google_api_gateway_gateway.gateway.default_hostname
}

output "service_1_ip" {
  value = data.terraform_remote_state.service_1.outputs.load_balancer_ip
}

output "service_1_dns" {
  value = data.terraform_remote_state.service_1.outputs.service_dns_name
}
