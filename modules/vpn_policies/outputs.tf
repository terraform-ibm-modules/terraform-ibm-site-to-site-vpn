##############################################################################
# IKE Policy
##############################################################################

output "ike_policy_id" {
  description = "Id of the created IKE policy."
  value       = ibm_is_ike_policy.ike.id
}

output "ike_vpn_connections" {
  description = "List of VPN connections that are using the IKE policy created."
  value       = ibm_is_ike_policy.ike.vpn_connections
}

output "ike_negotiation_mode" {
  description = "The IKE negotiation mode that was set for your IKE policy. Only main is supported."
  value       = ibm_is_ike_policy.ike.negotiation_mode
}

##############################################################################
# IPSec Policy
##############################################################################
output "ipsec_policy_id" {
  description = "Id of the created IPSec policy."
  value       = ibm_is_ipsec_policy.ipsec.id
}

output "ipsec_vpn_connections" {
  description = "List of VPN connections that are using the IPSec policy created."
  value       = ibm_is_ipsec_policy.ipsec.vpn_connections
}

output "ipsec_encapsulation_mode" {
  description = "The encapsulation mode that was set for your IPSec policy. Only tunnel is supported."
  value       = ibm_is_ipsec_policy.ipsec.encapsulation_mode
}

output "ipsec_transform_protocol" {
  description = "The transform protocol that is used in your IPSec policy."
  value       = ibm_is_ipsec_policy.ipsec.transform_protocol
}
