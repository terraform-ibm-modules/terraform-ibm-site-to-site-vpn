##############################################################################
# Account variables
##############################################################################

variable "resource_group_id" {
  description = "The ID of the resource group to use where you want to create the resources."
  type        = string
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
