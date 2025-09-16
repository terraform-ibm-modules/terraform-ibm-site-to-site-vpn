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

locals {
  connection_name = "${var.prefix}-test-connection"
  vpn_conn = {
    name          = local.connection_name
    preshared_key = var.preshared_key
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

    local_config = [
      {
        ike_identities = [
          {
            type  = "ipv4_address"
            value = var.local_gateway_ip
          },
          {
            type  = "ipv4_address"
            value = var.local_gateway_secondary_ip
          }
        ]
      }
    ]
  }
}

module "vpn_connection_to_site_c" {
  source = "../../.."

  resource_group_id = module.resource_group.resource_group_id

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

  # Create VPN Connection
  vpn_connections = [local.vpn_conn]

  # No routing - just testing the connection creation
  create_routes      = false
  create_route_table = false
}
