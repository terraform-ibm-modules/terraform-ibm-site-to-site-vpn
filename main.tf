##############################################################################
# VPN Policies (IPSec and IKE)
##############################################################################

module "vpn_policies" {
  count                          = var.create_vpn_policies ? 1 : 0
  source                         = "./modules/vpn_policies"
  resource_group                 = var.resource_group_id
  ike_policy_name                = var.ike_policy_name
  ike_authentication_algorithm   = var.ike_authentication_algorithm
  ike_encryption_algorithm       = var.ike_encryption_algorithm
  ike_dh_group                   = var.ike_dh_group
  ike_version                    = var.ike_version
  ike_key_lifetime               = var.ike_key_lifetime
  ipsec_policy_name              = var.ipsec_policy_name
  ipsec_encryption_algorithm     = var.ipsec_encryption_algorithm
  ipsec_authentication_algorithm = var.ipsec_authentication_algorithm
  ipsec_pfs                      = var.ipsec_pfs
  ipsec_key_lifetime             = var.ipsec_key_lifetime
}

##############################################################################
# VPN Gateway
##############################################################################

module "vpn_gateway" {
  count             = var.create_vpn_gateway ? 1 : 0
  source            = "./modules/gateway"
  resource_group_id = var.resource_group_id
  vpn_gateway_name  = var.vpn_gateway_name
  vpn_gateway_mode  = var.vpn_gateway_mode
  subnet_id         = var.vpn_gateway_subnet_id
  tags              = var.tags
}

##############################################################################
# Site to Site VPN Gateway Connection
##############################################################################

locals {

  vpn_gateway_id = (
    var.create_vpn_gateway ? module.vpn_gateway[0].vpn_gateway_id :
    var.existing_vpn_gateway_id != null ? var.existing_vpn_gateway_id : null
  )

  ike_policy_id = (
    var.create_vpn_policies ? module.vpn_policies[0].ike_policy_id :
    var.existing_ike_policy_id != null ? var.existing_ike_policy_id : null
  )

  ipsec_policy_id = (
    var.create_vpn_policies ? module.vpn_policies[0].ipsec_policy_id :
    var.existing_ipsec_policy_id != null ? var.existing_ipsec_policy_id : null
  )
}

module "vpn_connection" {
  count      = var.create_connection ? 1 : 0
  depends_on = [module.vpn_gateway, module.vpn_policies]
  source     = "./modules/gateway_connection"

  vpn_gateway_connection_name = var.connection_name
  vpn_gateway_id              = local.vpn_gateway_id
  preshared_key               = var.preshared_key
  establish_mode              = var.establish_mode
  is_admin_state_up           = var.is_admin_state_up
  enable_distribute_traffic   = var.enable_distribute_traffic
  peer                        = var.peer_config
  local                       = var.local_config

  # DPD settings
  dpd_action         = var.dpd_action
  dpd_check_interval = var.dpd_check_interval
  dpd_max_timeout    = var.dpd_max_timeout

  # Policy IDs
  ike_policy_id   = local.ike_policy_id
  ipsec_policy_id = local.ipsec_policy_id
}

##############################################################################
# VPC Routing Table and VPN Routes
##############################################################################

module "vpn_routes" {
  count                   = var.create_routes ? 1 : 0
  depends_on              = [module.vpn_connection]
  source                  = "./modules/vpn_routing"
  vpc_id                  = var.vpc_id
  existing_route_table_id = var.existing_route_table_id
  create_route_table      = var.create_route_table
  routing_table_name      = var.routing_table_name
  attach_subnet           = var.attach_subnet
  subnet_id_to_attach     = var.subnet_id
  vpn_routes = [
    for route in var.routes : {
      name        = route.name
      zone        = route.zone
      destination = route.destination
      action      = route.action
      advertise   = route.advertise
      priority    = route.priority
      next_hop    = local.vpn_gateway_id
    }
  ]
  existing_routes = []

  # Routing table configuration
  accept_routes_from_resource_type = var.accept_routes_from_resource_type
  advertise_routes_to              = var.advertise_routes_to
  route_direct_link_ingress        = var.route_direct_link_ingress
  route_transit_gateway_ingress    = var.route_transit_gateway_ingress
  route_vpc_zone_ingress           = var.route_vpc_zone_ingress
  route_internet_ingress           = var.route_internet_ingress
  tags                             = var.tags
}
