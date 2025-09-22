##############################################################################
# IKE Policy
##############################################################################

output "ike_policy_ids" {
  description = "Ids of the created IKE policy."
  value       = { for name, policy in ibm_is_ike_policy.ike : name => policy.id }
}

output "ike_vpn_connections" {
  description = "VPN connections using the created IKE policies."
  value       = { for name, policy in ibm_is_ike_policy.ike : name => policy.vpn_connections }
}

output "ike_negotiation_mode" {
  description = "IKE negotiation mode set for each IKE policy."
  value       = { for name, policy in ibm_is_ike_policy.ike : name => policy.negotiation_mode }
}

##############################################################################
# IPSec Policy
##############################################################################

output "ipsec_policy_ids" {
  description = "IDs of the created IPSec policies."
  value       = { for name, policy in ibm_is_ipsec_policy.ipsec : name => policy.id }
}

output "ipsec_vpn_connections" {
  description = "VPN connections using the created IPSec policies."
  value       = { for name, policy in ibm_is_ipsec_policy.ipsec : name => policy.vpn_connections }
}

output "ipsec_encapsulation_mode" {
  description = "Encapsulation mode set for each IPSec policy."
  value       = { for name, policy in ibm_is_ipsec_policy.ipsec : name => policy.encapsulation_mode }
}

output "ipsec_transform_protocol" {
  description = "Transform protocol used in each IPSec policy."
  value       = { for name, policy in ibm_is_ipsec_policy.ipsec : name => policy.transform_protocol }
}
