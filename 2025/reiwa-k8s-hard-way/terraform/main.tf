terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "reiwa-k8s-network"
}

resource "google_compute_firewall" "iap_ssh" {
  name    = "allow-iap-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP用のソースIP範囲
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "reiwa-k8s-hw"
  machine_type = "e2-medium"
 
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size = 20
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

    metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y git
    mkdir -p /opt
    cd /opt
    git clone https://github.com/k65miyazakiy/blog-snippets.git
    git config --global --add safe.directory /opt/blog-snippets
    EOF
}
