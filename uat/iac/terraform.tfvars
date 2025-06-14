# Example terraform.tfvars file
# Rename this to terraform.tfvars and fill in the sensitive values.

# --- Required --- #
db_password        = "yourpassword"
n8n_encryption_key = "yourkey"

# --- Optional (Defaults are likely suitable based on your setup) --- #
gcp_project_id = "palyground-457408"
gcp_region     = "asia-east1"

credentials_file = "yourjsonkey"

db_name                  = "n8n"
db_user                  = "n8n-user"
db_tier                  = "db-f1-micro"
db_storage_size          = 10
artifact_repo_name       = "n8n-repo"
cloud_run_service_name   = "n8n"
service_account_name     = "n8n-service-account"
cloud_run_cpu            = "2"
cloud_run_memory         = "2Gi"
cloud_run_max_instances  = 1
cloud_run_container_port = 5678
generic_timezone         = "UTC"
