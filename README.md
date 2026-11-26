# deterministic-operations-terraform-iac-testing-pipeline

![License: MIT-0](https://img.shields.io/badge/License-MIT--0-blue.svg)
![Huawei Cloud](https://img.shields.io/badge/Cloud-Huawei%20Cloud-red.svg)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple.svg)

## 1. 简介 / Overview

### 简介


本项目在华为云上构建一条 **CI/CT（持续集成 / 持续测试）流水线**，用于自动测试 Terraform 基础设施即代码。当开发者将 Terraform 代码推送到代码仓库时，流水线自动触发并运行四类测试工具：TFLint（代码规范检查）、Terraform Validate（语法校验）、Terratest（端到端测试）和 Checkov（安全扫描）。适用于希望在代码提交阶段就发现 IaC 问题的 DevOps 团队。

---

## 2. 目录

- [1. 简介 / Overview](#1-简介--overview)
- [2. 目录](#2-目录)
- [3. 架构图](#3-架构图)
- [4. 方案亮点](#4-方案亮点)
- [5. 涉及云服务](#5-涉及云服务)
- [6. 前置条件](#6-前置条件)
- [7. 快速开始](#7-快速开始)
- [8. 分步部署](#8-分步部署)
- [9. 使用方法 / 验证](#9-使用方法--验证)
- [10. 清理资源](#10-清理资源)
- [11. 详细说明](#11-详细说明)
- [12. 依赖](#12-依赖)
- [13. FAQ / 故障排除](#13-faq--故障排除)
- [14. 贡献指南](#14-贡献指南)
- [15. 许可证](#15-许可证)
- [16. 联系方式 / 维护者](#16-联系方式--维护者)

---

## 3. 架构图

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

## 4. 方案亮点

- **自动化 IaC 测试**：代码推送即触发四类测试，无需人工干预
- **并行执行**：TFLint、Validate、Terratest 并行运行，Checkov 依赖 TFLint 完成后执行
- **安全合规**：OBS 存储桶通过 KMS 加密，Checkov 扫描计划文件中的安全问题
- **一键部署**：通过 Terraform 一键创建全部云资源

---

## 5. 涉及云服务

| 服务 | 用途 |
|------|------|
| CodeArts（代码托管） | 存放 Terraform IaC 代码仓库 |
| CodeArts（构建） | 运行 TFLint、Validate、Terratest、Checkov 构建任务 |
| CodeArts（流水线） | 编排构建任务的执行流程 |
| OBS（对象存储服务） | 存储构建产物和日志 |
| KMS（密钥管理服务） | 加密 OBS 存储桶 |

清理资源提示：部署完成后如不再使用，请执行 `terraform destroy` 释放所有资源，避免残留。

---

## 6. 前置条件

1. **华为云账号**：已开通 CodeArts 服务，具备项目创建权限
2. **Terraform**：本地安装 >= 1.5.7
3. **华为云 CLI（hcloud）**：已配置 AK/SK 凭证
4. **区域**：默认 `cn-north-4`，可根据需要修改 `variables.tf`

---

## 7. 快速开始

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

---

## 8. 分步部署

1. **准备凭证**：在本地配置 AK/SK（见「6. 前置条件」），勿写入仓库文件。
2. **初始化 Terraform**：进入 `infra/` 目录执行 `terraform init`，下载 huaweicloud provider。
3. **审阅计划**：执行 `terraform plan`，确认将创建的 CodeArts 项目、仓库、流水线与 OBS 桶。
4. **应用变更**：确认无误后执行 `terraform apply`，等待全部资源创建完成。
5. **获取输出**：执行 `terraform output` 查看仓库地址、流水线名称等，用于后续验证。

---

## 9. 使用方法 / 验证

### 使用方法与验证


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

---

## 10. 清理资源

```bash
cd infra
terraform destroy
```

---

## 11. 详细说明

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

---

## 12. 依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| Terraform | >= 1.5.7 | IaC 部署工具 |
| huaweicloud Provider | ~> 1.60 | 华为云 Terraform Provider |
| TFLint | 0.47.0 | Terraform 代码检查 |
| Terratest | latest | Go 端到端测试框架 |
| Checkov | 3.1.40 | 安全扫描工具 |

---

## 13. FAQ / 故障排除

### FAQ


**Q: 如何添加新的测试工具？**
A: 在 `infra/codearts_build.tf` 中添加新的 `huaweicloud_codearts_build_task` 资源，然后在 `infra/codearts_pipeline.tf` 的 `definition` JSON 中添加对应的任务条目。

**Q: 如何修改流水线触发分支？**
A: 修改 `variables.tf` 中的 `branches` 变量。

**Q: 构建任务失败如何排查？**
A: 在 CodeArts 控制台 > 构建任务页面查看构建日志，日志同时存储在 OBS `build_logs` 桶中。

---

## 14. 贡献指南

欢迎提交 Issue 与 Pull Request。提交代码前请确保 Terraform 配置通过 `terraform fmt`、`terraform validate` 以及本流水线集成的 TFLint / Checkov 检查；变更基础设施资源时请同步更新 `docs/` 下的说明文档。

---

## 15. 许可证

本项目采用 MIT No Attribution 许可证。

---

## 16. 联系方式 / 维护者
| 项 | 内容 |
|---|---|
| **创建者** | [dgc-git](https://github.com/dgc-git) |
| **维护者** | [dgc-git](https://github.com/dgc-git) |
| **联系方式** | GitHub Issues / PR（见[第 14 节](#14-贡献指南)） |
