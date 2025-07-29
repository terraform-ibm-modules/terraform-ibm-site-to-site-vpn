locals {
  # Convert the vpn inputs from list to a map
  vpn_gateway_map     = { for gateway in var.vpn_gateways : gateway.name => gateway }
  vpn_connections_map = { for conn in var.vpn_connections : conn.vpn_gateway_connection_name => conn }
  ike_policy_map      = { for ike_policy in var.ike_policies : ike_policy.name => ike_policy }
  ipsec_policy_map    = { for ipsec_policy in var.ipsec_policies : ipsec_policy.name => ipsec_policy }
  vpn_routes_map      = { for route in var.vpn_routes : route.name => route }
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
  for_each          = local.vpn_gateway_map
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
  depends_on                  = [module.vpn_policies, module.vpn_gateway]
  source                      = "./modules/gateway_connection"
  for_each                    = local.vpn_connections_map
  vpn_gateway_connection_name = each.key
  vpn_gateway_id              = var.use_existing_vpn_gateway ? each.value.vpn_gateway_id : module.vpn_gateway[each.value.vpn_gateway_name].vpn_gateway_id
  preshared_key               = each.value.preshared_key
  establish_mode              = each.value.establish_mode
  is_admin_state_up           = each.value.is_admin_state_up
  enable_distribute_traffic   = each.value.enable_distribute_traffic
  ike_policy_id               = each.value.ike_policy_id
  ipsec_policy_id             = each.value.ipsec_policy_id
  peer                        = each.value.peer
  local                       = each.value.local
  dpd_action                  = each.value.dpd_action
  dpd_check_interval          = each.value.dpd_check_interval
  dpd_max_timeout             = each.value.dpd_max_timeout
}

##############################################################################
# VPC Routing Table and VPN Routes
##############################################################################
module "vpn_routes" {
  source                  = "./modules/vpn_routing"
  for_each                = local.vpn_routes_map
  existing_route_table_id = var.existing_route_table_id
  create_route_table      = var.create_route_table
  vpc_id                  = each.value.vpc_id #var.vpc_id
  vpn_gateway_id          = try(module.vpn_gateway[each.value.vpn_gateway_name].vpn_gateway_id, null)
  vpn_routes = [{
    name        = each.key
    zone        = "${var.region}-${each.value.zone}"
    destination = each.value.destination
    next_hop    = try(each.value.next_hop, try(module.vpn_gateway[each.value.vpn_gateway_name].vpn_gateway_id, null))
    action      = each.value.action
    advertise   = lookup(each.value, "advertise", false)
    priority    = lookup(each.value, "priority", 2)
  }]

  # Routing table specific inputs
  routing_table_name               = var.routing_table_name
  accept_routes_from_resource_type = var.accept_routes_from_resource_type
  advertise_routes_to              = var.advertise_routes_to
  route_direct_link_ingress        = var.route_direct_link_ingress
  route_transit_gateway_ingress    = var.route_transit_gateway_ingress
  route_vpc_zone_ingress           = var.route_vpc_zone_ingress
  route_internet_ingress           = var.route_internet_ingress
}
