# VPN Policy Submodule for IBM Cloud Site-to-Site VPN
locals {

  ike_policy = {
    authentication_algo = ["sha256", "sha384", "sha512"]
    encryption_algo     = ["aes128", "aes192", "aes256"]
    dh_groups           = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 31]
    versions            = [1, 2]
  }

  ipsec_policy = {
    authentication_algo = ["sha256", "sha384", "sha512", "disabled"]
    encryption_algo     = ["aes128", "aes192", "aes256", "aes128gcm16", "aes192gcm16", "aes256gcm16"]
    pfs                 = ["disabled", "group_2", "group_5", "group_14"]
    gcm_variant         = ["aes128gcm16", "aes192gcm16", "aes256gcm16"]
  }
}

###########################################################################################
# Internet Key Exchange (IKE) Policy
###########################################################################################

resource "ibm_is_ike_policy" "ike" {
  name                     = var.ike_policy_name
  resource_group           = var.resource_group
  authentication_algorithm = var.ike_authentication_algorithm
  encryption_algorithm     = var.ike_encryption_algorithm
  dh_group                 = var.ike_dh_group
  ike_version              = var.ike_version
  key_lifetime             = var.ike_key_lifetime
}


###########################################################################################
# Internet Protocol Security (IPSec) Policy
###########################################################################################
resource "ibm_is_ipsec_policy" "ipsec" {
  name                     = var.ipsec_policy_name
  resource_group           = var.resource_group
  authentication_algorithm = var.ipsec_authentication_algorithm
  encryption_algorithm     = var.ipsec_encryption_algorithm
  pfs                      = var.ipsec_pfs
  key_lifetime             = var.ipsec_key_lifetime
}

###########################################################################################
