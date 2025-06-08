# --- Artifact Registry --- #
# resource "google_artifact_registry_repository" "n8n_repo" {
#   project       = var.gcp_project_id
#   location      = var.gcp_region
#   repository_id = var.artifact_repo_name
#   description   = "Repository for n8n workflow images"
#   format        = "DOCKER"
#   depends_on    = [google_project_service.artifactregistry]
# }
