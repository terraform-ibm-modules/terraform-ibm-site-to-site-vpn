##############################################################################
# Outputs
##############################################################################

output "ipsec_policy_id" {
  description = "ID of the created IPsec policy resource."
  value       = ibm_is_ipsec_policy.ipsec.id
}
