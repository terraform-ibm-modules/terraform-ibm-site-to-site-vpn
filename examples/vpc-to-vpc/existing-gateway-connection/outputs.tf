########################################################################################################################
# Simplified Outputs for Testing Existing Gateway Connection
########################################################################################################################

output "vpn_gateway_id" {
  description = "VPN Gateway ID (should be null since using existing gateway)"
  value       = module.vpn_connection_to_site_c.vpn_gateway_id
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP (should be null since using existing gateway)"
  value       = module.vpn_connection_to_site_c.vpn_gateway_public_ip
}

output "vpn_gateway_connection_id" {
  description = "VPN connection ID for the new test connection"
  value       = module.vpn_connection_to_site_c.vpn_gateway_connection_id
}

output "vpn_connection_status" {
  description = "VPN connection status for the new test connection"
  value       = module.vpn_connection_to_site_c.vpn_gateway_connection_status
}
