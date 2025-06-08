terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file) # ← 讀入你的 SA key
  project     = var.gcp_project_id
  region      = var.gcp_region
}

# Data source to get the project number
data "google_project" "project" {
  project_id = var.gcp_project_id
}
