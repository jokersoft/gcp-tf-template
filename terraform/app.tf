resource "google_compute_instance" "app" {
  count        = length(data.google_compute_zones.available.names)
  name         = "nginx"
  machine_type = "e2-micro"
  zone         = element(data.google_compute_zones.available.names, count.index)

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  network_interface {
    network = "default"

    access_config {
      // This empty block assigns an ephemeral external IP address to the instance.
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
  EOF

  tags = ["http-server"]
}
