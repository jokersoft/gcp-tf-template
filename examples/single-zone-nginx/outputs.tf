output "instance_group_instances" {
  value = module.nginx_gateway.instance_group_instances
}

output "log_sink_writer_identity" {
  value = module.nginx_gateway.log_sink_writer_identity
}
