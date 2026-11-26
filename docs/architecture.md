# Architecture

## Overview

This project implements a Continuous Integration / Continuous Testing (CI/CT) pipeline for Terraform Infrastructure-as-Code (IaC) on Huawei Cloud. The pipeline automatically runs four testing tools against Terraform code whenever changes are pushed to the repository.

## Architecture Diagram

```
                    ┌─────────────────────────────────┐
                    │       CodeArts Repository        │
                    │    (Terraform IaC Scripts)       │
                    └──────────────┬──────────────────┘
                                   │ Push to branch
                                   ▼
                    ┌─────────────────────────────────┐
                    │       CodeArts Pipeline          │
                    │   (Triggered by code push)       │
                    └──────────────┬──────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │               │
                    ▼              ▼               ▼
            ┌──────────┐  ┌──────────┐   ┌──────────┐
            │  TFLint  │  │Validate  │   │Terratest │
            │  Check   │  │ Terraform│   │   E2E    │
            └────┬─────┘  └────┬─────┘   └────┬─────┘
                 │              │               │
                 └──────────────┤               │
                                ▼               │
                        ┌──────────┐            │
                        │ Checkov  │            │
                        │  Scan    │            │
                        └────┬─────┘            │
                             │                  │
                             ▼                  ▼
                    ┌─────────────────────────────────┐
                    │         OBS Buckets              │
                    │  (Artifacts + Logs Storage)      │
                    └─────────────────────────────────┘
```

## Components

### CodeArts Project
- Acts as the top-level container for all pipeline resources
- Created via `huaweicloud_codearts_project`

### CodeArts Repository (CodeHub)
- Hosts the Terraform IaC scripts
- Pipeline triggers on push events to the configured branch
- Created via `huaweicloud_codearts_repository`

### CodeArts Build Tasks
Four build tasks run in parallel (except Checkov which runs after TFLint):

1. **TFLint Check** - Lints Terraform code for formatting, naming conventions, and deprecated syntax
2. **Terraform Validate** - Validates Terraform syntax and configuration
3. **Terratest E2E** - Runs end-to-end tests using the Terratest Go framework
4. **Checkov Scan** - Scans the Terraform plan for security misconfigurations

### CodeArts Pipeline
- Orchestrates the build tasks in a multi-stage pipeline
- Source stage fetches code from the repository
- Testing stage runs the four build tasks
- Triggered automatically on code push

### OBS Buckets
- **Pipeline Artifacts bucket** - Stores build artifacts and test results
- **Build Logs bucket** - Stores build execution logs
- Both buckets are encrypted with KMS

### KMS Key
- Encrypts OBS buckets at rest
- Created via `huaweicloud_kms_key`

## Testing Tools

| Tool | Purpose | Configuration |
|------|---------|---------------|
| TFLint | Linter for Terraform | `.tflint.hcl` in `infra/` |
| terraform validate | Syntax validation | Built into Terraform CLI |
| Terratest | E2E testing framework | Go tests in `test/` directory |
| Checkov | Security scanner | Scans `terraform plan` JSON output |
