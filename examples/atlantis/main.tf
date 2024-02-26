resource "google_compute_instance" "atlantis_server" {
  name         = "atlantis-server"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = <<-EOS
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo docker rm -f atlantis || true
    sudo docker run --name atlantis -d -p 4141:4141 \
      --env ATLANTIS_GH_USER="${data.terraform_remote_state.secrets.outputs.atlantis_gh_user}" \
      --env ATLANTIS_GH_TOKEN="${data.terraform_remote_state.secrets.outputs.atlantis_gh_token}" \
      --env ATLANTIS_GH_WEBHOOK_SECRET="${data.terraform_remote_state.secrets.outputs.atlantis_gh_webhook_secret}" \
      --env ATLANTIS_REPO_ALLOWLIST="${data.terraform_remote_state.secrets.outputs.atlantis_repo_allowlist}" \
      runatlantis/atlantis
  EOS

  service_account {
    email  = google_service_account.atlantis.email
    # TODO: narrow the scope
    scopes = ["cloud-platform"]
  }

  tags = ["atlantis"]
}

resource "google_compute_firewall" "atlantis_http" {
  name    = "atlantis-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["4141"]
  }

  source_ranges = ["0.0.0.0/0"] # TODO: narrow the range
  target_tags = ["atlantis"]
}
