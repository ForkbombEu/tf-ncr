variable "project_id" {
  description = "GCP project id"
  type = string
  default = "your-project-id"
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
  default = "/absolute/path/to/file.json"
}

variable "gandi_token" {
  sensitive = true
}

variable "ssh_user" {
  description = "Username for SSH access"
  type        = string
  default     = "your_username"
}

variable "ssh_pub_key_path" {
  description = "Path to your local public SSH key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "name" {}

variable "domain" {}
