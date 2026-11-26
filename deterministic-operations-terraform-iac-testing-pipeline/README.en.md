# deterministic-operations-terraform-iac-testing-pipeline

![License: MIT-0](https://img.shields.io/badge/License-MIT--0-blue.svg)
![Huawei Cloud](https://img.shields.io/badge/Cloud-Huawei%20Cloud-red.svg)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple.svg)

## Overview

This project builds a **CI/CT (Continuous Integration / Continuous Testing) pipeline** on Huawei Cloud for automatically testing Terraform Infrastructure-as-Code. When developers push Terraform code to the repository, the pipeline automatically triggers and runs four testing tools: TFLint (code linting), Terraform Validate (syntax validation), Terratest (end-to-end testing), and Checkov (security scanning). Designed for DevOps teams who want to catch IaC issues at the code commit stage.

## Table of Contents

- [Architecture Diagram](#architecture-diagram)
- [Highlights](#highlights)
- [Cloud Services](#cloud-services)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Usage and Verification](#usage-and-verification)
- [Cleanup](#cleanup)
- [Details](#details)
- [Dependencies](#dependencies)
- [FAQ](#faq)
- [License](#license)
- [Contact](#contact)

## Architecture Diagram

```
  CodeArts Repository ──push──▶ CodeArts Pipeline
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                  ▼
              ┌─────────┐    ┌───────────┐      ┌───────────┐
              │ TFLint  │    │ Validate  │      │ Terratest │
              └────┬───┘    └─────┬─────┘      └─────┬─────┘
                   │              │                   │
                   └──────────────┤                   │
                                  ▼                   │
                          ┌───────────┐               │
                          │  Checkov  │               │
                          └─────┬─────┘               │
                                │                     ▼
                                ▼              ┌─────────────┐
                        ┌──────────────┐      │ OBS Buckets │
                        │ OBS Buckets  │◀─────│ (Artifacts) │
                        └──────────────┘      └─────────────┘
```

## Highlights

- **Automated IaC Testing**: Code push triggers four testing tools automatically
- **Parallel Execution**: TFLint, Validate, and Terratest run in parallel; Checkov runs after TFLint
- **Security Compliance**: OBS buckets encrypted with KMS; Checkov scans plan files for security issues
- **One-Click Deployment**: All cloud resources created via a single Terraform apply

## Cloud Services

| Service | Purpose |
|---------|---------|
| CodeArts (Repository) | Hosts Terraform IaC code repository |
| CodeArts (Build) | Runs TFLint, Validate, Terratest, Checkov build tasks |
| CodeArts (Pipeline) | Orchestrates build task execution flow |
| OBS (Object Storage Service) | Stores build artifacts and logs |
| KMS (Key Management Service) | Encrypts OBS buckets |

Cleanup reminder: After deployment, if no longer needed, run `terraform destroy` to release all resources and avoid residuals.

## Prerequisites

1. **Huawei Cloud account**: CodeArts service enabled, project creation permission
2. **Terraform**: >= 1.5.7 installed locally
3. **Huawei Cloud CLI (hcloud)**: AK/SK credentials configured
4. **Region**: Default `cn-north-4`, configurable in `variables.tf`

## Quick Start

```bash
# 1. Configure credentials
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION="cn-north-4"

# 2. Deploy
cd infra
terraform init
terraform apply
```

## Usage and Verification

### Verify Deployment

After deployment, run the following commands to verify resources are correctly created:

```bash
# View all outputs
terraform output

# Expected output example:
# codearts_project_name = "cict-terraform-testing"
# repository_https_url  = "https://codehub.devcloud.cn-north-4.huaweicloud.com/..."
# pipeline_name         = "cict-terraform-testing-pipeline"
# build_task_names      = ["tflint-check", "terraform-validate", "terratest-e2e", "checkov-scan"]
```

### Verify Pipeline Trigger

1. Clone the created repository:
   ```bash
   git clone $(terraform output -raw repository_https_url)
   ```
2. Add Terraform code files and push:
   ```bash
   cd terraform-iac-scripts
   echo 'resource "huaweicloud_obs_bucket" "test" { bucket = "test-bucket" }' > test.tf
   git add . && git commit -m "Add test file" && git push origin main
   ```
3. Check pipeline execution status in the CodeArts console

### Verify Build Tasks

In the CodeArts console > Pipeline page, confirm all build tasks execute successfully:
- `tflint-check`: TFLint code linting
- `terraform-validate`: Terraform syntax validation
- `terratest-e2e`: Terratest end-to-end testing
- `checkov-scan`: Checkov security scanning

> After deployment, please verify according to the steps above to confirm functionality before considering delivery complete.

## Cleanup

```bash
cd infra
terraform destroy
```

## Details

### Pipeline Stages

| Stage | Task | Description |
|-------|------|-------------|
| Source | Fetch-Code | Fetch latest code from repository |
| IaC-Testing | TFLint | Check Terraform code conventions (parallel) |
| IaC-Testing | Terraform-Validate | Validate Terraform syntax (parallel) |
| IaC-Testing | Terratest-E2E | Run Go end-to-end tests (parallel) |
| IaC-Testing | Checkov-Scan | Scan security configuration (serial, depends on TFLint) |

### Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `cn-north-4` | Deployment region |
| `codearts_project_name` | `cict-terraform-testing` | CodeArts project name |
| `repository_name` | `terraform-iac-scripts` | Code repository name |
| `terraform_version` | `1.5.7` | Terraform version in build environment |
| `tflint_version` | `0.47.0` | TFLint version |
| `checkov_version` | `3.1.40` | Checkov version |

## Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| Terraform | >= 1.5.7 | IaC deployment tool |
| huaweicloud Provider | ~> 1.60 | Huawei Cloud Terraform Provider |
| TFLint | 0.47.0 | Terraform code linter |
| Terratest | latest | Go end-to-end testing framework |
| Checkov | 3.1.40 | Security scanner |

## FAQ

**Q: How to add a new testing tool?**
A: Add a new `huaweicloud_codearts_build_task` resource in `infra/codearts_build.tf`, then add a corresponding task entry in the `definition` JSON in `infra/codearts_pipeline.tf`.

**Q: How to change the pipeline trigger branch?**
A: Modify the `branches` variable in `variables.tf`.

**Q: How to troubleshoot build task failures?**
A: View build logs in CodeArts console > Build Tasks page. Logs are also stored in the OBS `build_logs` bucket.

## License

This project is licensed under MIT No Attribution.

## Contact

- Maintainer: `<github-username>`
- Communication: [GitHub Issues](https://github.com/<github-username>/deterministic-operations-terraform-iac-testing-pipeline/issues)
