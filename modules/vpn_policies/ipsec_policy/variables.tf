##############################################################################
# Account variables
##############################################################################

variable "resource_group_id" {
  description = "The ID of the resource group to use where you want to create the resources."
  type        = string
}

##############################################################################
# IPSec Policy variables
##############################################################################

variable "ipsec_policy_name" {
  description = "The name of the IPSec Policy."
  type        = string
}

variable "ipsec_encryption_algorithm" {
  description = "Encryption algorithm used to secure data. Allowed values: aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16."
  type        = string
  validation {
    condition     = contains(["aes128", "aes192", "aes256", "aes128gcm16", "aes192gcm16", "aes256gcm16"], var.ipsec_encryption_algorithm)
    error_message = "ipsec_encryption_algorithm must be one of: aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16."
  }
}

variable "ipsec_authentication_algorithm" {

  description = "Authentication algorithm for IPSec peers. Allowed values: sha256, sha384, sha512, disabled. Set to 'disabled' only if ipsec_encryption_algorithm belongs to GCM ciphers i.e. aes128gcm16, aes192gcm16, or aes256gcm16."
  type        = string

  validation {
    condition     = contains(["sha256", "sha384", "sha512", "disabled"], var.ipsec_authentication_algorithm)
    error_message = "Value of ipsec_authentication_algorithm must be one of: sha256, sha384, sha512 or disabled."
  }

  validation {
    condition     = var.ipsec_authentication_algorithm != "disabled" || contains(["aes128gcm16", "aes192gcm16", "aes256gcm16"], var.ipsec_encryption_algorithm)
    error_message = "If the value of ipsec_authentication_algorithm is set to 'disabled', value of ipsec_encryption_algorithm must be a GCM variant i.e aes128gcm16, aes192gcm16, aes256gcm16."
  }
}

variable "ipsec_pfs" {
  description = "Perfect Forward Secrecy (PFS) protocol to use. Allowed values: disabled, group_2, group_5, group_14."
  type        = string
  validation {
    condition     = contains(["disabled", "group_2", "group_5", "group_14"], var.ipsec_pfs)
    error_message = "Value of ipsec_pfs must be one of: disabled, group_2, group_5, group_14."
  }
}

variable "ipsec_key_lifetime" {
  description = "Optional lifetime value of the encryption key in seconds. Must be between 300 and 86400."
  type        = number
  default     = 3600
  validation {
    condition     = var.ipsec_key_lifetime >= 300 && var.ipsec_key_lifetime <= 86400
    error_message = "ipsec_key_lifetime must be between 300 and 86400 seconds."
  }
}
