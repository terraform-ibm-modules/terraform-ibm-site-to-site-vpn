##############################################################################
# IKE Policy
##############################################################################

variable "ike_policy_name" {
  description = "The name of the IKE policy to create."
  type        = string
}

variable "ike_authentication_algorithm" {
  description = "The authentication algorithm used in the IKE policy. Valid values: sha256, sha384, sha512."
  type        = string

  validation {
    condition     = contains(local.ike_policy.authentication_algo, var.ike_authentication_algorithm)
    error_message = "Authentication algorithm must be one of: sha256, sha384, sha512."
  }
}

variable "ike_encryption_algorithm" {
  description = "The encryption algorithm used in the IKE policy. Valid values: aes128, aes192, aes256."
  type        = string

  validation {
    condition     = contains(local.ike_policy.encryption_algo, var.ike_encryption_algorithm)
    error_message = "Encryption algorithm must be one of: aes128, aes192, aes256."
  }
}

variable "ike_dh_group" {
  description = "The Diffie-Hellman group to use. Valid values: 14 to 24, or 31."
  type        = number

  validation {
    condition     = contains(local.ike_policy.dh_groups, var.ike_dh_group)
    error_message = "DH group must be one of: 14 to 24, or 31."
  }
}

variable "ike_version" {
  description = "The IKE protocol version to use. Valid values: 1 or 2."
  type        = number
  default     = 2

  validation {
    condition     = contains(local.ike_policy.versions, var.ike_version)
    error_message = "IKE version must be either 1 or 2."
  }
}

variable "ike_key_lifetime" {
  description = "The key lifetime in seconds. Must be between 1800 and 86400."
  type        = number
  default     = 28800

  validation {
    condition     = var.ike_key_lifetime >= 1800 && var.ike_key_lifetime <= 86400
    error_message = "IKE lifetime key must be between 1800 and 86400 seconds."
  }
}

variable "ike_resource_group" {
  description = "Optional resource group ID for the IKE policy. If not provided, default will be used."
  type        = string
  default     = null
}

##############################################################################
# IPSec Policy
##############################################################################

variable "ipsec_policy_name" {
  description = "The name of the IPSec policy to create."
  type        = string
}

variable "ipsec_encryption_algorithm" {
  description = "The encryption algorithm for the IPSec policy. Valid values: aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16."
  type        = string

  validation {
    condition     = contains(local.ipsec_policy.encryption_algo, var.ipsec_encryption_algorithm)
    error_message = "Encryption algorithm must be one of: aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16."
  }
}

variable "ipsec_authentication_algorithm" {
  description = "The authentication algorithm for the IPSec policy. Valid values: sha256, sha384, sha512, disabled."
  type        = string

  validation {
    condition     = contains(local.ipsec_policy.authentication_algo, var.ipsec_authentication_algorithm)
    error_message = "Authentication algorithm must be one of: sha256, sha384, sha512 or disabled."
  }

  validation {
    condition     = var.ipsec_authentication_algorithm != "disabled" || contains(local.ipsec_policy.gcm_variant, var.ipsec_encryption_algorithm)
    error_message = "If the value of IPSec Authentication algorithm is set to 'disabled', value of IPSec Encryption algorithm must be a GCM variant i.e aes128gcm16, aes192gcm16, aes256gcm16."
  }

}

variable "ipsec_pfs" {
  description = "The Perfect Forward Secrecy (PFS) protocol for the IPSec policy. Valid values: disabled, group_2, group_5, group_14."
  type        = string

  validation {
    condition     = contains(local.ipsec_policy.pfs, var.ipsec_pfs)
    error_message = "PFS must be one of: disabled, group_2, group_5, group_14."
  }
}

variable "ipsec_key_lifetime" {
  description = "The key lifetime for the IPSec policy in seconds. Must be between 300 and 86400."
  type        = number
  default     = 3600

  validation {
    condition     = var.ipsec_key_lifetime >= 300 && var.ipsec_key_lifetime <= 86400
    error_message = "Key lifetime must be between 300 and 86400 seconds."
  }
}

variable "ipsec_resource_group" {
  description = "Optional resource group ID for the IPSec policy. If not provided, default will be used."
  type        = string
  default     = null
}
