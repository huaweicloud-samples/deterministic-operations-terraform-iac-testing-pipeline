#!/bin/bash
# ============================================================
# Deployment helper script for CI/CT Terraform IaC Testing Pipeline
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${SCRIPT_DIR}/../infra"

usage() {
    echo "Usage: $0 [init|plan|apply|destroy|output]"
    echo "  init    - Initialize Terraform"
    echo "  plan    - Show Terraform execution plan"
    echo "  apply   - Apply Terraform configuration"
    echo "  destroy - Destroy all created resources"
    echo "  output  - Show Terraform outputs"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

cd "${INFRA_DIR}"

case "$1" in
    init)
        terraform init
        ;;
    plan)
        terraform init
        terraform plan
        ;;
    apply)
        terraform init
        terraform plan -out tfplan
        terraform apply tfplan
        ;;
    destroy)
        terraform init
        terraform destroy -auto-approve
        ;;
    output)
        terraform output
        ;;
    *)
        usage
        ;;
esac
