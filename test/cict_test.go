package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestPipelineCreation(t *testing.T) {
	uniqueId := strings.ToLower(random.UniqueId())
	expectedTags := map[string]string{
		"Application":    fmt.Sprintf("terratest-example-%s", random.UniqueId()),
		"Environment":    "Terratest",
		"DeploymentType": "Terratest",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../infra",
		Vars: map[string]interface{}{
			"custom_tags":            expectedTags,
			"codearts_project_name":  fmt.Sprintf("test-pipeline-%s", uniqueId),
			"repository_name":        fmt.Sprintf("test-repo-%s", uniqueId),
		},
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	actualTags := terraform.OutputMap(t, terraformOptions, "custom_tags")
	assert.Equal(t, expectedTags, actualTags)
}

func TestDefaultTags(t *testing.T) {
	uniqueId := strings.ToLower(random.UniqueId())
	expectedTags := map[string]string{
		"Application":    fmt.Sprintf("terratest-example-%s", random.UniqueId()),
		"Environment":    "Terratest",
		"DeploymentType": "Terratest",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../infra",
		Vars: map[string]interface{}{
			"custom_tags":            expectedTags,
			"codearts_project_name":  fmt.Sprintf("test-tags-%s", uniqueId),
			"repository_name":        fmt.Sprintf("test-tags-repo-%s", uniqueId),
		},
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	actualTags := terraform.OutputMap(t, terraformOptions, "custom_tags")
	assert.Equal(t, expectedTags, actualTags)
	assert.Contains(t, actualTags, "Application", "Application tag was found in the output")
}
