##############################################################################
# Outputs
##############################################################################

output "ike_policies" {
  description = "IKE policy details."
  value = { for k, v in ibm_is_ike_policy.ike : k => {
    id   = v.id
    name = v.name
  } }
}

output "ipsec_policies" {
  description = "IPSec policy details."
  value = { for k, v in ibm_is_ipsec_policy.ipsec : k => {
    id   = v.id
    name = v.name
  } }
}