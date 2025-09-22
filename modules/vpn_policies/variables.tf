##############################################################################
variable "resource_group" {
  description = "Optional resource group ID for the IKE and IPSec policies. If not provided, default will be used."
  type        = string
  default     = null
}

##############################################################################
# VPN Connections - Policy Configuration
##############################################################################

variable "vpn_connections" {
  description = "List of VPN Connections with IKE and IPSec configuration. Each connection will create a new IKE/IPSec policy."
  type = list(object({
    name = string # VPN Connection Name

    # IKE Policy

    create_ike_policy      = optional(bool, false)
    existing_ike_policy_id = optional(string, null)
    ike_policy_config = optional(object({
      name                     = string
      authentication_algorithm = string
      encryption_algorithm     = string
      dh_group                 = number
      version                  = optional(number, 2)
      key_lifetime             = optional(number, 28800)
    }), null)

    # IPSec Policy

    create_ipsec_policy      = optional(bool, false)
    existing_ipsec_policy_id = optional(string, null)
    ipsec_policy_config = optional(object({
      name                     = string
      encryption_algorithm     = string
      authentication_algorithm = string
      pfs                      = string
      key_lifetime             = optional(number, 3600)
    }), null)

  }))

  # Value specific checks
  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ike_policy_config != null ? contains(local.ike_policy.authentication_algo, conn.ike_policy_config.authentication_algorithm) : (conn.existing_ike_policy_id != null)
    ])
    error_message = "Please provide a valid IKE Configuration and IKE authentication algorithm must be one of: sha256, sha384, sha512."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ike_policy_config != null ? contains(local.ike_policy.encryption_algo, conn.ike_policy_config.encryption_algorithm) : (conn.existing_ike_policy_id != null)
    ])
    error_message = "Please provide a valid IKE Configuration and IKE encryption algorithm must be one of: aes128, aes192, aes256."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ike_policy_config != null ? contains(local.ike_policy.dh_groups, conn.ike_policy_config.dh_group) : (conn.existing_ike_policy_id != null)
    ])
    error_message = "Please provide a valid IKE Configuration and IKE Diffie-Hellman (DH) group must be one of: 14 to 24, or 31."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ike_policy_config != null ? contains(local.ike_policy.versions, conn.ike_policy_config.version) : (conn.existing_ike_policy_id != null)
    ])
    error_message = "Please provide a valid IKE Configuration and IKE protocol version must be either 1 or 2."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ike_policy_config != null ? (conn.ike_policy_config.key_lifetime >= 1800 && conn.ike_policy_config.key_lifetime <= 86400) : (conn.existing_ike_policy_id != null)
    ])
    error_message = "Please provide a valid IKE Configuration and IKE key lifetime must be between 1800 and 86400 seconds."
  }

  # IPSec validations
  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_policy_config != null ? contains(local.ipsec_policy.encryption_algo, conn.ipsec_policy_config.encryption_algorithm) : (conn.existing_ipsec_policy_id != null)
    ])
    error_message = "Please provide a valid IPSec Configuration and IPSec encryption algorithm must be one of: aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_policy_config != null ? contains(local.ipsec_policy.authentication_algo, conn.ipsec_policy_config.authentication_algorithm) : (conn.existing_ipsec_policy_id != null)
    ])
    error_message = "Please provide a valid IPSec Configuration and IPSec authentication algorithm must be one of: sha256, sha384, sha512, disabled."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_policy_config != null ? (conn.ipsec_policy_config.authentication_algorithm != "disabled" || contains(local.ipsec_policy.gcm_variant, conn.ipsec_policy_config.encryption_algorithm)) : (conn.existing_ipsec_policy_id != null)
    ])
    error_message = "Please provide a valid IPSec Configuration. If the value of IPSec Authentication algorithm is set to 'disabled', value of IPSec Encryption algorithm must be a GCM variant i.e aes128gcm16, aes192gcm16, aes256gcm16."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_policy_config != null ? contains(local.ipsec_policy.pfs, conn.ipsec_policy_config.pfs) : (conn.existing_ipsec_policy_id != null)
    ])
    error_message = "Please provide a valid IPSec Configuration and IPSec Perfect Forward Secrecy (PFS) protocol must be one of: disabled, group_2, group_5, group_14."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_policy_config != null ? (conn.ipsec_policy_config.key_lifetime >= 300 && conn.ipsec_policy_config.key_lifetime <= 86400) : (conn.existing_ipsec_policy_id != null)
    ])
    error_message = "Please provide a valid IPSec Configuration and IPSec key lifetime must be between 300 and 86400 seconds."
  }
}
