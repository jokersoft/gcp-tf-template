resource "google_compute_url_map" "http" {
  name            = "${var.app_name}-url-map"
  default_service = google_compute_backend_service.app.self_link
}

resource "google_compute_target_http_proxy" "http" {
  name    = "${var.app_name}-http-proxy"
  url_map = google_compute_url_map.http.self_link
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = "${var.app_name}-lb"
  target     = google_compute_target_http_proxy.http.self_link
  port_range = "80"
  ip_address = google_compute_global_address.app_ip.address
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  // The following target tags should match the tags applied to your instances.
  // This assumes instances are tagged as 'http-server' for HTTP traffic.
  target_tags = ["http-server"]

  // Source ranges for the world (restrict this further based on requirements).
  source_ranges = ["0.0.0.0/0"]
}

# need static IP to use with DNS
resource "google_compute_global_address" "app_ip" {
  name = "${var.app_name}-ip"
}

# need to create an A DNS record to allow usage with API-Gateway
data "google_dns_managed_zone" "managed_zone" {
  name = var.managed_zone_name
}

resource "google_dns_record_set" "app" {
  name         = "${var.app_name}.${data.google_dns_managed_zone.managed_zone.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = var.managed_zone_name
  rrdatas      = [google_compute_global_address.app_ip.address]
}
