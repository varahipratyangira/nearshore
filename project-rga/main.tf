provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.project_id
  region      = var.region
}

resource "random_string" "website_suffix" {
  length  = 8
  special = false
}

resource "random_string" "logs_suffix" {
  length  = 8
  special = false
}

resource "google_storage_bucket" "website_bucket" {
  name     = var.website_bucket_name
  location = var.location
}

resource "google_storage_bucket" "access_logs_bucket" {
  name     = var.access_logs_bucket_name
  location = var.location
}

resource "google_compute_instance" "web_server" {
  count        = var.resource_group_count
  name         = "web-server-${count.index + 1}-${random_string.website_suffix.result}"
  machine_type = var.vm_size
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = var.vm_os
    }
  }

  network_interface {
    network = "bhadrakali"
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
  EOF
}

resource "google_compute_instance_group" "web_server_group" {
  name        = "web-server-group"
  zone        = "${var.region}-a"

  instances = google_compute_instance.web_server[*].self_link
}

resource "google_compute_health_check" "http_health_check" {
  name               = "http-health-check"
  check_interval_sec = 10
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2

  http_health_check {
    port        = 80
    request_path = "/"
  }
}

resource "google_compute_backend_service" "backend_service" {
  name        = "backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  health_checks = [google_compute_health_check.http_health_check.id]

  backend {
    group = google_compute_instance_group.web_server_group.id
  }
}

resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend_service.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "http-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.http_ip.address
}

resource "google_compute_global_address" "http_ip" {
  name = "http-ip"
}