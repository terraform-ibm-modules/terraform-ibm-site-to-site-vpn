
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

module "vpn_gateway" {
  source                         = "../.."
  resource_group_id              = module.resource_group.resource_group_id
  create_vpn_gateway             = true
  tags                           = var.tags
  vpn_gateway_name               = local.vpn_gw_name
  vpn_gateway_subnet_id          = local.subnet_id
  vpn_gateway_mode               = "route"
  create_vpn_policies            = true
  ike_policy_name                = "${var.prefix}-ike-policy"
  ike_authentication_algorithm   = local.authentication_algo
  ike_encryption_algorithm       = local.encryption_algo
  ike_dh_group                   = 14
  ipsec_policy_name              = "${var.prefix}-ipsec-policy"
  ipsec_encryption_algorithm     = local.encryption_algo
  ipsec_authentication_algorithm = local.authentication_algo
  ipsec_pfs                      = "group_14"
}

module "site_to_site_vpn" {
  source                   = "../.."
  depends_on               = [module.vpn_gateway]
  resource_group_id        = module.resource_group.resource_group_id
  create_vpn_gateway       = false
  existing_vpn_gateway_id  = module.vpn_gateway.vpn_gateway_id
  create_vpn_policies      = false
  existing_ike_policy_id   = module.vpn_gateway.ike_policy_id
  existing_ipsec_policy_id = module.vpn_gateway.ipsec_policy_id

  # Create Connection to Remote Peer
  create_connection = true
  connection_name   = "${var.prefix}-vpn-conn"
  preshared_key     = var.preshared_key

  # Peer Configuration (remote VPN gateway)
  peer_config = [
    {
      address = var.remote_gateway_ip
      ike_identity = [
        {
          type  = "ipv4_address"
          value = var.remote_gateway_ip
        }
      ]
    }
  ]
  # Local Configuration
  local_config = [
    {
      ike_identities = [
        {
          type  = "ipv4_address"
          value = module.vpn_gateway.vpn_gateway_public_ip
        },
        {
          type  = "ipv4_address"
          value = module.vpn_gateway.vpn_gateway_public_ip
        }
      ]
    }
  ]

  # Create routing table
  create_route_table               = true
  routing_table_name               = "${var.prefix}-vpn-rt"
  accept_routes_from_resource_type = ["vpn_gateway"]
  route_attach_subnet              = true
  route_subnet_id                  = local.subnet_id

  # Add routes
  create_routes = true
  vpc_id        = ibm_is_vpc.vpc.id
  routes = [
    {
      name             = "${var.prefix}-vpn-route"
      vpn_gateway_name = local.vpn_gw_name
      zone             = local.zone
      next_hop         = module.vpn_gateway.vpn_gateway_id
      destination      = var.remote_cidr
    }
  ]
}
