# VPN Routing Submodule for IBM Cloud Site-to-Site VPN

locals {
  route_table_id = var.existing_route_table_id != null ? var.existing_route_table_id : (
    var.create_route_table ? ibm_is_vpc_routing_table.vpn_routing_table[0].id : null
  )
  # Combine existing and new routes
  all_routes = concat(var.existing_routes, var.vpn_routes)
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

resource "ibm_is_vpc_routing_table_route" "vpn_route" {
  depends_on = [ibm_is_vpc_routing_table.vpn_routing_table]
  for_each = {
    for idx, route in local.all_routes :
    "${idx}-${route.name}" => route
    if var.existing_route_table_id != null || var.create_route_table
  }

  vpc           = var.vpc_id
  routing_table = var.existing_route_table_id != null ? var.existing_route_table_id : ibm_is_vpc_routing_table.vpn_routing_table[0].id
  name          = each.value.name
  destination   = each.value.destination
  next_hop      = each.value.next_hop
  zone          = each.value.zone
  action        = each.value.action
  advertise     = each.value.advertise
  priority      = each.value.priority
}
