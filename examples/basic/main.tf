
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
## Site to Site VPN
########################################################################################################################
module "site_to_site_vpn" {
  source            = "../.."
  resource_group_id = module.resource_group.resource_group_id
  tags              = var.tags

  # Create VPN Gateway
  create_vpn_gateway    = true
  vpn_gateway_name      = "${var.prefix}-vpn-gateway"
  vpn_gateway_subnet_id = ibm_is_subnet.subnet_zone_1.id
  vpn_gateway_mode      = "route"

  # Create Policies
  create_vpn_policies            = true
  ike_policy_name                = "${var.prefix}-ike-policy"
  ike_authentication_algorithm   = "sha256"
  ike_encryption_algorithm       = "aes256"
  ike_dh_group                   = 14
  ipsec_policy_name              = "${var.prefix}-ipsec-policy"
  ipsec_encryption_algorithm     = "aes256"
  ipsec_authentication_algorithm = "sha256"
  ipsec_pfs                      = "group_14"

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
          type  = "fqdn"
          value = "${var.prefix}.local.example.com"
        },
        {
          type  = "fqdn"
          value = "${var.prefix}.local.example.com"
        }
      ]
    }
  ]

  # Routes to remote networks
  create_routes = true
  vpc_id        = ibm_is_vpc.vpc.id
  routes = [
    {
      name        = "${var.prefix}-vpn-route"
      zone        = "${var.region}-1"
      destination = var.remote_cidr
      action      = "delegate"
      advertise   = false
      priority    = 2
    }
  ]

  # Create routing table
  create_route_table               = true
  routing_table_name               = "${var.prefix}-vpn-rt"
  accept_routes_from_resource_type = ["vpn_gateway"]
  route_vpc_zone_ingress           = true
}