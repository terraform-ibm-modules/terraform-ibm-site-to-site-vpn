locals {
  route_table_id = var.existing_route_table_id != null ? var.existing_route_table_id : (
    var.create_route_table ? split("/", ibm_is_vpc_routing_table.vpn_routing_table[0].id)[1] : null
  )

  # Combine existing and new routes only if route mode is enabled
  all_routes = var.vpn_gateway_mode == "route" ? concat(var.existing_routes, var.vpn_routes) : []
}

########################################
# Route Table Creation
########################################
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

########################################
# Attach Subnets to Routing Table
########################################
resource "ibm_is_subnet_routing_table_attachment" "attach_subnet" {
  count         = var.route_attach_subnet ? 1 : 0
  routing_table = local.route_table_id
  subnet        = var.subnet_id_to_attach
}

########################################
# Create Routes
########################################
resource "ibm_is_vpc_routing_table_route" "vpn_route" {

  depends_on = [
    ibm_is_vpc_routing_table.vpn_routing_table,
    ibm_is_subnet_routing_table_attachment.attach_subnet
  ]

  for_each = {
    for _, route in local.all_routes : route.name => route
    if(var.existing_route_table_id != null || var.create_route_table) && var.vpn_gateway_mode == "route"
  }

  vpc           = var.vpc_id
  routing_table = local.route_table_id
  name          = each.value.name
  destination   = each.value.destination
  next_hop      = each.value.action == "deliver" ? each.value.next_hop : "0.0.0.0"
  zone          = each.value.zone
  action        = each.value.action
  advertise     = each.value.advertise
  priority      = each.value.priority
}
