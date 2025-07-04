variable "project_id" {
  description = "GCP project id"
  type = string
  default = "causal-axle-464911-u4"
}

variable "region" {
  description = "GCP region"
  type = string
  default = "europe-west1"
}

variable "instance_type" {
  description = "CGP instance type"
  type = string
  default = "e2-micro"
}

variable "credentials_file" {
  default = "/home/antoniotrkdz/dyne/tf-ncr/credentials.json"
}

variable "gandi_token" {
  sensitive = true
}

variable "ssh_user" {
  description = "Username for SSH access"
  type        = string
  default     = "antoniotrkdz"
}

variable "ssh_pub_key_path" {
  description = "Path to your local public SSH key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "name" {}

variable "domain" {}