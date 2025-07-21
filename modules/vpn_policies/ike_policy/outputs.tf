##############################################################################
# Outputs
##############################################################################

output "ike_policy_id" {
  description = "ID of the created IKE policy resource."
  value       = ibm_is_ike_policy.ike.id
}

