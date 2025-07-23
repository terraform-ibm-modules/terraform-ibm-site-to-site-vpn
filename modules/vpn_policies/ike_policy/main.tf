
###########################################################################################
# Internet Key Exchange (IKE) Policy
###########################################################################################

resource "ibm_is_ike_policy" "ike" {
  name                     = var.ike_policy_name
  resource_group           = var.resource_group_id
  ike_version              = var.ike_version
  encryption_algorithm     = var.ike_encryption_algorithm
  authentication_algorithm = var.ike_authentication_algorithm
  dh_group                 = var.ike_dh_group
  key_lifetime             = var.ike_key_lifetime
}
