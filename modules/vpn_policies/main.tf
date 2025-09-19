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
  for_each                 = { for conn in var.vpn_connections : conn.name => conn if conn.create_ike_policy }
  name                     = each.value.ike_policy_config.name
  resource_group           = var.resource_group
  authentication_algorithm = each.value.ike_policy_config.authentication_algorithm
  encryption_algorithm     = each.value.ike_policy_config.encryption_algorithm
  dh_group                 = each.value.ike_policy_config.dh_group
  ike_version              = each.value.ike_policy_config.version
  key_lifetime             = each.value.ike_policy_config.key_lifetime
}


###########################################################################################
# Internet Protocol Security (IPSec) Policy
###########################################################################################
resource "ibm_is_ipsec_policy" "ipsec" {
  for_each                 = { for conn in var.vpn_connections : conn.name => conn if conn.create_ipsec_policy }
  name                     = each.value.ipsec_policy_config.name
  resource_group           = var.resource_group
  authentication_algorithm = each.value.ipsec_policy_config.authentication_algorithm
  encryption_algorithm     = each.value.ipsec_policy_config.encryption_algorithm
  pfs                      = each.value.ipsec_policy_config.pfs
  key_lifetime             = each.value.ipsec_policy_config.key_lifetime
}

###########################################################################################
