package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
)

func TestRunMultipleVpnConnectionsExample(t *testing.T) {
	t.Parallel()

	// Provision Resources to be used by this example
	var region = validRegions[common.CryptoIntn(len(validRegions))]
	prefixExistingRes := fmt.Sprintf("ex-%s", strings.ToLower(random.UniqueId()))
	existingTerraformOptions := setupRemoteVPNGateway(t, region, prefixExistingRes, true)

	// Test Multiple connections using existing VPC and VPN Gateway details
	options := setupOptions(t, "mconn", multipleConnExampleDir)
	options.TerraformVars["remote_gateway_ip"] = terraform.Output(t, existingTerraformOptions, "vpn_gateway_public_ip")
	options.TerraformVars["remote_cidr"] = terraform.Output(t, existingTerraformOptions, "remote_cidr")
	options.TerraformVars["remote_gateway_ip_2"] = terraform.Output(t, existingTerraformOptions, "vpn_gateway_public_ip_2")
	options.TerraformVars["remote_cidr_2"] = terraform.Output(t, existingTerraformOptions, "remote_cidr")

	// Run consistency checks
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")

	// Cleanup the resources provisioned to run this example.
	cleanupResources(t, existingTerraformOptions, prefixExistingRes)
}
