resource "google_compute_instance_template" "app" {
  name         = "${var.app_name}-template"
  machine_type = "e2-micro"

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  disk {
    source_image = data.google_compute_image.debian_image.self_link
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
  EOF

  lifecycle {
    create_before_destroy = true
  }

  tags = ["http-server"]
}

resource "google_compute_region_instance_group_manager" "app" {
  name               = "${var.app_name}-group"
  base_instance_name = var.app_name
  region             = var.region
  target_size        = var.app_target_size
  version {
    instance_template = google_compute_instance_template.app.id
  }
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "http" {
  name               = "${var.app_name}-health-check"
  check_interval_sec = 5
  timeout_sec        = 5

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_backend_service" "app" {
  name          = var.app_name
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.http.self_link]

  backend {
    group = google_compute_region_instance_group_manager.app.instance_group
  }
}

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
