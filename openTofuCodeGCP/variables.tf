variable "project_id" {
  default = "causal-axle-464911-u4" # IMPORTANT: this is provided by Google Cloud Platform, should match the project_id in credential.json
}

variable "region" {
  default = "europe-west1" # you can change this to your region
}

variable "zone" {
  default = "europe-west1-b" # you can change this to your region
}

variable "instance_name" {
  default = "ncr-instance" # leave this unchanged, it is invoked in main.tf
}

variable "machine_type" {
  default = "e2-medium" # you can change this to machine type you prefer
}

variable "ssh_username" {
  default = "my-username" # IMPORTANT: write here the user name you're currently logged in with. Ansible uses this to deploy NCR and you will use this to log in the VM via SSH
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"  # IMPORTANT: the path to your public key, will use this to log in the VM via SSH
}

variable "ssh_private_key_path" {
  default = "~/.ssh/id_rsa" # IMPORTANT: the path to your private key, will use this to log in the VM via SSH   
}

variable "domain_name" {
  default = "" # Will fall back to instance IP if left empty
}
