#####################################################################################
# Routing Table
#####################################################################################

output "routing_table_id" {
  description = "The unique identifier for the routing table in format <vpc_id>/<routing_table_id>."
  value       = ibm_is_vpc_routing_table.vpc_route_table.id
}
output "routing_table_name" {
  description = "Name of the routing table."
  value       = ibm_is_vpc_routing_table.vpc_route_table.name
}

output "routing_table_crn" {
  description = "Cloud Resource Name (CRN) of the routing table."
  value       = ibm_is_vpc_routing_table.vpc_route_table.crn
}

#####################################################################################
# Routes
#####################################################################################

output "single_route_id" {
  description = "ID of the route in format <table_id>/<route_id>."
  value       = ibm_is_vpc_routing_table_route.single_route[0].id
}

output "single_route_name" {
  description = "Name of the route created."
  value       = ibm_is_vpc_routing_table_route.single_route[0].name
}

output "multiple_route_ids" {
  value       = var.enable_multiple_routes ? { for route_name, route in ibm_is_vpc_routing_table_route.multiple_routes : route_name => route.id } : {}
  description = "Map of route names to their IDs."
}