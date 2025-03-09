# variables.tf

variable "prefix" {
  description = "Prefix for resource names"
  default     = "loginapp"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "login-app-resources"
}

variable "location" {
  description = "Azure region to deploy resources"
  default     = "eastus"
}

variable "admin_username" {
  description = "Username for the VM"
  default     = "azureuser"
}

variable "public_key_path" {
  description = "Path to the public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "domain_name_label" {
  description = "DNS label for the public IP"
  default     = "login-app-demo"
}