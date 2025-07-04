terraform {
  required_providers {
    google = {
      version = "~> 6.0.0"
    }
    gandi = {
      source  = "go-gandi/gandi"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = "${var.region}-b"
  credentials = file(var.credentials_file)
}

provider "gandi" {
  personal_access_token = var.gandi_token
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

output "instance_public_ip" {
  description = "Public IP of Google cloud instance"
  value = google_compute_address.static_ip.address
}

resource "gandi_livedns_record" "ncr-gcp" {
  zone       = var.domain
  name       = var.name
  type       = "A"
  ttl        = 300
  values     = [google_compute_address.static_ip.address]
  depends_on = [google_compute_instance.ncr_instance]
}

resource "null_resource" "wait_for_ping" {
  depends_on = [google_compute_instance.ncr_instance]

  provisioner "local-exec" {
    command = "../ping_new.sh ${local.hostname}"
  }
}

locals {
  depends_on       = null_resource.wait_for_ping
  hostname         = "${gandi_livedns_record.ncr-gcp.name}.${gandi_livedns_record.ncr-gcp.zone}"
  known_hosts_file = "~/.ssh/known_hosts"
}

output "instance_name" {
  description = "DNS name of Google cloud ncr instance"
  value       = local.hostname
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

# Generate the inventory/hosts.yml file
data "template_file" "ansible_inventory" {
  template = <<EOT
all:
  hosts:
    ${local.hostname}:
EOT
}

# Write the inventory file to the filesystem
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory/hosts.yml"
  content  = data.template_file.ansible_inventory.rendered
}

resource "null_resource" "add_ssh_key_to_known_hosts" {
  depends_on = [null_resource.wait_for_ping]
  triggers = {
    hostname         = local.hostname
    known_hosts_file = local.known_hosts_file
  }

  provisioner "local-exec" {
    command = "ssh-keyscan -H ${self.triggers.hostname} >> ${local.known_hosts_file}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "ssh-keygen -f ${self.triggers.known_hosts_file} -R ${self.triggers.hostname}"
  }
}

# Run Ansible after creating the instance
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.wait_for_ping, null_resource.add_ssh_key_to_known_hosts]

  provisioner "local-exec" {
    command = <<EOT
ansible-playbook -i ${local_file.ansible_inventory.filename} \
-e domain_name=${local.hostname} \
../install_ncr.yaml
EOT
  }
}
