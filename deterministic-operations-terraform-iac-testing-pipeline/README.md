# deterministic-operations-terraform-iac-testing-pipeline

![License: MIT-0](https://img.shields.io/badge/License-MIT--0-blue.svg)
![Huawei Cloud](https://img.shields.io/badge/Cloud-Huawei%20Cloud-red.svg)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple.svg)

## 简介

本项目在华为云上构建一条 **CI/CT（持续集成 / 持续测试）流水线**，用于自动测试 Terraform 基础设施即代码。当开发者将 Terraform 代码推送到代码仓库时，流水线自动触发并运行四类测试工具：TFLint（代码规范检查）、Terraform Validate（语法校验）、Terratest（端到端测试）和 Checkov（安全扫描）。适用于希望在代码提交阶段就发现 IaC 问题的 DevOps 团队。

## 目录

- [架构图](#架构图)
- [方案亮点](#方案亮点)
- [涉及云服务](#涉及云服务)
- [前置条件](#前置条件)
- [快速开始](#快速开始)
- [使用方法与验证](#使用方法与验证)
- [清理资源](#清理资源)
- [详细说明](#详细说明)
- [依赖](#依赖)
- [FAQ](#faq)
- [许可证](#许可证)
- [联系方式](#联系方式)

## 架构图

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

## 方案亮点

- **自动化 IaC 测试**：代码推送即触发四类测试，无需人工干预
- **并行执行**：TFLint、Validate、Terratest 并行运行，Checkov 依赖 TFLint 完成后执行
- **安全合规**：OBS 存储桶通过 KMS 加密，Checkov 扫描计划文件中的安全问题
- **一键部署**：通过 Terraform 一键创建全部云资源

## 涉及云服务

| 服务 | 用途 |
|------|------|
| CodeArts（代码托管） | 存放 Terraform IaC 代码仓库 |
| CodeArts（构建） | 运行 TFLint、Validate、Terratest、Checkov 构建任务 |
| CodeArts（流水线） | 编排构建任务的执行流程 |
| OBS（对象存储服务） | 存储构建产物和日志 |
| KMS（密钥管理服务） | 加密 OBS 存储桶 |

清理资源提示：部署完成后如不再使用，请执行 `terraform destroy` 释放所有资源，避免残留。

## 前置条件

1. **华为云账号**：已开通 CodeArts 服务，具备项目创建权限
2. **Terraform**：本地安装 >= 1.5.7
3. **华为云 CLI（hcloud）**：已配置 AK/SK 凭证
4. **区域**：默认 `cn-north-4`，可根据需要修改 `variables.tf`

## 快速开始

```bash
# 1. 配置凭证
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION="cn-north-4"

# 2. 部署
cd infra
terraform init
terraform apply
```

## 使用方法与验证

### 验证部署

部署完成后，执行以下命令验证资源已正确创建：

```bash
# 查看所有输出
terraform output

# 预期输出示例：
# codearts_project_name = "cict-terraform-testing"
# repository_https_url  = "https://codehub.devcloud.cn-north-4.huaweicloud.com/..."
# pipeline_name         = "cict-terraform-testing-pipeline"
# build_task_names      = ["tflint-check", "terraform-validate", "terratest-e2e", "checkov-scan"]
```

### 验证流水线触发

1. 克隆创建的代码仓库：
   ```bash
   git clone $(terraform output -raw repository_https_url)
   ```
2. 添加 Terraform 代码文件并推送：
   ```bash
   cd terraform-iac-scripts
   echo 'resource "huaweicloud_obs_bucket" "test" { bucket = "test-bucket" }' > test.tf
   git add . && git commit -m "Add test file" && git push origin main
   ```
3. 在 CodeArts 控制台查看流水线执行状态

### 验证构建任务

在 CodeArts 控制台 > 流水线页面，确认以下构建任务均执行成功：
- `tflint-check`：TFLint 代码规范检查
- `terraform-validate`：Terraform 语法校验
- `terratest-e2e`：Terratest 端到端测试
- `checkov-scan`：Checkov 安全扫描

> 部署完成后请按本节步骤自行验证，确认业务功能可用，方可视为交付完成。

## 清理资源

```bash
cd infra
terraform destroy
```

## 详细说明

### 流水线阶段

| 阶段 | 任务 | 说明 |
|------|------|------|
| Source | Fetch-Code | 从代码仓库拉取最新代码 |
| IaC-Testing | TFLint | 检查 Terraform 代码规范（并行） |
| IaC-Testing | Terraform-Validate | 校验 Terraform 语法（并行） |
| IaC-Testing | Terratest-E2E | 运行 Go 端到端测试（并行） |
| IaC-Testing | Checkov-Scan | 扫描安全配置（串行，依赖 TFLint） |

### 配置项

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `region` | `cn-north-4` | 部署区域 |
| `codearts_project_name` | `cict-terraform-testing` | CodeArts 项目名 |
| `repository_name` | `terraform-iac-scripts` | 代码仓库名 |
| `terraform_version` | `1.5.7` | 构建环境 Terraform 版本 |
| `tflint_version` | `0.47.0` | TFLint 版本 |
| `checkov_version` | `3.1.40` | Checkov 版本 |

## 依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| Terraform | >= 1.5.7 | IaC 部署工具 |
| huaweicloud Provider | ~> 1.60 | 华为云 Terraform Provider |
| TFLint | 0.47.0 | Terraform 代码检查 |
| Terratest | latest | Go 端到端测试框架 |
| Checkov | 3.1.40 | 安全扫描工具 |

## FAQ

**Q: 如何添加新的测试工具？**
A: 在 `infra/codearts_build.tf` 中添加新的 `huaweicloud_codearts_build_task` 资源，然后在 `infra/codearts_pipeline.tf` 的 `definition` JSON 中添加对应的任务条目。

**Q: 如何修改流水线触发分支？**
A: 修改 `variables.tf` 中的 `branches` 变量。

**Q: 构建任务失败如何排查？**
A: 在 CodeArts 控制台 > 构建任务页面查看构建日志，日志同时存储在 OBS `build_logs` 桶中。

## 许可证

本项目采用 MIT No Attribution 许可证。

## 联系方式

- 维护者：`<github-username>`
- 交流渠道：[GitHub Issues](https://github.com/<github-username>/deterministic-operations-terraform-iac-testing-pipeline/issues)
