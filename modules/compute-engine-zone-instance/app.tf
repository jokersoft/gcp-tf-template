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

  # TODO: make it a configuration choice
  # see https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/third-party/nginx
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx

    cat <<'EOT' > /etc/nginx/conf.d/status.conf
${file("${path.module}/config/nginx/conf.d/status.conf")}
EOT

    # Reload Nginx to apply changes
    sudo systemctl reload nginx

    systemctl start nginx

    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install

    echo "Applying custom Ops Agent configuration..."
    cat <<'EOT' > /etc/google-cloud-ops-agent/config.yaml
${file("${path.module}/config/etc/google-cloud-ops-agent/config.yaml")}
EOT

    sudo systemctl restart google-cloud-ops-agent.service
    sleep 60
  EOF

  lifecycle {
    create_before_destroy = true
  }

  tags = ["http-server"]
}

resource "google_compute_instance_group_manager" "app" {
  name               = "${var.app_name}-group-mngr"
  base_instance_name = var.app_name
  zone               = var.zone
  target_size        = var.app_target_size

  version {
    name              = random_string.stateless_suffix.result
    instance_template = google_compute_instance_template.app.id
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = length(data.google_compute_zones.available)
    max_unavailable_fixed = 0
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
    group = google_compute_instance_group_manager.app.instance_group
  }
}
