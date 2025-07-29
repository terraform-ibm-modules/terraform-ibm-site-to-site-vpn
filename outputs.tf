########################################################################################################################
# Outputs
########################################################################################################################

output "ike_policies" {
  description = "List of IKE Policies."
  value       = module.vpn_policies.ike_policies
}

output "ipsec_policies" {
  description = "List of IPSec Policies."
  value       = module.vpn_policies.ipsec_policies
}

output "vpn_gateways" {
  description = "List of VPN gateways."
  value       = [for gateway in module.vpn_gateway : gateway]
}
output "vpn_connections" {
  description = "List of VPN connections."
  value       = [for conn in module.vpn_connections : conn]
}