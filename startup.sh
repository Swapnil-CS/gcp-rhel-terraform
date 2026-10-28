#!/bin/bash
# Install and start Apache web server on Red Hat Enterprise Linux (RHEL)
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Validate IAM Service Account permission by listing the GCS bucket
gsutil ls gs://rhel-app-storage-bucket-01 > /var/www/html/iam_check.txt

# Create simple web page
echo "<h1>Red Hat Linux Web Server Automated via Terraform</h1>" > /var/www/html/index.html
