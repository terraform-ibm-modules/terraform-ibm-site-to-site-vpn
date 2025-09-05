########################################################################################################################
# VPN Policies - IKE and IPSec
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

##############################################################################
# VPN Gateway
##############################################################################

output "vpn_gateway_id" {
  description = "ID of the VPN gateway."
  value       = var.create_vpn_gateway ? ibm_is_vpn_gateway.vpn_gateway[0].id : null
}

output "vpn_gateway_crn" {
  description = "CRN of the VPN gateway."
  value       = var.create_vpn_gateway ? ibm_is_vpn_gateway.vpn_gateway[0].crn : null
}

output "vpn_gateway_public_ip" {
  description = "Resolved public IP address from either `public_ip_address` or `public_ip_address2`. [Learn more](https://registry.terraform.io/providers/IBM-cloud/ibm/1.80.4/docs/resources/is_vpn_gateway#public_ip_address2-4)"
  value       = var.create_vpn_gateway ? (ibm_is_vpn_gateway.vpn_gateway[0].public_ip_address == "0.0.0.0" ? ibm_is_vpn_gateway.vpn_gateway[0].public_ip_address2 : ibm_is_vpn_gateway.vpn_gateway[0].public_ip_address) : null
}

output "vpn_gateway_members" {
  description = "List of VPN gateway members."
  value = var.create_vpn_gateway ? [
    for member in ibm_is_vpn_gateway.vpn_gateway[0].members : {
      address         = member.address
      private_address = member.private_address
      role            = member.role
    }
  ] : null
}

output "vpn_gateway_status" {
  description = "Overall health state of the VPN gateway. Refer [here](https://registry.terraform.io/providers/IBM-cloud/ibm/1.80.4/docs/resources/is_vpn_gateway#health_state-4) for more information."
  value       = var.create_vpn_gateway ? ibm_is_vpn_gateway.vpn_gateway[0].health_state : null
}

output "vpn_gateway_vpc_info" {
  description = "Information about the VPC associated with the VPN gateway."
  value       = var.create_vpn_gateway ? ibm_is_vpn_gateway.vpn_gateway[0].vpc : null
}


##############################################################################
# VPN Gateway Connection
##############################################################################

output "vpn_gateway_connection_name" {
  description = "Name of the VPN gateway connection."
  value       = var.vpn_gateway_connection_name
}

output "vpn_gateway_connection_id" {
  description = "Unique identifier of the VPN gateway connection."
  value       = ibm_is_vpn_gateway_connection.vpn_site_to_site_connection.gateway_connection
}

# This is part of attribute reference but giving errors now.
# output "vpn_gateway_connection_crn" {
#   description = "Cloud Resource Name (CRN) of the VPN gateway connection."
#   value       = ibm_is_vpn_gateway_connection.vpn_site_to_site_connection.crn
# }

output "vpn_gateway_connection_status" {
  description = "Current status of the VPN gateway connection, either 'up' or 'down'."
  value       = ibm_is_vpn_gateway_connection.vpn_site_to_site_connection.status
}

output "vpn_gateway_connection_mode" {
  description = "Mode of the VPN gateway connection: either 'policy' or 'route'."
  value       = ibm_is_vpn_gateway_connection.vpn_site_to_site_connection.mode
}

# output "vpn_tunnels" {
#   description = "List of VPN tunnel configurations in static route mode."
#   value = ibm_is_vpn_gateway_connection.vpn_site_to_site_connection.mode == "route" ? [
#     for tunnel in ibm_is_vpn_gateway_connection.vpn_site_to_site_connection.tunnels : {
#       address       = tunnel.address
#       resource_type = tunnel.resource_type
#     }
#   ] : null
# }

output "vpn_status_reasons" {
  description = "List of status reasons explaining the current connection state."
  value = length(try(ibm_is_vpn_gateway_connection.vpn_site_to_site_connection.status_reasons, [])) > 0 ? [
    for reason in ibm_is_vpn_gateway_connection.vpn_site_to_site_connection.status_reasons : {
      code      = try(reason.code, null)
      message   = try(reason.message, null)
      more_info = try(reason.more_info, null)
  }] : null
}

##############################################################################
# Routes
##############################################################################

output "vpn_routes" {
  description = "VPN routing information."
  value = var.create_routes ? {
    route_table_id = module.vpn_routes[0].route_table_id
    routes_count   = module.vpn_routes[0].routes_count
    created_routes = module.vpn_routes[0].created_routes
  } : null
}
