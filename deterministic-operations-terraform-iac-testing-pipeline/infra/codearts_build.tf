# ============================================================
# CodeArts Build Tasks for IaC Testing
# ============================================================

# --- TFLint Build Task ---
resource "huaweicloud_codearts_build_task" "tflint" {
  name       = "tflint-check"
  project_id = huaweicloud_codearts_project.cict_project.id
  arch       = var.build_task_arch
  flavor     = var.build_task_flavor

  scms {
    scm_type  = "codehub"
    url       = huaweicloud_codearts_repository.iac_repo.https_url
    branch    = var.branches[0]
    repo_id   = tostring(huaweicloud_codearts_repository.iac_repo.repository_id)
    repo_name = huaweicloud_codearts_repository.iac_repo.name
  }

  steps {
    enable    = true
    name      = "Install Tools"
    module_id = "devcloud2018.codeci_action_20017.action"
    properties = {
      image   = "shell4.2.46-git1.8.3-zip6.00"
      command = <<-EOT
        export TOOLS_DIR=$HOME/.local/bin
        mkdir -p $TOOLS_DIR
        export PATH=$TOOLS_DIR:$PATH
        # Configure Terraform CLI to use Huawei Cloud provider mirror
        cat > $HOME/.terraformrc << 'TFRC'
        provider_installation {
          network_mirror {
            url    = "https://mirrors.huaweicloud.com/terraform/"
            include = ["huaweicloud/huaweicloud"]
          }
          direct {
            exclude = ["huaweicloud/huaweicloud"]
          }
        }
        TFRC
        # Install Terraform
        curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${var.terraform_version}/terraform_${var.terraform_version}_linux_amd64.zip
        unzip -o /tmp/terraform.zip -d $TOOLS_DIR
        terraform version
        # Install TFLint - download binary directly from GitHub releases
        curl -sL -o /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${var.tflint_version}/tflint_linux_amd64.zip
        unzip -o /tmp/tflint.zip -d $TOOLS_DIR
        tflint --version
      EOT
    }
  }

  steps {
    enable    = true
    name      = "Run TFLint"
    module_id = "devcloud2018.codeci_action_20017.action"
    properties = {
      image   = "shell4.2.46-git1.8.3-zip6.00"
      command = <<-EOT
        export TOOLS_DIR=$HOME/.local/bin
        export PATH=$TOOLS_DIR:$PATH
        cd $WORKSPACE/infra
        tflint --init
        tflint --force
        tflint --force --format=junit > tflint_results.xml
      EOT
    }
  }
}

# --- Terraform Validate Build Task ---
resource "huaweicloud_codearts_build_task" "validate" {
  name       = "terraform-validate"
  project_id = huaweicloud_codearts_project.cict_project.id
  arch       = var.build_task_arch
  flavor     = var.build_task_flavor

  scms {
    scm_type  = "codehub"
    url       = huaweicloud_codearts_repository.iac_repo.https_url
    branch    = var.branches[0]
    repo_id   = tostring(huaweicloud_codearts_repository.iac_repo.repository_id)
    repo_name = huaweicloud_codearts_repository.iac_repo.name
  }

  steps {
    enable    = true
    name      = "Install Terraform"
    module_id = "devcloud2018.codeci_action_20017.action"
    properties = {
      image   = "shell4.2.46-git1.8.3-zip6.00"
      command = <<-EOT
        export TOOLS_DIR=$HOME/.local/bin
        mkdir -p $TOOLS_DIR
        export PATH=$TOOLS_DIR:$PATH
        # Configure Terraform CLI to use Huawei Cloud provider mirror
        cat > $HOME/.terraformrc << 'TFRC'
        provider_installation {
          network_mirror {
            url    = "https://mirrors.huaweicloud.com/terraform/"
            include = ["huaweicloud/huaweicloud"]
          }
          direct {
            exclude = ["huaweicloud/huaweicloud"]
          }
        }
        TFRC
        curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${var.terraform_version}/terraform_${var.terraform_version}_linux_amd64.zip
        unzip -o /tmp/terraform.zip -d $TOOLS_DIR
        terraform version
      EOT
    }
  }

  steps {
    enable    = true
    name      = "Validate Terraform"
    module_id = "devcloud2018.codeci_action_20017.action"
    properties = {
      image   = "shell4.2.46-git1.8.3-zip6.00"
      command = <<-EOT
        export TOOLS_DIR=$HOME/.local/bin
        export PATH=$TOOLS_DIR:$PATH
        cd $WORKSPACE/infra
        terraform fmt -diff -recursive -write=false
        terraform init -backend=false
        terraform validate
        terraform validate -json > validate_result.json
      EOT
    }
  }
}

# --- Terratest Build Task ---
resource "huaweicloud_codearts_build_task" "terratest" {
  name       = "terratest-e2e"
  project_id = huaweicloud_codearts_project.cict_project.id
  arch       = var.build_task_arch
  flavor     = var.build_task_flavor

  scms {
    scm_type  = "codehub"
    url       = huaweicloud_codearts_repository.iac_repo.https_url
    branch    = var.branches[0]
    repo_id   = tostring(huaweicloud_codearts_repository.iac_repo.repository_id)
    repo_name = huaweicloud_codearts_repository.iac_repo.name
  }

  steps {
    enable    = true
    name      = "Install Tools"
    module_id = "devcloud2018.codeci_action_20017.action"
    properties = {
      image   = "shell4.2.46-git1.8.3-zip6.00"
      command = <<-EOT
        export TOOLS_DIR=$HOME/.local/bin
        mkdir -p $TOOLS_DIR
        export PATH=$TOOLS_DIR:$PATH
        # Configure Terraform CLI to use Huawei Cloud provider mirror
        cat > $HOME/.terraformrc << 'TFRC'
        provider_installation {
          network_mirror {
            url    = "https://mirrors.huaweicloud.com/terraform/"
            include = ["huaweicloud/huaweicloud"]
          }
          direct {
            exclude = ["huaweicloud/huaweicloud"]
          }
        }
        TFRC
        # Install Terraform
        curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${var.terraform_version}/terraform_${var.terraform_version}_linux_amd64.zip
        unzip -o /tmp/terraform.zip -d $TOOLS_DIR
        # Install Go from Google mirror
        curl -L -o /tmp/go.tar.gz https://dl.google.com/go/go1.21.5.linux-amd64.tar.gz
        tar -xzf /tmp/go.tar.gz -C $HOME/.local
        export PATH=$HOME/.local/go/bin:$PATH
        go version
      EOT
    }
  }

  steps {
    enable    = true
    name      = "Run Terratest"
    module_id = "devcloud2018.codeci_action_20017.action"
    properties = {
      image   = "shell4.2.46-git1.8.3-zip6.00"
      command = <<-EOT
        export TOOLS_DIR=$HOME/.local/bin
        export PATH=$TOOLS_DIR:$HOME/.local/go/bin:$PATH
        cd $WORKSPACE
        go test ./test/... -timeout 10m -v | tee test_output.log
      EOT
    }
  }
}

# --- Checkov Build Task ---
resource "huaweicloud_codearts_build_task" "checkov" {
  name       = "checkov-scan"
  project_id = huaweicloud_codearts_project.cict_project.id
  arch       = var.build_task_arch
  flavor     = var.build_task_flavor

  scms {
    scm_type  = "codehub"
    url       = huaweicloud_codearts_repository.iac_repo.https_url
    branch    = var.branches[0]
    repo_id   = tostring(huaweicloud_codearts_repository.iac_repo.repository_id)
    repo_name = huaweicloud_codearts_repository.iac_repo.name
  }

  steps {
    enable    = true
    name      = "Install Tools"
    module_id = "devcloud2018.codeci_action_20017.action"
    properties = {
      image   = "shell4.2.46-git1.8.3-zip6.00"
      command = <<-EOT
        export TOOLS_DIR=$HOME/.local/bin
        mkdir -p $TOOLS_DIR
        export PATH=$TOOLS_DIR:$PATH
        # Configure Terraform CLI to use Huawei Cloud provider mirror
        cat > $HOME/.terraformrc << 'TFRC'
        provider_installation {
          network_mirror {
            url    = "https://mirrors.huaweicloud.com/terraform/"
            include = ["huaweicloud/huaweicloud"]
          }
          direct {
            exclude = ["huaweicloud/huaweicloud"]
          }
        }
        TFRC
        # Install Terraform
        curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${var.terraform_version}/terraform_${var.terraform_version}_linux_amd64.zip
        unzip -o /tmp/terraform.zip -d $TOOLS_DIR
        # Install Checkov
        pip3 install --user --no-deps --timeout=300 -i https://mirrors.huaweicloud.com/repository/pypi/simple/ checkov && pip3 install --user --timeout=300 --only-binary :all: -i https://mirrors.huaweicloud.com/repository/pypi/simple/ boto3 termcolor tabulate jmespath dpath tqdm pyyaml requests jsonschema networkx junit-xml yarl aiohttp click packaging lark-parser detect-secrets cloudsplaining python-hcl2 bc-python-hcl2 argcomplete
        export PATH=$HOME/.local/bin:$PATH
        checkov --version
      EOT
    }
  }

  steps {
    enable    = true
    name      = "Run Checkov"
    module_id = "devcloud2018.codeci_action_20017.action"
    properties = {
      image   = "shell4.2.46-git1.8.3-zip6.00"
      command = <<-EOT
        export TOOLS_DIR=$HOME/.local/bin
        export PATH=$TOOLS_DIR:$PATH
        cd $WORKSPACE/infra
        terraform init -backend=false
        terraform plan -out tf.plan
        terraform show -json tf.plan > tf.json
        checkov -f tf.json --framework terraform_plan --output junitxml > checkov_results.xml
      EOT
    }
  }
}
