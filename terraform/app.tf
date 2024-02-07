resource "google_compute_instance_template" "app" {
  # The name has to be updated every time because reasons: https://github.com/hashicorp/terraform-provider-google/issues/10962
  # hence random suffix
  name         = "${var.app_name}-template-${random_string.stateless_suffix.result}"
  machine_type = "e2-micro"

  scheduling {
    automatic_restart   = true
    min_node_cpus       = 0
    on_host_maintenance = "MIGRATE"
    preemptible         = null
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = google_service_account.ops_agent_service_account.email
    scopes = ["https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring"]
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  disk {
    source_image = data.google_compute_image.debian_image.self_link
  }

  # see https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/third-party/nginx
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    sudo tee /etc/nginx/conf.d/status.conf > /dev/null << EOT
server {
   listen 80;
   server_name 127.0.0.1;
   location /nginx_status {
       stub_status on;
       access_log on;
       allow 127.0.0.1;
       deny all;
   }
   location / {
       root /dev/null;
   }
}
EOT

    # Reload Nginx to apply changes
    sudo systemctl reload nginx

    systemctl start nginx

    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install

    echo "Applying custom Ops Agent configuration..."
    sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null <<EOT
metrics:
  receivers:
    nginx:
      type: nginx
      stub_status_url: http://127.0.0.1:80/nginx_status
  service:
    pipelines:
      nginx:
        receivers:
          - nginx
logging:
  receivers:
    nginx_access:
      type: nginx_access
    nginx_error:
      type: nginx_error
  service:
    pipelines:
      nginx:
        receivers:
          - nginx_access
          - nginx_error
EOT

    sudo systemctl restart google-cloud-ops-agent.service
    sleep 60
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
