##############################################################################
# Site-to-Site VPN Configuration
##############################################################################

locals {

  # Policies
  ike_policy_name   = "${var.prefix}-ike-policy"
  ipsec_policy_name = "${var.prefix}-ipsec-policy"

  # VPN Gateways
  vpn_gateway_site_a_name = "${var.prefix}-vpn-gw-site-a"
  vpn_gateway_site_b_name = "${var.prefix}-vpn-gw-site-b"

  # VPN Connections
  vpn_connection_name_site_a = "${var.prefix}-vpn-conn-a-to-b"
  vpn_connection_name_site_b = "${var.prefix}-vpn-conn-b-to-a"

  # Routes
  vpn_route_site_a_to_site_b = "${var.prefix}-route-a-to-b"
  vpn_route_site_b_to_site_a = "${var.prefix}-route-b-to-a"

  # Routing Table
  route_table_site_a_to_site_b = "${var.prefix}-a-to-b-rt"
  route_table_site_b_to_site_a = "${var.prefix}-b-to-a-rt"
}

locals {

  # If one of the public IP addresses is "0.0.0.0", you can use a conditional expression to get the valid IP address.
  valid_ip_1_site_a = module.vpn_gateway_site_a.vpn_gateway_public_ip == "0.0.0.0" ? module.vpn_gateway_site_a.vpn_gateway_public_ip_2 : module.vpn_gateway_site_a.vpn_gateway_public_ip
  valid_ip_2_site_a = module.vpn_gateway_site_a.vpn_gateway_public_ip_2 == "0.0.0.0" ? module.vpn_gateway_site_a.vpn_gateway_public_ip : module.vpn_gateway_site_a.vpn_gateway_public_ip_2

  valid_ip_1_site_b = module.vpn_gateway_site_b.vpn_gateway_public_ip == "0.0.0.0" ? module.vpn_gateway_site_b.vpn_gateway_public_ip_2 : module.vpn_gateway_site_b.vpn_gateway_public_ip
  valid_ip_2_site_b = module.vpn_gateway_site_b.vpn_gateway_public_ip_2 == "0.0.0.0" ? module.vpn_gateway_site_b.vpn_gateway_public_ip : module.vpn_gateway_site_b.vpn_gateway_public_ip_2

  # Peer IPs - For Site A it is Site B's Public IP and vice versa.
  # Site B Public IP
  peer_ip_for_site_a = local.valid_ip_1_site_b == "0.0.0.0" ? local.valid_ip_2_site_b : local.valid_ip_1_site_b
  # Site A Public IP
  peer_ip_for_site_b = local.valid_ip_1_site_a == "0.0.0.0" ? local.valid_ip_2_site_a : local.valid_ip_1_site_a

  # VPN Connections
  vpn_conn_a_to_b = {
    name          = local.vpn_connection_name_site_a
    preshared_key = var.preshared_key

    peer_config = [
      {
        address = local.peer_ip_for_site_a
        ike_identity = [
          {
            type  = "ipv4_address"
            value = local.peer_ip_for_site_a
          }
        ]
      }
    ]

    local_config = [
      {
        ike_identities = [
          {
            type  = "ipv4_address"
            value = local.valid_ip_1_site_a
          },
          {
            type  = "ipv4_address"
            value = local.valid_ip_2_site_a
          }
        ]
      }
    ]
  }

  vpn_conn_b_to_a = {
    name          = local.vpn_connection_name_site_b
    preshared_key = var.preshared_key

    peer_config = [
      {
        address = local.peer_ip_for_site_b
        ike_identity = [
          {
            type  = "ipv4_address"
            value = local.peer_ip_for_site_b
          }
        ]
      }
    ]

    local_config = [
      {
        ike_identities = [
          {
            type  = "ipv4_address"
            value = local.valid_ip_1_site_b
          },
          {
            type  = "ipv4_address"
            value = local.valid_ip_2_site_b
          }
        ]
      }
    ]
  }
}

##############################################################################
# Site A (VPC in region 1)
##############################################################################

module "vpn_gateway_site_a" {
  source = "../.."
  providers = {
    ibm = ibm.site_a
  }

  resource_group_id     = module.resource_group.resource_group_id
  tags                  = var.resource_tags
  create_vpn_gateway    = true
  vpn_gateway_name      = local.vpn_gateway_site_a_name
  vpn_gateway_subnet_id = ibm_is_subnet.subnet_site_a.id
  vpn_gateway_mode      = "route"

  # policies

  create_vpn_policies            = true
  ike_policy_name                = local.ike_policy_name
  ike_authentication_algorithm   = "sha256"
  ike_encryption_algorithm       = "aes256"
  ike_dh_group                   = 14
  ipsec_policy_name              = local.ipsec_policy_name
  ipsec_encryption_algorithm     = "aes256"
  ipsec_authentication_algorithm = "sha256"
  ipsec_pfs                      = "group_14"

  # Create vpn gateway connection from A to B
  vpn_connections = [local.vpn_conn_a_to_b]

  # Create Routes to Site B networks
  create_routes = true
  vpc_id        = local.vpc_id_site_a
  routes = [
    {
      name                = local.vpn_route_site_a_to_site_b
      zone                = "${var.region_site_a}-1"
      destination         = local.cidr_block_site_b
      action              = "deliver"
      next_hop            = null # This will be resolved using connection name
      vpn_gateway_name    = local.vpn_gateway_site_a_name
      vpn_connection_name = local.vpn_connection_name_site_a
    }
  ]

  create_route_table               = true
  accept_routes_from_resource_type = ["vpn_gateway"]
  routing_table_name               = local.route_table_site_a_to_site_b
  route_attach_subnet              = true
  route_subnet_id                  = ibm_is_subnet.subnet_site_a.id
}

##############################################################################
# Site B (VPC in region 2)
##############################################################################
module "vpn_gateway_site_b" {
  source = "../.."
  providers = {
    ibm = ibm.site_b
  }

  resource_group_id     = module.resource_group.resource_group_id
  tags                  = var.resource_tags
  create_vpn_gateway    = true
  vpn_gateway_name      = local.vpn_gateway_site_b_name
  vpn_gateway_subnet_id = ibm_is_subnet.subnet_site_b.id
  vpn_gateway_mode      = "route"

  # Policies

  create_vpn_policies            = true
  ike_policy_name                = local.ike_policy_name
  ike_authentication_algorithm   = "sha256"
  ike_encryption_algorithm       = "aes256"
  ike_dh_group                   = 14
  ipsec_policy_name              = local.ipsec_policy_name
  ipsec_encryption_algorithm     = "aes256"
  ipsec_authentication_algorithm = "sha256"
  ipsec_pfs                      = "group_14"

  # Create vpn gateway connection from B to A
  vpn_connections = [local.vpn_conn_b_to_a]

  # Routes to Site A networks
  create_routes = true
  vpc_id        = local.vpc_id_site_b
  routes = [
    {
      name                = local.vpn_route_site_b_to_site_a
      zone                = "${var.region_site_b}-1"
      destination         = local.cidr_block_site_a
      action              = "deliver"
      next_hop            = null # This will be resolved using connection name
      vpn_gateway_name    = local.vpn_gateway_site_b_name
      vpn_connection_name = local.vpn_connection_name_site_b
    }
  ]

  create_route_table               = true
  accept_routes_from_resource_type = ["vpn_gateway"]
  routing_table_name               = local.route_table_site_b_to_site_a
  route_attach_subnet              = true
  route_subnet_id                  = ibm_is_subnet.subnet_site_b.id
}

##############################################################################
