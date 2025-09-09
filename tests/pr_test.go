// Tests in this file are run in the PR pipeline and the continuous testing pipeline

package test

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"

const vpcTovpcExampleDir = "examples/vpc-to-vpc"
const singleSiteExampleDir = "examples/single-site"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}
var sharedInfoSvc *cloudinfo.CloudInfoService

var validRegions = []string{
	"au-syd",
	"us-south",
	"us-east",
	"eu-de",
	"eu-gb",
	"jp-tok",
}

func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	// Read the YAML file content
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, exampleDir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  exampleDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
	})

	options.TerraformVars = map[string]interface{}{
		"region":         validRegions[rand.Intn(len(validRegions))],
		"prefix":         options.Prefix,
		"resource_group": resourceGroup,
		"tags":           options.Tags,
		"remote_cidr":    "10.100.10.0/24", // Same CIDR is used in the existing resource
		"preshared_key":  fmt.Sprintf("ps-key-%s", common.UniqueId(3)),
	}

	return options
}

// Provision Remote VPN Gateway
func setupRemoteVPNGateway(t *testing.T, region string, prefix string) *terraform.Options {
	realTerraformDir := "./resources"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))

	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix": prefix,
			"region": region,
		},
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	require.NoError(t, existErr, "Init and Apply of temp resources (VPC and VPN Gateway) failed")

	return existingTerraformOptions
}

// Cleanup the resources created for validation
func cleanupResources(t *testing.T, terraformOptions *terraform.Options, prefix string) {

	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, terraformOptions)
		terraform.WorkspaceDelete(t, terraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}

func TestRunSingleSiteExample(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]
	prefixExistingRes := fmt.Sprintf("ex-%s", strings.ToLower(random.UniqueId()))
	existingTerraformOptions := setupRemoteVPNGateway(t, region, prefixExistingRes)

	// Test Single Site using existing VPC and VPN Gateway details
	options := setupOptions(t, "site1", singleSiteExampleDir)
	options.TerraformVars["remote_gateway_ip"] = terraform.Output(t, existingTerraformOptions, "vpn_gateway_public_ip")
	options.TerraformVars["remote_cidr"] = terraform.Output(t, existingTerraformOptions, "remote_cidr")
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")

	cleanupResources(t, existingTerraformOptions, prefixExistingRes)
}

func TestRunVpcToVpcExample(t *testing.T) {
	t.Parallel()

	region_site_a := validRegions[rand.Intn(len(validRegions))]

	// Ensuring second region is always different from first region
	var region_site_b string
	for {
		region_site_b = validRegions[rand.Intn(len(validRegions))]
		if region_site_b != region_site_a {
			break
		}
	}

	options := setupOptions(t, "vpcs", vpcTovpcExampleDir)

	options.TerraformVars = map[string]interface{}{
		"region_site_a":  region_site_a,
		"region_site_b":  region_site_b,
		"preshared_key":  fmt.Sprintf("ps-key-%s", common.UniqueId(3)),
		"resource_group": resourceGroup,
		"prefix":         "s2s",
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
