locals {
  # Convert the vpn inputs from list to a map
  vpn_gateway_map     = { for gateway in var.vpn_gateways : gateway.name => gateway }
  vpn_connections_map = { for conn in var.vpn_connections : conn.vpn_gateway_connection_name => conn }
  gateways_to_create  = var.use_existing_vpn_gateway ? {} : local.vpn_gateway_map
}

##############################################################################
# VPN Policies (IPSec and IKE)
##############################################################################

module "vpn_policies" {
  source            = "./modules/vpn_policies"
  resource_group_id = var.resource_group_id
  ike_policies      = var.ike_policies
  ipsec_policies    = var.ipsec_policies
}

##############################################################################
# VPN Gateway
##############################################################################

module "vpn_gateway" {
  source            = "./modules/gateway"
  for_each          = local.gateways_to_create
  resource_group_id = var.resource_group_id
  vpn_gateway_name  = each.key
  vpn_gateway_mode  = each.value.mode
  subnet_id         = each.value.subnet_id
  tags              = var.tags
}

##############################################################################
# Site to Site VPN Gateway Connection
##############################################################################

module "vpn_connections" {
  source                      = "./modules/gateway_connection"
  for_each                    = local.vpn_connections_map
  vpn_gateway_connection_name = each.key
  vpn_gateway_id              = var.use_existing_vpn_gateway ? each.value.vpn_gateway_id : module.vpn_gateway[each.value.vpn_gateway_name].vpn_gateway_id
  preshared_key               = each.value.preshared_key
  establish_mode              = each.value.establish_mode
  is_admin_state_up           = each.value.is_admin_state_up
  enable_distribute_traffic   = each.value.enable_distribute_traffic
  peer                        = each.value.peer
  local                       = each.value.local
  dpd_action                  = each.value.dpd_action
  dpd_check_interval          = each.value.dpd_check_interval
  dpd_max_timeout             = each.value.dpd_max_timeout

  ike_policy_id = var.use_existing_ike_policy ? each.value.ike_policy_id : (
    each.value.ike_policy_name != null ? module.vpn_policies.ike_policies[each.value.ike_policy_name].id : null
  )
  ipsec_policy_id = var.use_existing_ipsec_policy ? each.value.ipsec_policy_id : (
    each.value.ipsec_policy_name != null ? module.vpn_policies.ipsec_policies[each.value.ipsec_policy_name].id : null
  )
}

##############################################################################
# VPC Routing Table and VPN Routes
##############################################################################

module "vpn_routes" {
  depends_on = [module.vpn_gateway, module.vpn_connections]
  source     = "./modules/vpn_routing"
  count      = length(var.vpn_routes) > 0 ? 1 : 0

  vpc_id                  = var.vpn_routes[0].vpc_id # Use first route's VPC ID
  existing_route_table_id = var.existing_route_table_id
  create_route_table      = var.create_route_table
  routing_table_name      = var.routing_table_name != null ? var.routing_table_name : "vpn-routing-table"

  vpn_routes = [
    for route in var.vpn_routes : {
      name        = route.name
      zone        = route.zone
      destination = route.destination
      action      = route.action
      advertise   = route.advertise
      priority    = route.priority
      next_hop    = route.next_hop
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
