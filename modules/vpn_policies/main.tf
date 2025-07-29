# VPN Policy Submodule for IBM Cloud Site-to-Site VPN
locals {

  ike_policy = {
    lifetime            = { min = 1800, max = 86400 }
    authentication_algo = ["sha256", "sha384", "sha512"]
    encryption_algo     = ["aes128", "aes192", "aes256"]
    dh_groups           = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 31]
    versions            = [1, 2]
  }

  ipsec_policy = {
    lifetime            = { min = 300, max = 86400 }
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
  for_each                 = { for policy in var.ike_policies : policy.name => policy }
  name                     = each.key
  authentication_algorithm = each.value.authentication_algorithm
  encryption_algorithm     = each.value.encryption_algorithm
  dh_group                 = each.value.dh_group
  ike_version              = each.value.ike_version
  key_lifetime             = each.value.key_lifetime
  resource_group           = var.resource_group_id
}

###########################################################################################
# Internet Protocol Security (IPSec) Policy
###########################################################################################

resource "ibm_is_ipsec_policy" "ipsec" {
  for_each                 = { for policy in var.ipsec_policies : policy.name => policy }
  name                     = each.key
  authentication_algorithm = each.value.authentication_algorithm
  encryption_algorithm     = each.value.encryption_algorithm
  pfs                      = each.value.pfs
  key_lifetime             = each.value.key_lifetime
  resource_group           = var.resource_group_id
}

###########################################################################################