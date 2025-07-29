##############################################################################
# Outputs
##############################################################################

output "vpn_gateway_connection_id" {
  description = "Unique identifier of the VPN gateway connection."
  value       = ibm_is_vpn_gateway_connection.vpn_gw_conn.id
}

# This is part of attribute reference but giving errors now.
# output "vpn_gateway_connection_crn" {
#   description = "Cloud Resource Name (CRN) of the VPN gateway connection."
#   value       = ibm_is_vpn_gateway_connection.vpn_gw_conn.crn
# }

output "vpn_gateway_connection_status" {
  description = "Current status of the VPN gateway connection, either 'up' or 'down'."
  value       = ibm_is_vpn_gateway_connection.vpn_gw_conn.status
}

output "vpn_gateway_connection_mode" {
  description = "Mode of the VPN gateway connection: either 'policy' or 'route'."
  value       = ibm_is_vpn_gateway_connection.vpn_gw_conn.mode
}

# output "vpn_tunnels" {
#   description = "List of VPN tunnel configurations in static route mode."
#   value = ibm_is_vpn_gateway_connection.vpn_gw_conn.mode == "route" ? [
#     for tunnel in ibm_is_vpn_gateway_connection.vpn_gw_conn.tunnels : {
#       address       = tunnel.address
#       resource_type = tunnel.resource_type
#     }
#   ] : null
# }

output "vpn_status_reasons" {
  description = "List of status reasons explaining the current connection state."
  value = [
    for reason in ibm_is_vpn_gateway_connection.vpn_gw_conn.status_reasons : {
      code      = reason.code
      message   = reason.message
      more_info = reason.more_info
    }
  ]
}
