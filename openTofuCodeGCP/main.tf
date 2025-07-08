terraform {
  required_providers {
    google = {
      version = "~> 6.0.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = "${var.region}-b"
  credentials = file(var.credentials_file)
}

resource "google_compute_address" "static_ip" {
  name = "ncr-static-ip"
}

# Create Compute Engine instance
resource "google_compute_instance" "ncr_instance" {
  name         = "ncr-instance"
  machine_type = var.instance_type
  zone         = "${var.region}-b"
  
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
}

# Create firewall rules (equivalent to security groups)
resource "google_compute_firewall" "ncr_firewall" {
  name    = "ncr-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
# Egress is allowed by default in GCP

output "instance_public_ip" {
  description = "Public IP of Google cloud instance"
  value = google_compute_address.static_ip.address
}

resource "null_resource" "wait_for_ping" {
  depends_on = [google_compute_instance.ncr_instance]

  provisioner "local-exec" {
    command = "../ping_new.sh ${google_compute_address.static_ip.address}"
  }
}

locals {
  depends_on        = null_resource.wait_for_ping
  host              = "${google_compute_address.static_ip.address}"
  known_hosts_file  = "~/.ssh/known_hosts"
  # Generate the inventory/hosts.yml file content
  ansible_inventory = <<-EOT
    all:
      hosts:
        ${google_compute_address.static_ip.address}:
          ansible_user: ${var.ssh_user}
  EOT
}

# Write the inventory file to the filesystem
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory/hosts.yml"
  content  = local.ansible_inventory 
}

resource "null_resource" "add_ssh_key_to_known_hosts" {
  depends_on = [null_resource.wait_for_ping]
  triggers = {
    host             = local.host
    known_hosts_file = local.known_hosts_file
  }

  provisioner "local-exec" {
    command = "ssh-keyscan -H ${self.triggers.host} >> ${local.known_hosts_file}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "ssh-keygen -f ${self.triggers.known_hosts_file} -R ${self.triggers.host}"
  }
}

# Run Ansible after creating the instance
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.wait_for_ping, null_resource.add_ssh_key_to_known_hosts]

  provisioner "local-exec" {
    command = <<EOT
ansible-playbook -i ${local_file.ansible_inventory.filename} \
../install_ncr.yaml
EOT
  }
}