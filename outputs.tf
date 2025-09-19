########################################################################################################################
# VPN Policies - IKE and IPSec
########################################################################################################################

output "vpn_connection_policies" {
  description = "IKE and IPSec policy details."
  value = {
    for conn in var.vpn_connections : conn.name => {
      ike_policy = {
        id               = conn.existing_ike_policy_id != null ? conn.existing_ike_policy_id : module.vpn_policies[0].ike_policy_ids[conn.name]
        vpn_connections  = try(module.vpn_policies[0].ike_vpn_connections[conn.name], null)
        negotiation_mode = try(module.vpn_policies[0].ike_negotiation_mode[conn.name], null)
      }
      ipsec_policy = {
        id                 = conn.existing_ipsec_policy_id != null ? conn.existing_ipsec_policy_id : module.vpn_policies[0].ipsec_policy_ids[conn.name]
        vpn_connections    = try(module.vpn_policies[0].ipsec_vpn_connections[conn.name], null)
        encapsulation_mode = try(module.vpn_policies[0].ipsec_encapsulation_mode[conn.name], null)
        transform_protocol = try(module.vpn_policies[0].ipsec_transform_protocol[conn.name], null)
    } }
  }
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
