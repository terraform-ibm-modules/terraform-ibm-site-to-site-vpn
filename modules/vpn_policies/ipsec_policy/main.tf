###########################################################################################
# Internet Protocol Security (IPSec) Policy
###########################################################################################

resource "ibm_is_ipsec_policy" "ipsec" {
  name                     = var.ipsec_policy_name
  resource_group           = var.resource_group_id
  encryption_algorithm     = var.ipsec_encryption_algorithm
  authentication_algorithm = var.ipsec_authentication_algorithm
  pfs                      = var.ipsec_pfs
  key_lifetime             = var.ipsec_key_lifetime
}
