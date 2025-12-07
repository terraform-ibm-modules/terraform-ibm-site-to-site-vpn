########################################################################################################################
# Resource Group
########################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.4.3"
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
## Simple VPN Connection to Existing Gateway - Testing Only
########################################################################################################################

locals {
  connection_name = "${var.prefix}-test-connection"
  vpn_conn = {
    name                     = local.connection_name
    preshared_key            = var.preshared_key
    existing_ike_policy_id   = "${var.existing_vpn_gateway_region}/${var.existing_ike_policy_id}"
    existing_ipsec_policy_id = "${var.existing_vpn_gateway_region}/${var.existing_ipsec_policy_id}"
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

  # Create VPN Connection
  vpn_connections = [local.vpn_conn]

  # No routing - just testing the connection creation
  create_routes      = false
  create_route_table = false
}
