##############################################################################
variable "resource_group" {
  description = "Optional resource group ID for the IKE and IPSec policies. If not provided, default will be used."
  type        = string
  default     = null
}

##############################################################################
# VPN Connections - Policy Configuratrion
##############################################################################

variable "vpn_connections" {
  description = "List of VPN Connections with IKE and IPSec configuration. Each connection can either create a new IKE/IPSec policy or reuse an existing policy Id."
  type = list(object({
    name = string

    # IKE Policy
    create_ike_policy      = optional(bool, false)
    # existing_ike_policy_id = optional(string, null)

    ike_policy_name              = optional(string)
    ike_authentication_algorithm = optional(string)
    ike_encryption_algorithm     = optional(string)
    ike_dh_group                 = optional(number)
    ike_version                  = optional(number, 2)
    ike_key_lifetime             = optional(number, 28800)

    # IPSec Policy
    create_ipsec_policy      = optional(bool, false)
    # existing_ipsec_policy_id = optional(string, null)

    ipsec_policy_name              = optional(string)
    ipsec_encryption_algorithm     = optional(string)
    ipsec_authentication_algorithm = optional(string)
    ipsec_pfs                      = optional(string)
    ipsec_key_lifetime             = optional(number, 3600)
  }))

  validation {
    condition = alltrue([
    for conn in var.vpn_connections : conn.ike_authentication_algorithm == null || contains(local.ike_policy.authentication_algo, conn.ike_authentication_algorithm)])
    error_message = "IKE authentication algorithm must be one of: sha256, sha384, sha512."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ike_encryption_algorithm == null || contains(local.ike_policy.encryption_algo, conn.ike_encryption_algorithm)
    ])
    error_message = "IKE encryption algorithm must be one of: aes128, aes192, aes256."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ike_dh_group == null || contains(local.ike_policy.dh_groups, conn.ike_dh_group)
    ])
    error_message = "IKE Diffie-Hellman (DH) group must be one of: 14 to 24, or 31."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ike_version == null || contains(local.ike_policy.versions, conn.ike_version)
    ])
    error_message = "IKE protocol version must be either 1 or 2."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ike_key_lifetime == null || (conn.ike_key_lifetime >= 1800 && conn.ike_key_lifetime <= 86400)
    ])
    error_message = "IKE key lifetime must be between 1800 and 86400 seconds."
  }

  # IPSec validations
  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_encryption_algorithm == null || contains(local.ipsec_policy.encryption_algo, conn.ipsec_encryption_algorithm)
    ])
    error_message = "IPSec encryption algorithm must be one of: aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_authentication_algorithm == null || contains(local.ipsec_policy.authentication_algo, conn.ipsec_authentication_algorithm)
    ])
    error_message = "IPSec authentication algorithm must be one of: sha256, sha384, sha512, disabled."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_authentication_algorithm != "disabled" || contains(local.ipsec_policy.gcm_variant, conn.ipsec_encryption_algorithm)
    ])
    error_message = "If the value of IPSec Authentication algorithm is set to 'disabled', value of IPSec Encryption algorithm must be a GCM variant i.e aes128gcm16, aes192gcm16, aes256gcm16."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_pfs == null || contains(local.ipsec_policy.pfs, conn.ipsec_pfs)
    ])
    error_message = "IPSec Perfect Forward Secrecy (PFS) protocol must be one of: disabled, group_2, group_5, group_14."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_key_lifetime == null || (conn.ipsec_key_lifetime >= 300 && conn.ipsec_key_lifetime <= 86400)
    ])
    error_message = "IPSec key lifetime must be between 300 and 86400 seconds."
  }
}