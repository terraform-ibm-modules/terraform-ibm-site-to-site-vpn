########################################################################################################################
# Resource Group
########################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.3.0"
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
## Simple VPN Connection to Existing Gateway - Testing Only
########################################################################################################################

module "vpn_connection_to_site_c" {
  source = "../../.."
  providers = {
    ibm = ibm.site_a
  }

  resource_group_id = module.resource_group.resource_group_id
  tags              = ["terraform", "test", "existing-gateway"]

  # Use existing VPN gateway instead of creating new one
  create_vpn_gateway      = false
  existing_vpn_gateway_id = var.existing_vpn_gateway_id
  vpn_gateway_name        = null
  vpn_gateway_subnet_id   = null

  # Create simple policies for testing
  create_vpn_policies            = true
  ike_policy_name                = "${var.prefix}-test-ike-policy"
  ike_authentication_algorithm   = "sha256"
  ike_encryption_algorithm       = "aes256"
  ike_dh_group                   = 14
  ipsec_policy_name              = "${var.prefix}-test-ipsec-policy"
  ipsec_encryption_algorithm     = "aes256"
  ipsec_authentication_algorithm = "sha256"
  ipsec_pfs                      = "group_14"

  # Create simple connection
  vpn_gateway_connection_name = "${var.prefix}-test-connection"
  preshared_key               = var.preshared_key

  # Simple peer configuration
  peer_config = [
    {
      address = var.remote_site_c_ip
      ike_identity = [
        {
          type  = "ipv4_address"
          value = var.remote_site_c_ip
        }
      ]
    }
  ]

  # Simple local configuration
  local_config = [
    {
      ike_identities = [
        {
          type  = "ipv4_address"
          value = var.local_gateway_ip
        },
        {
          type  = "ipv4_address"
          value = var.local_gateway_ip
        }
      ]
    }
  ]

  # No routing - just testing the connection creation
  create_routes      = false
  create_route_table = false
}
