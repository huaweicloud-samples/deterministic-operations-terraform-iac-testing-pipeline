# ============================================================
# Outputs
# ============================================================

output "codearts_project_name" {
  description = "Name of the CodeArts project"
  value       = huaweicloud_codearts_project.cict_project.name
}

output "codearts_project_id" {
  description = "ID of the CodeArts project"
  value       = huaweicloud_codearts_project.cict_project.id
}

output "repository_name" {
  description = "Name of the code repository"
  value       = huaweicloud_codearts_repository.iac_repo.name
}

output "repository_https_url" {
  description = "HTTPS URL for cloning the repository"
  value       = huaweicloud_codearts_repository.iac_repo.https_url
}

output "pipeline_name" {
  description = "Name of the CI/CT pipeline"
  value       = huaweicloud_codearts_pipeline.cict_pipeline.name
}

output "build_task_names" {
  description = "Names of the build tasks"
  value = [
    huaweicloud_codearts_build_task.tflint.name,
    huaweicloud_codearts_build_task.validate.name,
    huaweicloud_codearts_build_task.terratest.name,
    huaweicloud_codearts_build_task.checkov.name,
  ]
}

output "pipeline_artifacts_bucket" {
  description = "OBS bucket for pipeline artifacts"
  value       = huaweicloud_obs_bucket.pipeline_artifacts.bucket
}

output "build_logs_bucket" {
  description = "OBS bucket for build logs"
  value       = huaweicloud_obs_bucket.build_logs.bucket
}

output "kms_key_alias" {
  description = "KMS key alias for artifact encryption"
  value       = huaweicloud_kms_key.artifact_key.key_alias
}
