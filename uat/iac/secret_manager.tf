# --- Secret Manager --- #
resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "${var.cloud_run_service_name}-db-password"
  project   = var.gcp_project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = var.db_password
}

resource "google_secret_manager_secret" "encryption_key_secret" {
  secret_id = "${var.cloud_run_service_name}-encryption-key"
  project   = var.gcp_project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "encryption_key_secret_version" {
  secret      = google_secret_manager_secret.encryption_key_secret.id
  secret_data = var.n8n_encryption_key
}
