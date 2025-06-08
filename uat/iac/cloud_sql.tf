# --- Cloud SQL --- #
resource "google_sql_database_instance" "n8n_db_instance" {
  name             = "${var.cloud_run_service_name}-db" # Use service name prefix for uniqueness
  project          = var.gcp_project_id
  region           = var.gcp_region
  database_version = "POSTGRES_13"
  settings {
    tier              = var.db_tier
    availability_type = "ZONAL"  # Match guide
    disk_type         = "PD_HDD" # Match guide
    disk_size         = var.db_storage_size
    backup_configuration {
      enabled = false # Match guide
    }
  }
  deletion_protection = false # Allow deletion in Terraform
  depends_on          = [google_project_service.sqladmin]
}

resource "google_sql_database" "n8n_database" {
  name     = var.db_name
  instance = google_sql_database_instance.n8n_db_instance.name
  project  = var.gcp_project_id
}

resource "google_sql_user" "n8n_user" {
  name     = var.db_user
  instance = google_sql_database_instance.n8n_db_instance.name
  password = var.db_password
  project  = var.gcp_project_id
}
