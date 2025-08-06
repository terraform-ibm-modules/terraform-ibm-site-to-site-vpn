#####################################################################################
# Routing Table
#####################################################################################

output "route_table_id" {
  description = "ID of the route table (existing or newly created)."
  value       = local.route_table_id
}

#####################################################################################
# Routes
#####################################################################################

output "created_routes" {
  description = "List of created VPN routes."
  value = [
    for route in ibm_is_vpc_routing_table_route.vpn_route : {
      id          = route.id
      name        = route.name
      destination = route.destination
      next_hop    = route.next_hop
      zone        = route.zone
      action      = route.action
      advertise   = route.advertise
      priority    = route.priority
    }
  ]
}

output "routes_count" {
  description = "Number of routes created in the routing table."
  value       = length(ibm_is_vpc_routing_table_route.vpn_route)
}
