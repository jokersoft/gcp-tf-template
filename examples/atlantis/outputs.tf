output "atlantis_server_ip" {
  value = google_compute_instance.atlantis_server.network_interface.0.access_config.0.nat_ip
}
