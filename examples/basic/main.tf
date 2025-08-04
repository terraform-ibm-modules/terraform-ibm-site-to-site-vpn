
########################################################################################################################
# Resource Group
########################################################################################################################
module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
## VPC
########################################################################################################################
resource "ibm_is_vpc" "vpc" {
  name                      = "${var.prefix}-vpc"
  resource_group            = module.resource_group.resource_group_id
  address_prefix_management = "auto"
  tags                      = var.tags
}

resource "ibm_is_subnet" "subnet_zone_1" {
  name                     = "${var.prefix}-subnet-1"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = module.resource_group.resource_group_id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
}

########################################################################################################################
## VPN
########################################################################################################################
locals {
  vpn_gateway_name = "${var.prefix}-vpn-gateway"
  vpn_gateway_id   = local.vpn_gateway_map[local.vpn_gateway_name].vpn_gateway_id

  vpn_gateway_map  = { for gw in module.site_to_site_vpn.vpn_gateways : gw.vpn_gateway_name => gw }
  ike_policy_map   = { for policy in module.site_to_site_vpn.ike_policies : policy.name => policy }
  ipsec_policy_map = { for policy in module.site_to_site_vpn.ipsec_policies : policy.name => policy }
}

locals {

  # VPN Gateway
  vpn_gw = [
    {
      name      = local.vpn_gateway_name
      subnet_id = ibm_is_subnet.subnet_zone_1.id
      mode      = "route"
      tags      = var.tags
    }
  ]
  # Policies
  ike_policies = [
    {
      name                     = "${var.prefix}-ike-policy"
      encryption_algorithm     = "aes256"
      authentication_algorithm = "sha256"
      dh_group                 = 14
    }
  ]

  ipsec_policies = [
    {
      name                     = "${var.prefix}-ipsec-policy"
      encryption_algorithm     = "aes256"
      authentication_algorithm = "sha256"
      pfs                      = "group_14"
    }
  ]

  # VPN Connection
  vpn_conn = [
    {
      vpn_gateway_connection_name = "${var.prefix}-vpn-conn"
      vpn_gateway_name            = local.vpn_gateway_name
      vpn_gateway_id              = local.vpn_gateway_id
      preshared_key               = var.preshared_key
      ike_policy_id               = local.ike_policy_map["${var.prefix}-ike-policy"].id
      ipsec_policy_id             = local.ipsec_policy_map["${var.prefix}-ipsec-policy"].id
      local = [{
        ike_identities = [
          {
            type  = "fqdn"
            value = "${var.prefix}.local.example"
          },
          {
            type  = "fqdn"
            value = "${var.prefix}-2.local.example"
          }
        ]
      }]

      peer = [{
        address = cidrhost(ibm_is_subnet.subnet_zone_1.ipv4_cidr_block, 4)
        ike_identity = [{
          type  = "fqdn"
          value = "${var.prefix}.peer.example"
        }]
      }]
    }
  ]

}

module "site_to_site_vpn" {
  source            = "../.."
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  ike_policies      = local.ike_policies
  ipsec_policies    = local.ipsec_policies
  vpn_gateways      = local.vpn_gw
  vpn_connections   = local.vpn_conn
}
