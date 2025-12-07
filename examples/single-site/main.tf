
########################################################################################################################
# Resource Group
########################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.4.3"
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
  connection_name     = "${var.prefix}-vpn-conn"
  subnet_id           = ibm_is_subnet.subnet_zone_1.id
  authentication_algo = "sha256"
  encryption_algo     = "aes256"
  vpn_gw_name         = "${var.prefix}-vpn-gateway"

  valid_ip_address = module.vpn_gateway_single_site.vpn_gateway_public_ip == "0.0.0.0" ? module.vpn_gateway_single_site.vpn_gateway_public_ip_2 : module.vpn_gateway_single_site.vpn_gateway_public_ip

  # IKE Policy configuration
  ike_policy_config = {
    name                     = "${var.prefix}-ike-policy"
    authentication_algorithm = local.authentication_algo
    encryption_algorithm     = local.encryption_algo
    dh_group                 = 14
  }

  # IPSec Policy configuration
  ipsec_policy_config = {
    name                     = "${var.prefix}-ipsec-policy"
    encryption_algorithm     = local.encryption_algo
    authentication_algorithm = local.authentication_algo
    pfs                      = "group_14"
  }

  # VPN Connection
  vpn_conn = {
    name          = local.connection_name
    preshared_key = var.preshared_key
    # Policies
    create_ike_policy   = true
    create_ipsec_policy = true
    ike_policy_config   = local.ike_policy_config
    ipsec_policy_config = local.ipsec_policy_config
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
}

module "vpn_gateway_single_site" {
  source            = "../.."
  resource_group_id = module.resource_group.resource_group_id
  tags              = var.tags

  # VPN Gateway
  create_vpn_gateway    = true
  vpn_gateway_name      = local.vpn_gw_name
  vpn_gateway_subnet_id = local.subnet_id
  vpn_gateway_mode      = "policy" # Policy Based VPN

  # Create VPN Connection
  vpn_connections = [local.vpn_conn]

  # Skip routing table & routes for policy VPN
  create_route_table = false
  create_routes      = false
}
