variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "storage_account_name" {
  description = "Storage account name"
  type        = string
  default     = "examplestorageacct"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
}

variable "user_data" {
  description = "Path to the ecd configuration shell script file"
  type        = string
}