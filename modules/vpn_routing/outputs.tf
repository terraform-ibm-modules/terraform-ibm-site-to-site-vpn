#####################################################################################
# Routing Table
#####################################################################################

output "route_table_id" {
  description = "ID of the route table being used (existing or newly created)"
  value       = local.route_table_id
}

output "route_table_name" {
  description = "Name of the route table being used"
  value = var.existing_route_table_id != null ? data.ibm_is_vpc_routing_table.existing[0].name : (
    var.create_route_table ? ibm_is_vpc_routing_table.vpn_routing_table[0].name : null
  )
}

#####################################################################################
# Routes
#####################################################################################

output "created_routes" {
  description = "List of created VPN routes"
  value = [
    for route in ibm_is_vpc_routing_table_route.vpn_route : {
      id          = route.route
      destination = route.destination
      next_hop    = route.next_hop
      zone        = route.zone
      name        = route.name
    }
  ]
}