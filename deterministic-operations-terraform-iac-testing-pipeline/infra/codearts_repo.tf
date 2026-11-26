# ============================================================
# CodeArts Project and Repository
# ============================================================

# CodeArts project to host the pipeline resources
resource "huaweicloud_codearts_project" "cict_project" {
  name        = var.codearts_project_name
  type        = var.codearts_project_type
  description = "Project for CI/CT Terraform IaC testing pipeline"
}

# Code repository for storing Terraform IaC scripts
resource "huaweicloud_codearts_repository" "iac_repo" {
  project_id       = huaweicloud_codearts_project.cict_project.id
  name             = var.repository_name
  description      = var.repository_description
  enable_readme    = 1
  visibility_level = 0
}
