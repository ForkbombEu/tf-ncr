provider "google" {
  credentials = file("credential.json")
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}


resource "google_compute_instance" "ncr_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
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


resource "null_resource" "wait_for_ping" {
  provisioner "local-exec" {
    command = "../ping_new.sh ${google_compute_instance.ncr_instance.network_interface.0.access_config.0.nat_ip}"
  }

  depends_on = [google_compute_instance.ncr_instance]
}

resource "null_resource" "add_ssh_key_to_known_hosts" {
  provisioner "local-exec" {
    command = "ssh-keyscan -4 -H ${google_compute_instance.ncr_instance.network_interface.0.access_config.0.nat_ip} >> ~/.ssh/known_hosts || true"
  }

  depends_on = [null_resource.wait_for_ping]
}

resource "local_file" "ansible_inventory" {
  content = yamlencode({
    all = {
      hosts = {
        "${google_compute_instance.ncr_instance.network_interface.0.access_config.0.nat_ip}" = {
          ansible_user                 = var.ssh_username
          ansible_ssh_private_key_file = var.ssh_private_key_path
        }
      }
    }
  })

  filename = "${path.module}/inventory/hosts.yml"
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./inventory/hosts.yml -e domain_name=${var.domain_name != "" ? var.domain_name : google_compute_instance.ncr_instance.network_interface.0.access_config.0.nat_ip} ../install_ncr.yaml"
  }

  depends_on = [
    null_resource.add_ssh_key_to_known_hosts,
    local_file.ansible_inventory
  ]
}


output "ncr_address" {
  value = "http://${google_compute_instance.ncr_instance.network_interface.0.access_config.0.nat_ip}:8080/docs"
}
