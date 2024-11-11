variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "location" {
  description = "Location for resources"
  type        = string
}

variable "gcp_credentials_file" {
  description = "Path to GCP credentials JSON file"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "n1-standard-1"
}

variable "vm_os" {
  description = "Operating system for the VM"
  type        = string
  default     = "debian-cloud/debian-10"
}

variable "resource_group_count" {
  description = "Number of resource groups"
  type        = number
  default     = 2
}