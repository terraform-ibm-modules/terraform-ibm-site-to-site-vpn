##############################################################################
# Account variables
##############################################################################

variable "resource_group" {
  description = "The name of the resource group where you want to create the IKE or IPSec Policies."
  type        = string
  default     = "Default"
}

variable "tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

##############################################################################
# IKE Policy variables
##############################################################################

variable "ike_policy_name" {
  description = "The name of the IKE Policy."
  type        = string
}

variable "ike_authentication_algorithm" {
  description = "Algorithm used to authenticate IKE peers. Allowed values: sha256, sha384, sha512."
  type        = string
  validation {
    condition     = contains(["sha256", "sha384", "sha512"], var.ike_authentication_algorithm)
    error_message = "ike_authentication_algorithm must be one of: sha256, sha384, sha512."
  }
}

variable "ike_encryption_algorithm" {
  description = "IKE Algorithm that is required to encrypt VPN traffic. Allowed values: aes128, aes192, aes256."
  type        = string
  validation {
    condition     = contains(["aes128", "aes192", "aes256"], var.ike_encryption_algorithm)
    error_message = "ike_encryption_algorithm must be one of: aes128, aes192, aes256."
  }
}

variable "ike_dh_group" {
  description = "Diffie-Hellman group used for IKE key exchange. Allowed values are: 14‑24, 31."
  type        = number
  validation {
    condition     = contains([14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 31], var.ike_dh_group)
    error_message = "Value fo ike_dh_group must be one of: 14 to 24, or 31."
  }
}

variable "ike_version" {
  description = "Optional IKE protocol version. Allowed values: 1 or 2."
  type        = number
  default     = 2
  validation {
    condition     = contains([1, 2], var.ike_version)
    error_message = "ike_version must be either 1 or 2."
  }
}

variable "ike_key_lifetime" {
  description = "Optional key lifetime in seconds (min 1800, max 86400)."
  type        = number
  default     = 28800
  validation {
    condition     = var.ike_key_lifetime >= 1800 && var.ike_key_lifetime <= 86400
    error_message = "ike_key_lifetime must be between 1800 and 86400 seconds."
  }
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
