
########################################################################################################################
# Resource Group
########################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.3.0"
  existing_resource_group_name = var.resource_group
}

locals {
  address_prefix_cidr     = "172.16.10.0/24"
  zone                    = "${var.region}-1"
  vpc_name                = "${var.prefix}-vpc"
  subnet_name             = "${var.prefix}-subnet-1"
  vpc_address_prefix_name = "${var.prefix}-prefix-zone-1"
}

########################################################################################################################
# VPC
########################################################################################################################
resource "ibm_is_vpc" "vpc" {
  name           = local.vpc_name
  resource_group = module.resource_group.resource_group_id
  tags           = var.tags
}

resource "ibm_is_subnet" "subnet_zone_1" {
  name                     = local.subnet_name
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = module.resource_group.resource_group_id
  zone                     = local.zone
  total_ipv4_address_count = 256
}

resource "ibm_is_vpc_address_prefix" "prefix_zone_1" {
  name = local.vpc_address_prefix_name
  zone = local.zone
  vpc  = ibm_is_vpc.vpc.id
  cidr = local.address_prefix_cidr
}

########################################################################################################################
## Site to Site VPN
########################################################################################################################

locals {
  subnet_id           = ibm_is_subnet.subnet_zone_1.id
  authentication_algo = "sha256"
  encryption_algo     = "aes256"
  vpn_gw_name         = "${var.prefix}-vpn-gateway"
}

locals {

  valid_ip_address = module.vpn_gateway_with_multiple_connections.vpn_gateway_public_ip == "0.0.0.0" ? module.vpn_gateway_with_multiple_connections.vpn_gateway_public_ip_2 : module.vpn_gateway_with_multiple_connections.vpn_gateway_public_ip
  vpn_connection_1 = {
    name           = "${var.prefix}-vpn-conn-1"
    preshared_key  = var.preshared_key
    establish_mode = "peer_only"
    peer_config = [
      {
        address = var.remote_gateway_ip
        cidrs   = [var.remote_cidr]
        ike_identity = [
          {
            type  = "ipv4_address"
            value = var.remote_gateway_ip
          }
        ]
      }
    ]

    local_config = [
      {
        cidrs = [local.address_prefix_cidr]
        ike_identities = [
          {
            type  = "ipv4_address"
            value = local.valid_ip_address
          }
        ]
      }
    ]
  }

  vpn_connection_2 = {
    name              = "${var.prefix}-vpn-conn-2"
    preshared_key     = var.preshared_key
    is_admin_state_up = true
    peer_config = [
      {
        address = var.remote_gateway_ip_2
        cidrs   = [var.remote_cidr_2]
        ike_identity = [
          {
            type  = "ipv4_address"
            value = var.remote_gateway_ip_2
          }
        ]
      }
    ]

    local_config = [
      {
        cidrs = [local.address_prefix_cidr]
        ike_identities = [
          {
            type  = "ipv4_address"
            value = module.vpn_gateway_with_multiple_connections.vpn_gateway_public_ip
          }
        ]
      }
    ]
  }
}

module "vpn_gateway_with_multiple_connections" {
  source                = "../.."
  resource_group_id     = module.resource_group.resource_group_id
  create_vpn_gateway    = true
  tags                  = var.tags
  vpn_gateway_name      = local.vpn_gw_name
  vpn_gateway_subnet_id = local.subnet_id
  vpn_gateway_mode      = "policy" # Policy Based VPN

  # Policies

  create_vpn_policies = true
  # IKE
  ike_policy_name              = "${var.prefix}-ike-policy"
  ike_authentication_algorithm = local.authentication_algo
  ike_encryption_algorithm     = local.encryption_algo
  ike_dh_group                 = 14
  # IPSec
  ipsec_policy_name              = "${var.prefix}-ipsec-policy"
  ipsec_encryption_algorithm     = local.encryption_algo
  ipsec_authentication_algorithm = local.authentication_algo
  ipsec_pfs                      = "group_14"

  # VPN Connections

  vpn_connections = [local.vpn_connection_1, local.vpn_connection_2]

  # Skip creating routing table & routes for policy based VPN
  create_route_table = false
  create_routes      = false
}
