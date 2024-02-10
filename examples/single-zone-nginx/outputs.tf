output "instance_group_instances" {
  value = module.nginx_gateway.instance_group_instances
}

output "app_self_ink" {
  value = module.nginx_gateway.service_self_link
}
