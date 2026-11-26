# deterministic-operations-terraform-iac-testing-pipeline

![License: MIT-0](https://img.shields.io/badge/License-MIT--0-blue.svg)
![Huawei Cloud](https://img.shields.io/badge/Cloud-Huawei%20Cloud-red.svg)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple.svg)

## 1. Overview

This project builds a **CI/CT (Continuous Integration / Continuous Testing) pipeline** on Huawei Cloud for automatically testing Terraform Infrastructure as Code. When developers push Terraform code to the code repository, the pipeline automatically triggers and runs four testing tools: TFLint (code linting), Terraform Validate (syntax validation), Terratest (end-to-end testing), and Checkov (security scanning). It is designed for DevOps teams that want to catch IaC problems at the code-commit stage.

---

## 2. Table of Contents

- [1. Overview](#1-overview)
- [2. Table of Contents](#2-table-of-contents)
- [3. Architecture Diagram](#3-architecture-diagram)
- [4. Highlights](#4-highlights)
- [5. Cloud Services Used](#5-cloud-services-used)
- [6. Prerequisites](#6-prerequisites)
- [7. Quick Start](#7-quick-start)
- [8. Step-by-Step Deployment](#8-step-by-step-deployment)
- [9. Usage / Verification](#9-usage--verification)
- [10. Cleanup](#10-cleanup)
- [11. Detailed Explanation](#11-detailed-explanation)
- [12. Dependencies](#12-dependencies)
- [13. FAQ / Troubleshooting](#13-faq--troubleshooting)
- [14. Contributing](#14-contributing)
- [15. License](#15-license)
- [16. Contact / Maintainers](#16-contact--maintainers)

---

## 3. Architecture Diagram

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

---

## 4. Highlights

- **Automated IaC testing**: a code push triggers four testing tools without manual intervention
- **Parallel execution**: TFLint, Validate, and Terratest run in parallel; Checkov runs after TFLint completes
- **Security compliance**: OBS buckets are encrypted with KMS; Checkov scans plan files for security issues
- **One-click deployment**: all cloud resources are created with a single Terraform apply

---

## 5. Cloud Services Used

| Service | Purpose |
|---|---|
| CodeArts (Repository) | Hosts the Terraform IaC code repository |
| CodeArts (Build) | Runs the TFLint, Validate, Terratest, and Checkov build tasks |
| CodeArts (Pipeline) | Orchestrates the execution flow of the build tasks |
| OBS (Object Storage Service) | Stores build artifacts and logs |
| KMS (Key Management Service) | Encrypts the OBS buckets |

Cleanup reminder: after deployment, if the resources are no longer needed, run `terraform destroy` to release all resources and avoid residue.

---

## 6. Prerequisites

1. **Huawei Cloud account**: CodeArts service enabled with project-creation permission
2. **Terraform**: >= 1.5.7 installed locally
3. **Huawei Cloud CLI (hcloud)**: AK/SK credentials configured
4. **Region**: defaults to `cn-north-4`, configurable in `variables.tf`

---

## 7. Quick Start

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

---

## 8. Step-by-Step Deployment

1. **Prepare credentials**: configure AK/SK locally (see "6. Prerequisites"); do not write them into repository files.
2. **Initialize Terraform**: enter the `infra/` directory and run `terraform init` to download the huaweicloud provider.
3. **Review the plan**: run `terraform plan` to confirm the CodeArts project, repository, pipeline, and OBS buckets to be created.
4. **Apply the changes**: after confirming, run `terraform apply` and wait for all resources to be created.
5. **Get the outputs**: run `terraform output` to view the repository address, pipeline name, etc., for subsequent verification.

---

## 9. Usage / Verification

### Verify the deployment

After deployment, run the following commands to confirm that the resources were created correctly:

```bash
# View all outputs
terraform output

# Expected output example:
# codearts_project_name = "cict-terraform-testing"
# repository_https_url  = "https://codehub.devcloud.cn-north-4.huaweicloud.com/..."
# pipeline_name         = "cict-terraform-testing-pipeline"
# build_task_names      = ["tflint-check", "terraform-validate", "terratest-e2e", "checkov-scan"]
```

### Verify pipeline triggering

1. Clone the created code repository:
   ```bash
   git clone $(terraform output -raw repository_https_url)
   ```
2. Add a Terraform code file and push it:
   ```bash
   cd terraform-iac-scripts
   echo 'resource "huaweicloud_obs_bucket" "test" { bucket = "test-bucket" }' > test.tf
   git add . && git commit -m "Add test file" && git push origin main
   ```
3. Check the pipeline execution status in the CodeArts console.

### Verify the build tasks

In the CodeArts console > Pipeline page, confirm that all build tasks executed successfully:
- `tflint-check`: TFLint code linting
- `terraform-validate`: Terraform syntax validation
- `terratest-e2e`: Terratest end-to-end testing
- `checkov-scan`: Checkov security scanning

After deployment, follow these steps to verify that the business functionality works before considering the delivery complete.

---

## 10. Cleanup

```bash
cd infra
terraform destroy
```

---

## 11. Detailed Explanation

### Pipeline stages

| Stage | Task | Description |
|---|---|---|
| Source | Fetch-Code | Fetch the latest code from the code repository |
| IaC-Testing | TFLint | Check Terraform code conventions (parallel) |
| IaC-Testing | Terraform-Validate | Validate Terraform syntax (parallel) |
| IaC-Testing | Terratest-E2E | Run Go end-to-end tests (parallel) |
| IaC-Testing | Checkov-Scan | Scan security configuration (serial, depends on TFLint) |

### Configuration items

| Variable | Default | Description |
|---|---|---|
| `region` | `cn-north-4` | Deployment region |
| `codearts_project_name` | `cict-terraform-testing` | CodeArts project name |
| `repository_name` | `terraform-iac-scripts` | Code repository name |
| `terraform_version` | `1.5.7` | Terraform version in the build environment |
| `tflint_version` | `0.47.0` | TFLint version |
| `checkov_version` | `3.1.40` | Checkov version |

---

## 12. Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| Terraform | >= 1.5.7 | IaC deployment tool |
| huaweicloud Provider | ~> 1.60 | Huawei Cloud Terraform Provider |
| TFLint | 0.47.0 | Terraform code linter |
| Terratest | latest | Go end-to-end testing framework |
| Checkov | 3.1.40 | Security scanning tool |

---

## 13. FAQ / Troubleshooting

**Q: How to add a new testing tool?**
A: Add a new `huaweicloud_codearts_build_task` resource in `infra/codearts_build.tf`, then add the corresponding task entry to the `definition` JSON in `infra/codearts_pipeline.tf`.

**Q: How to change the pipeline trigger branch?**
A: Modify the `branches` variable in `variables.tf`.

**Q: How to troubleshoot build task failures?**
A: View the build logs in the CodeArts console > Build Tasks page. The logs are also stored in the OBS `build_logs` bucket.

---

## 14. Contributing

Issues and Pull Requests are welcome. Before submitting code, make sure the Terraform configuration passes `terraform fmt`, `terraform validate`, and the TFLint / Checkov checks integrated in this pipeline; when changing infrastructure resources, update the documentation under `docs/` accordingly.

---

## 15. License

This project is licensed under the MIT No Attribution license.

---

## 16. Contact / Maintainers
| Item | Content |
|---|---|
| **Creator** | [dgc-git](https://github.com/dgc-git) |
| **Maintainer** | [dgc-git](https://github.com/dgc-git) |
| **Contact** | GitHub Issues / PR (see [Section 14](#14-contributing)) |
