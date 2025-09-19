##############################################################################
# IKE Policy
##############################################################################

output "ike_policy_ids" {
  description = "Ids of the created IKE policy."
  value       = { for conn in var.vpn_connections : conn.name => ibm_is_ike_policy.ike[conn.name].id }
}

output "ike_vpn_connections" {
  description = "List of VPN connections that are using the IKE policy created."
  value       = { for conn in var.vpn_connections : conn.name => ibm_is_ike_policy.ike[conn.name].vpn_connections }
}

output "ike_negotiation_mode" {
  description = "The IKE negotiation mode that was set for your IKE policy. Only main is supported."
  value       = try({ for conn in var.vpn_connections : conn.name => ibm_is_ike_policy.ike[conn.name].negotiation_mode }, null)
}

##############################################################################
# IPSec Policy
##############################################################################
output "ipsec_policy_ids" {
  description = "Ids of the created IPSec policy per connection."
  value       = { for conn in var.vpn_connections : conn.name => ibm_is_ipsec_policy.ipsec[conn.name].id }
}

output "ipsec_vpn_connections" {
  description = "List of VPN connections that are using the IPSec policy created."
  value       = { for conn in var.vpn_connections : conn.name => ibm_is_ipsec_policy.ipsec[conn.name].vpn_connections }
}

output "ipsec_encapsulation_mode" {
  description = "The encapsulation mode that was set for your IPSec policy. Only tunnel is supported."
  value       = try({ for conn in var.vpn_connections : conn.name => ibm_is_ipsec_policy.ipsec[conn.name].encapsulation_mode }, null)
}

output "ipsec_transform_protocol" {
  description = "The transform protocol that is used in your IPSec policy."
  value       = { for conn in var.vpn_connections : conn.name => ibm_is_ipsec_policy.ipsec[conn.name].transform_protocol }
}
