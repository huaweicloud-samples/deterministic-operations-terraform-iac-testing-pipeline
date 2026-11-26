# ============================================================
# Variables for CI/CT Terraform IaC Testing Pipeline
# ============================================================

variable "region" {
  description = "Region where the resources will be deployed"
  type        = string
  default     = "cn-north-4"
}

variable "codearts_project_name" {
  description = "Name of the CodeArts project"
  type        = string
  default     = "cict-terraform-testing"
}

variable "codearts_project_type" {
  description = "Type of the CodeArts project"
  type        = string
  default     = "scrum"
}

variable "repository_name" {
  description = "Name of the code repository to be created"
  type        = string
  default     = "terraform-iac-scripts"
}

variable "repository_description" {
  description = "Description of the code repository"
  type        = string
  default     = "Repository for Terraform IaC scripts tested by CI/CT pipeline"
}

variable "obs_bucket_name_prefix" {
  description = "Prefix for OBS bucket names used as artifact storage"
  type        = string
  default     = "cict-artifacts"
}

variable "build_task_flavor" {
  description = "Flavor of the build execution environment"
  type        = string
  default     = "DEFAULT"
}

variable "build_task_arch" {
  description = "Architecture of the build execution environment"
  type        = string
  default     = "x86-64"
}

variable "custom_tags" {
  description = "Tags applied to resources that support tagging"
  type        = map(string)
  default = {
    Environment    = "Testing"
    DeploymentType = "Terraform"
    Application    = "cict-pipeline"
  }
}

variable "branches" {
  description = "Branches to trigger the pipeline"
  type        = list(string)
  default     = ["main"]
}

variable "terraform_version" {
  description = "Terraform version installed in build environment"
  type        = string
  default     = "1.5.7"
}

variable "tflint_version" {
  description = "TFLint version installed in build environment"
  type        = string
  default     = "0.47.0"
}

variable "checkov_version" {
  description = "Checkov version installed in build environment"
  type        = string
  default     = "2.3.290"
}
