resource "random_string" "website_suffix" {
  length  = 8
  special = false
}

resource "random_string" "logs_suffix" {
  length  = 8
  special = false
}

resource "google_storage_bucket" "website_bucket" {
  name     = "rga-assessment-${random_string.website_suffix.result}"
  location = var.location
}

resource "google_storage_bucket" "access_logs_bucket" {
  name     = "rga-assessment-access-logs-${random_string.logs_suffix.result}"
  location = var.location
}