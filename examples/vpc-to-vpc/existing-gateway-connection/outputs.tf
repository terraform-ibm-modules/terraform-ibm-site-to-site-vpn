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

output "test_results" {
  description = "Test results showing which outputs are null vs populated"
  value = {
    message             = "Testing connection to existing VPN gateway"
    existing_gateway_id = var.existing_vpn_gateway_id

    # These should be null (proving the fix works)
    null_outputs = {
      vpn_gateway_id        = module.vpn_connection_to_site_c.vpn_gateway_id
      vpn_gateway_public_ip = module.vpn_connection_to_site_c.vpn_gateway_public_ip
      vpn_gateway_crn       = module.vpn_connection_to_site_c.vpn_gateway_crn
      vpn_gateway_status    = module.vpn_connection_to_site_c.vpn_gateway_status
    }

    # These should have values (showing the connection works)
    working_outputs = {
      connection_id     = module.vpn_connection_to_site_c.vpn_gateway_connection_id
      connection_status = module.vpn_connection_to_site_c.vpn_gateway_connection_status
      ike_policy_id     = module.vpn_connection_to_site_c.ike_policy
      ipsec_policy_id   = module.vpn_connection_to_site_c.ipsec_policy
    }
  }
}
