provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# 1. Custom VPC Network & Firewall Rule (Allow SSH port 22 and HTTP port 80)
resource "google_compute_network" "custom_vpc" {
  name                    = "rhel-custom-vpc"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "allow_http_ssh" {
  name    = "allow-http-ssh-firewall"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# 2. Cloud Storage (GCS) Bucket
resource "google_storage_bucket" "storage_bucket" {
  name     = var.bucket_name
  location = var.region
}

# 3. IAM Service Account & Bucket Permission
resource "google_service_account" "vm_sa" {
  account_id   = "rhel-vm-sa"
  display_name = "RHEL VM Service Account"
}

resource "google_storage_bucket_iam_member" "bucket_access" {
  bucket = google_storage_bucket.storage_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.vm_sa.email}"
}

# 4. Red Hat Enterprise Linux (RHEL) VM with Startup Script
resource "google_compute_instance" "rhel_vm" {
  name         = "rhel-web-server"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "rhel-cloud/rhel-9"
    }
  }

  network_interface {
    network = google_compute_network.custom_vpc.name
    access_config {} # Gives the VM a public IP
  }

  metadata_startup_script = file("startup.sh")

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }
}
