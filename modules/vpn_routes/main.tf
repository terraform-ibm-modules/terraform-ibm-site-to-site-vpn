resource "ibm_is_vpc_routing_table" "vpc_route_table" {
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

# Create Single route resource if bulk creation is disabled.
resource "ibm_is_vpc_routing_table_route" "single_route" {
  count         = var.enable_multiple_routes ? 0 : 1
  name          = var.route_name
  zone          = var.route_zone
  vpc           = var.vpc_id
  destination   = var.route_destination
  next_hop      = var.route_next_hop
  action        = var.route_action
  advertise     = var.is_route_advertise
  priority      = var.route_priority
  routing_table = ibm_is_vpc_routing_table.vpc_route_table.id
}

# Create Multiple routes if bulk creation is enabled.
resource "ibm_is_vpc_routing_table_route" "multiple_routes" {
  for_each      = var.enable_multiple_routes ? { for route in var.routes : route.name => route } : {}
  name          = each.key
  zone          = "${var.region}-${each.value.zone}"
  vpc           = var.vpc_id
  destination   = each.value.destination
  next_hop      = each.value.next_hop
  action        = each.value.action
  advertise     = lookup(each.value, "advertise", false)
  priority      = lookup(each.value, "priority", 2)
  routing_table = ibm_is_vpc_routing_table.vpc_route_table.id
}
