
###########################################################################################
# Internet Key Exchange (IKE) Policy
###########################################################################################

resource "ibm_is_ike_policy" "ike" {
  name                     = var.ike_policy_name
  resource_group           = var.resource_group
  ike_version              = var.ike_version
  encryption_algorithm     = var.ike_encryption_algorithm
  authentication_algorithm = var.ike_authentication_algorithm
  dh_group                 = var.ike_dh_group
  key_lifetime             = var.ike_key_lifetime
}

###########################################################################################
# Internet Protocol Security (IPSec) Policy
###########################################################################################

resource "ibm_is_ipsec_policy" "ipsec" {
  name                     = var.ipsec_policy_name
  resource_group           = var.resource_group
  encryption_algorithm     = var.ipsec_encryption_algorithm
  authentication_algorithm = var.ipsec_authentication_algorithm
  pfs                      = var.ipsec_pfs
  key_lifetime             = var.ipsec_key_lifetime
}
