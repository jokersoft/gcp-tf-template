output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.http.ip_address
}

output "service_dns_name" {
  value = replace(google_dns_record_set.app.name, "/[.]$/", "")
}
