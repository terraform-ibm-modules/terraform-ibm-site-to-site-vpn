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
  description = "The IP address assigned to the VPN gateway. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpn_gateway#public_ip_address-1)"
  value       = var.create_vpn_gateway ? ibm_is_vpn_gateway.vpn_gateway[0].public_ip_address : null
}

output "vpn_gateway_public_ip_2" {
  description = "The Second Public IP address assigned to the VPN gateway member. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpn_gateway#private_ip_address2-1)"
  value       = var.create_vpn_gateway ? ibm_is_vpn_gateway.vpn_gateway[0].public_ip_address2 : null
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

output "vpn_gateway_connection_ids" {
  description = "Map of VPN gateway connection IDs, keyed by connection name."
  value       = { for k, v in ibm_is_vpn_gateway_connection.vpn_site_to_site_connection : k => v.gateway_connection }
}

# CRNs of all VPN Connections
# This is part of attribute reference but giving errors now.
# output "vpn_gateway_connection_crns" {
#   description = "Map of VPN gateway connection CRNs, keyed by connection name."
#   value       = { for k, v in ibm_is_vpn_gateway_connection.vpn_site_to_site_connection : k => v.crn }
# }

output "vpn_gateway_connection_statuses" {
  description = "Map of current statuses for each VPN gateway connection, either 'up' or 'down'."
  value       = { for k, v in ibm_is_vpn_gateway_connection.vpn_site_to_site_connection : k => v.status }
}

output "vpn_gateway_connection_modes" {
  description = "Map of VPN gateway connection modes: either 'policy' or 'route'."
  value       = { for k, v in ibm_is_vpn_gateway_connection.vpn_site_to_site_connection : k => v.mode }
}

output "vpn_status_reasons" {
  description = "Map of status reasons explaining the current connection state per connection."
  value = {
    for k, v in ibm_is_vpn_gateway_connection.vpn_site_to_site_connection :
    k => length(try(v.status_reasons, [])) > 0 ? [
      for reason in v.status_reasons : {
        code      = try(reason.code, null)
        message   = try(reason.message, null)
        more_info = try(reason.more_info, null)
      }
    ] : null
  }
}

# # Tunnels for route-based connections
# output "vpn_tunnels" {
#   description = "Map of VPN tunnel configurations (only for route mode connections)."
#   value = {
#     for k, v in ibm_is_vpn_gateway_connection.vpn_site_to_site_connection :
#     k => v.mode == "route" ? [
#       for tunnel in try(v.tunnels, []) : {
#         address       = tunnel.address
#         resource_type = tunnel.resource_type
#       }
#     ] : null
#   }
# }

##############################################################################
# Routes
##############################################################################

output "vpn_routes" {
  description = "VPN Routing information."
  value = var.create_routes ? {
    route_table_id = module.vpn_routes[0].route_table_id
    routes_count   = module.vpn_routes[0].routes_count
    created_routes = module.vpn_routes[0].created_routes
  } : null
}

##############################################################################
