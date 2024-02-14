output "load_balancer_ip" {
  value = module.app.load_balancer_ip
}

output "service_dns_name" {
  value = module.app.service_dns_name
}
