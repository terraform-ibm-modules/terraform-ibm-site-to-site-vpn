########################################################################################################################
# Outputs
########################################################################################################################

output "gateway_id" {
  description = "ID of the created VPN gateway"
  value       = module.vpn_gateway.vpn_gateway_id
}

output "gateway_public_ip" {
  description = "Public IP of the VPN gateway"
  value       = module.vpn_gateway.vpn_gateway_primary_ip
}

output "gateway_crn" {
  description = "CRN of the site to site VPN gateway"
  value       = module.vpn_gateway.vpn_gateway_crn
}

output "connection_id" {
  description = "ID of the VPN connection."
  value       = module.vpn_connections.vpn_gateway_connection_id
}

output "connection_crn" {
  description = "Cloud Resource Name (CRN) of the VPN gateway connection."
  value       = module.vpn_connections.vpn_gateway_connection_crn
}

output "connection_status" {
  description = "Status of the VPN connection"
  value       = module.vpn_connections.vpn_gateway_connection_status
}

output "connection_establish_mode" {
  description = "Establish mode confirmed by IBM Cloud"
  value       = module.vpn_connections.vpn_gateway_connection_mode
}

output "ike_policy_id" {
  description = "IKE policy ID created (if used)"
  value       = module.ike_policies.ike_policy_id
}

output "ipsec_policy_id" {
  description = "IPsec policy ID created (if used)"
  value       = module.ipsec_policies.ipsec_policy_id
}
