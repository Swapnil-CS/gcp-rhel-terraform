Automated Red Hat Linux (RHEL) Web Server on GCP via Terraform

Overview

This repository contains modular Terraform configurations (main.tf, variables.tf) designed to automate the provisioning of a Red Hat Enterprise Linux 9 (RHEL 9) Compute Engine instance, custom VPC firewall rules, a Google Cloud Storage (GCS) bucket, and least-privilege IAM Service Account permissions on Google Cloud Platform (GCP).

During instance launch, an automated Linux startup script (startup.sh) installs and enables the Apache (httpd) web service and verifies the attached IAM Service Account permissions by querying the provisioned GCS bucket.


Core Components

Custom VPC & Firewall (google_compute_network, google_compute_firewall): Isolates network resources and explicitly permits inbound SSH (22) and HTTP (80) traffic.

Cloud Storage Bucket (google_storage_bucket): Provides regional object storage for application assets and IAM validation checks.

Least-Privilege IAM (google_service_account, google_storage_bucket_iam_member): Replaces the default Compute Engine service account with a dedicated identity (rhel-vm-sa) granted roles/storage.objectViewer on the target bucket.

RHEL 9 Compute Instance (google_compute_instance): Deploys a rhel-cloud/rhel-9 virtual machine bootstrapped via metadata_startup_script.

Repository Structure

gcp-rhel-terraform/
├── .gitignore      # Excludes .terraform/, *.tfstate, and sensitive *.json keys
├── main.tf         # Primary GCP resource definitions (VPC, Firewall, GCS, IAM, VM)
├── variables.tf    # Modular input variables (Project ID, Region, Zone, Bucket Name)
├── startup.sh      # RHEL bootstrap script to install httpd and validate GCS IAM access
└── README.md       # Project documentation


Prerequisites

Terraform >= 1.3.0

Google Cloud SDK (gcloud)

Git (configured with .gitignore hygiene to protect state and credential files)

Deployment & Usage

1. Clone the Repository

git clone https://github.com/YOUR_GITHUB_USERNAME/gcp-rhel-terraform.git
cd gcp-rhel-terraform


2. Initialize & Validate (Offline / Pre-Deployment Check)

Verify syntax, formatting, and resource references before connecting to cloud APIs:

terraform init -backend=false
terraform fmt -check
terraform validate


3. Plan & Apply Infrastructure

To deploy to an active GCP environment, authenticate via gcloud auth application-default login and run:

terraform init
terraform plan -var="project_id=YOUR_GCP_PROJECT_ID" -out=tfplan
terraform apply "tfplan"


Verification Commands

After provisioning, use the following commands to verify the infrastructure state, VM health, and httpd service:

1. Verify Terraform State

# List all tracked resources in the state file
terraform state list

# Inspect attributes, status, and public IP of the RHEL VM
terraform state show google_compute_instance.rhel_vm


2. Verify VM & Startup Script Execution via GCP CLI

# Confirm VM status is RUNNING
gcloud compute instances list

# Inspect serial port output to verify startup.sh completed without errors
gcloud compute instances get-serial-port-output rhel-web-server --zone=asia-south1-a


3. Verify Apache (httpd) & IAM Validation Inside RHEL

# SSH into the RHEL instance
gcloud compute ssh rhel-web-server --zone=asia-south1-a

# Check Apache service status
sudo systemctl status httpd

# Verify the IAM check output generated during boot
cat /var/www/html/iam_check.txt
curl http://localhost


Clean Up

To tear down all provisioned resources and prevent ongoing cloud charges:

terraform destroy -var="project_id=YOUR_GCP_PROJECT_ID"
