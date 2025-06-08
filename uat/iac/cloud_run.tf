# cloud_run.tf: Public test deployment of n8n on Cloud Run v2 with env-based port binding

locals {
  # Pre-built image in Artifact Registry
  n8n_image_name = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${var.artifact_repo_name}/${var.cloud_run_service_name}:custom"
}

resource "google_cloud_run_v2_service" "n8n" {
  name     = var.cloud_run_service_name
  location = var.gcp_region
  project  = var.gcp_project_id

  ingress             = "INGRESS_TRAFFIC_ALL" # Allow unauthenticated
  deletion_protection = false                 # Ensure this is false

  template {
    service_account = google_service_account.n8n_sa.email
    scaling {
      max_instance_count = var.cloud_run_max_instances # Guide uses 1
      min_instance_count = 0
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.n8n_db_instance.connection_name]
      }
    }
    containers {
      image = local.n8n_image_name # IMPORTANT: Build and push this image manually first
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
      ports {
        container_port = var.cloud_run_container_port
      }
      resources {
        limits = {
          cpu    = var.cloud_run_cpu
          memory = var.cloud_run_memory
        }
        startup_cpu_boost = true
      }
      env {
        name  = "N8N_PATH"
        value = "/"
      }

      env {
        name  = "N8N_PORT"
        value = "443"
      }
      env {
        name  = "N8N_PROTOCOL"
        value = "https"
      }
      env {
        name  = "DB_TYPE"
        value = "postgresdb"
      }
      env {
        name  = "DB_POSTGRESDB_DATABASE"
        value = var.db_name
      }
      env {
        name  = "DB_POSTGRESDB_USER"
        value = var.db_user
      }
      env {
        name  = "DB_POSTGRESDB_HOST"
        value = "/cloudsql/${google_sql_database_instance.n8n_db_instance.connection_name}"
      }
      env {
        name  = "DB_POSTGRESDB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_POSTGRESDB_SCHEMA"
        value = "public"
      }
      env {
        name  = "N8N_USER_FOLDER"
        value = "/home/node/.n8n"
      }
      env {
        name  = "GENERIC_TIMEZONE"
        value = var.generic_timezone
      }
      env {
        name  = "QUEUE_HEALTH_CHECK_ACTIVE"
        value = "true"
      }
      env {
        name = "DB_POSTGRESDB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password_secret.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "N8N_ENCRYPTION_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.encryption_key_secret.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "N8N_HOST"
        # Construct hostname dynamically using project number and region
        value = "${var.cloud_run_service_name}-${data.google_project.project.number}.${var.gcp_region}.run.app"
      }
      env {
        name = "N8N_WEBHOOK_URL" # Deprecated but may be needed by older nodes/workflows
        # Construct URL dynamically using project number and region
        value = "https://${var.cloud_run_service_name}-${data.google_project.project.number}.${var.gcp_region}.run.app"
      }
      env {
        name = "N8N_EDITOR_BASE_URL"
        # Construct URL dynamically using project number and region
        value = "https://${var.cloud_run_service_name}-${data.google_project.project.number}.${var.gcp_region}.run.app"
      }
      env {
        name = "WEBHOOK_URL" # Current version
        # Construct URL dynamically using project number and region
        value = "https://${var.cloud_run_service_name}-${data.google_project.project.number}.${var.gcp_region}.run.app"
      }
      env {
        name  = "N8N_RUNNERS_ENABLED"
        value = "true"
      }
      env {
        name  = "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS"
        value = "true"
      }
      env {
        name  = "N8N_DIAGNOSTICS_ENABLED"
        value = "false"
      }
      env {
        name  = "DB_POSTGRESDB_CONNECTION_TIMEOUT"
        value = "60000"
      }
      env {
        name  = "DB_POSTGRESDB_ACQUIRE_TIMEOUT"
        value = "60000"
      }
      env {
        name  = "EXECUTIONS_PROCESS" # Added from GitHub issue solution
        value = "main"
      }
      env {
        name  = "EXECUTIONS_MODE" # Added from GitHub issue solution
        value = "regular"
      }
      env {
        name  = "N8N_LOG_LEVEL" # Added from GitHub issue solution
        value = "debug"
      }

      startup_probe {
        initial_delay_seconds = 120 # Added from GitHub issue solution
        timeout_seconds       = 240
        period_seconds        = 10 # Reduced period for faster checks
        failure_threshold     = 3  # Standard threshold
        tcp_socket {
          port = var.cloud_run_container_port
        }
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

# Grant public invocation for testing
# resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
#   project  = google_cloud_run_v2_service.n8n.project
#   location = google_cloud_run_v2_service.n8n.location
#   name     = google_cloud_run_v2_service.n8n.name
#   role     = "roles/run.invoker"
#   member   = "allUsers"
# }

resource "google_cloud_run_v2_service_iam_member" "tester_invoker" {
  project  = google_cloud_run_v2_service.n8n.project
  location = google_cloud_run_v2_service.n8n.location
  name     = google_cloud_run_v2_service.n8n.name
  role     = "roles/run.invoker"
  member   = "user:martin@perltsai.altostrat.com"
}

resource "google_cloud_run_v2_service_iam_member" "auth_invoker" {
  project  = google_cloud_run_v2_service.n8n.project
  location = google_cloud_run_v2_service.n8n.location
  name     = google_cloud_run_v2_service.n8n.name
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}
