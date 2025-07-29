# VPN Routing Submodule for IBM Cloud Site-to-Site VPN

data "ibm_is_vpc_routing_table" "existing" {
  count         = var.existing_route_table_id != null ? 1 : 0
  vpc           = var.vpc_id
  routing_table = var.existing_route_table_id
}

resource "ibm_is_vpc_routing_table" "vpn_routing_table" {
  count                            = var.existing_route_table_id == null && var.create_route_table ? 1 : 0
  name                             = var.routing_table_name
  vpc                              = var.vpc_id
  access_tags                      = var.access_tags
  tags                             = var.tags
  advertise_routes_to              = var.advertise_routes_to
  accept_routes_from_resource_type = var.accept_routes_from_resource_type
  route_direct_link_ingress        = var.route_direct_link_ingress
  route_transit_gateway_ingress    = var.route_transit_gateway_ingress
  route_vpc_zone_ingress           = var.route_vpc_zone_ingress
  route_internet_ingress           = var.route_internet_ingress
}

locals {

  route_table_id = var.existing_route_table_id != null ? var.existing_route_table_id : (
    var.create_route_table ? ibm_is_vpc_routing_table.vpn_routing_table[0].id : null
  )
  # Combine existing and new routes
  all_routes = concat(var.existing_routes, var.vpn_routes)
}

resource "ibm_is_vpc_routing_table_route" "vpn_route" {
  count         = length(local.all_routes)
  vpc           = var.vpc_id
  routing_table = local.route_table_id
  name          = try(local.all_routes[count.index].name, "vpn-route-${count.index}")
  destination   = local.all_routes[count.index].destination
  next_hop      = local.all_routes[count.index].next_hop
  zone          = local.all_routes[count.index].zone
  action        = try(local.all_routes[count.index].action, "deliver")
  advertise     = try(local.all_routes[count.index].advertise, false)
  priority      = try(local.all_routes[count.index].priority, 2)
}
