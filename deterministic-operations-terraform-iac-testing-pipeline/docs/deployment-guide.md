# Deployment Guide

## Prerequisites

1. **Huawei Cloud account** with CodeArts service enabled
2. **Terraform** >= 1.5.7 installed locally
3. **Huawei Cloud CLI (hcloud)** configured with AK/SK credentials
4. **CodeArts project** creation permission

## Step-by-Step Deployment

### Step 1: Configure Credentials

Configure your Huawei Cloud credentials using one of the following methods:

**Method A: Environment Variables**
```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION="cn-north-4"
```

**Method B: hcloud CLI**
```bash
hcloud configure set --ak=your-access-key --sk=your-secret-key --region=cn-north-4
```

### Step 2: Initialize Terraform

```bash
cd infra
terraform init
```

Expected output:
```
Initializing the backend...
Initializing provider plugins...
- Finding huaweicloud/huaweicloud versions matching "~> 1.60"...
- Installing huaweicloud/huaweicloud v1.60.x...
...
Terraform has been successfully initialized!
```

### Step 3: Review the Plan

```bash
terraform plan
```

Review the resources that will be created:
- 1 CodeArts Project
- 1 CodeArts Repository
- 4 CodeArts Build Tasks
- 1 CodeArts Pipeline
- 2 OBS Buckets
- 1 KMS Key

### Step 4: Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Step 5: Verify the Deployment

```bash
terraform output
```

You should see outputs including:
- `codearts_project_name` - The CodeArts project name
- `repository_https_url` - URL for cloning the repository
- `pipeline_name` - The pipeline name
- `build_task_names` - List of build task names

### Step 6: Push Code to the Repository

Clone the repository and push your Terraform IaC code:

```bash
git clone <repository_https_url>
cd terraform-iac-scripts
# Add your Terraform files
git add .
git commit -m "Add Terraform IaC code"
git push origin main
```

The pipeline will automatically trigger on push.

### Step 7: Monitor Pipeline Execution

Navigate to the CodeArts console to monitor pipeline execution:
1. Go to CodeArts > Pipelines
2. Find the pipeline named `cict-terraform-testing-pipeline`
3. Click to view execution history and build logs

## Cleanup

To destroy all created resources:

```bash
cd infra
terraform destroy
```

Type `yes` when prompted to confirm.
