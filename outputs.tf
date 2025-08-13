########################################################################################################################
# Outputs
########################################################################################################################

output "ike_policy" {
  description = "Map of newly created IKE policy."
  value = var.create_vpn_policies ? {
    ike_policy_name  = var.ike_policy_name
    id               = module.vpn_policies[0].ike_policy_id
    vpn_connections  = module.vpn_policies[0].ike_vpn_connections
    negotiation_mode = module.vpn_policies[0].ike_negotiation_mode
  } : null
}

output "ipsec_policy" {
  description = "Map of newly created IPSec policy."
  value = var.create_vpn_policies ? {
    ipsec_policy_name  = var.ipsec_policy_name
    id                 = module.vpn_policies[0].ipsec_policy_id
    vpn_connections    = module.vpn_policies[0].ipsec_vpn_connections
    encapsulation_mode = module.vpn_policies[0].ipsec_encapsulation_mode
    transform_protocol = module.vpn_policies[0].ipsec_transform_protocol
  } : null
}

output "vpn_gateway_id" {
  description = "ID of the VPN gateway (created or used)."
  value       = local.vpn_gateway_id
}

output "vpn_gateway" {
  description = "VPN gateway information."
  value = var.create_vpn_gateway ? {
    id         = module.vpn_gateway[0].vpn_gateway_id
    name       = var.vpn_gateway_name
    crn        = module.vpn_gateway[0].vpn_gateway_crn
    primary_ip = module.vpn_gateway[0].vpn_gateway_primary_ip
    members    = module.vpn_gateway[0].vpn_gateway_members
    status     = module.vpn_gateway[0].vpn_gateway_status
    vpc_info   = module.vpn_gateway[0].vpn_gateway_vpc_info
    mode       = var.vpn_gateway_mode
  } : null
}

output "vpn_gateway_public_ip" {
  description = "Public IP address of the VPN gateway created."
  value       = try(module.vpn_gateway[0].vpn_gateway_primary_ip, null)
}

output "vpn_connection" {
  description = "VPN connection information."
  value = var.create_connection ? {
    id             = module.vpn_connection[0].vpn_gateway_connection_id
    name           = var.connection_name
    status         = module.vpn_connection[0].vpn_gateway_connection_status
    mode           = module.vpn_connection[0].vpn_gateway_connection_mode
    status_reasons = module.vpn_connection[0].vpn_status_reasons
  } : null
}

output "ike_policy_id" {
  description = "ID of the IKE policy (created, existing, or looked up)."
  value       = local.ike_policy_id
}

output "ipsec_policy_id" {
  description = "ID of the IPSec policy (created, existing, or looked up)."
  value       = local.ipsec_policy_id
}

output "vpn_routes" {
  description = "VPN routing information."
  value = var.create_routes ? {
    route_table_id = module.vpn_routes[0].route_table_id
    routes_count   = module.vpn_routes[0].routes_count
    created_routes = module.vpn_routes[0].created_routes
  } : null
}
