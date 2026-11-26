# ============================================================
# CodeArts Pipeline Definition
# ============================================================

# Pipeline that orchestrates the IaC testing build tasks
# is_publish = true means this is a change-triggered pipeline
# (automatically runs when code is pushed to the repository)
resource "huaweicloud_codearts_pipeline" "cict_pipeline" {
  name        = "${var.codearts_project_name}-pipeline"
  project_id  = huaweicloud_codearts_project.cict_project.id
  is_publish  = true
  description = "CI/CT pipeline for testing Terraform IaC code"

  sources {
    type = "code"
    params {
      codehub_id     = huaweicloud_codearts_project.cict_project.id
      repo_name      = huaweicloud_codearts_repository.iac_repo.name
      default_branch = var.branches[0]
      git_url        = huaweicloud_codearts_repository.iac_repo.https_url
    }
  }

  definition = jsonencode({
    stages = [
      {
        name     = "Source"
        sequence = 1
        tasks = [
          {
            name = "Fetch-Code"
            type = "codehub"
            inputs = {
              repository = huaweicloud_codearts_repository.iac_repo.name
              branch     = var.branches[0]
            }
          }
        ]
      },
      {
        name     = "IaC-Testing"
        sequence = 2
        parallel = true
        tasks = [
          {
            name       = "TFLint"
            type       = "build"
            build_task = huaweicloud_codearts_build_task.tflint.name
            run_order  = 1
          },
          {
            name       = "Terraform-Validate"
            type       = "build"
            build_task = huaweicloud_codearts_build_task.validate.name
            run_order  = 1
          },
          {
            name       = "Terratest-E2E"
            type       = "build"
            build_task = huaweicloud_codearts_build_task.terratest.name
            run_order  = 1
          },
          {
            name       = "Checkov-Scan"
            type       = "build"
            build_task = huaweicloud_codearts_build_task.checkov.name
            run_order  = 2
          }
        ]
      }
    ]
  })
}
