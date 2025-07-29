##############################################################################
# Account variables
##############################################################################

variable "resource_group_id" {
  description = "The ID of the resource group to use where you want to create the resources."
  type        = string
}

##############################################################################
# IKE Policy
##############################################################################

variable "ike_policies" {
  description = "List of IKE policies to create."
  type = list(object({
    name                     = string
    authentication_algorithm = string
    encryption_algorithm     = string
    dh_group                 = number
    ike_version              = optional(number, 2)
    key_lifetime             = optional(number, 28800)
    resource_group           = optional(string)
  }))
  default = []

  validation {
    condition = length(var.ike_policies) == 0 || alltrue(
      [
        for p in var.ike_policies :
        p.key_lifetime >= local.ike_policy.lifetime.min &&
        p.key_lifetime <= local.ike_policy.lifetime.max
      ]
    )
    error_message = "IKE lifetime key must be between 1800 and 86400 seconds."
  }

  validation {
    condition = length(var.ike_policies) == 0 || alltrue(
      [for p in var.ike_policies : contains(local.ike_policy.versions, p.ike_version)]
    )
    error_message = "IKE version must be either 1 or 2."
  }

  validation {
    condition = length(var.ike_policies) == 0 || alltrue(
      [for p in var.ike_policies : contains(local.ike_policy.dh_groups, p.dh_group)]
    )
    error_message = "Value of DH group must be one of: 14 to 24, or 31."
  }

  validation {
    condition = length(var.ike_policies) == 0 || alltrue(
      [for p in var.ike_policies : contains(local.ike_policy.encryption_algo, p.encryption_algorithm)]
    )
    error_message = "Encryption algorithm must be one of: aes128, aes192, aes256."
  }

  validation {
    condition = length(var.ike_policies) == 0 || alltrue(
      [for p in var.ike_policies : contains(local.ike_policy.authentication_algo, p.authentication_algorithm)]
    )
    error_message = "Authentication algorithm must be one of: sha256, sha384, sha512."
  }

}

##############################################################################
# IPSec Policy
##############################################################################

variable "ipsec_policies" {
  description = "List of IPSec policies to create."
  type = list(object({
    name                     = string
    encryption_algorithm     = string
    authentication_algorithm = string
    pfs                      = string
    key_lifetime             = optional(number, 3600)
    resource_group           = optional(string)
  }))
  default = []

  validation {
    condition = length(var.ipsec_policies) == 0 || alltrue(
      [
        for p in var.ipsec_policies :
        p.key_lifetime >= local.ipsec_policy.lifetime.min &&
        p.key_lifetime <= local.ipsec_policy.lifetime.max
      ]
    )
    error_message = "IPSec key lifetime must be between 300 and 86400 seconds."
  }

  validation {
    condition = length(var.ipsec_policies) == 0 || alltrue(
      [for p in var.ipsec_policies : contains(local.ipsec_policy.pfs, p.pfs)]
    )
    error_message = "Value of Perfect Forward Secrecy (PFS) protocol must be one of: disabled, group_2, group_5, group_14."
  }

  validation {
    condition = length(var.ipsec_policies) == 0 || alltrue(
      [for p in var.ipsec_policies : contains(local.ipsec_policy.encryption_algo, p.encryption_algorithm)]
    )
    error_message = "Encryption Algorithm must be one of: aes128, aes192, aes256, aes128gcm16, aes192gcm16 or aes256gcm16"
  }

  validation {
    condition = length(var.ipsec_policies) == 0 || alltrue(
      [for p in var.ipsec_policies : contains(local.ipsec_policy.authentication_algo, p.authentication_algorithm)]
    )
    error_message = "Authentication Algorithm must be one of: sha256, sha384, sha512, or disabled"
  }

  validation {
    condition = length(var.ipsec_policies) == 0 || alltrue(
      [
        for p in var.ipsec_policies :
        p.authentication_algorithm != "disabled" || contains(local.ipsec_policy.gcm_variant, p.encryption_algorithm)
      ]
    )
    error_message = "If the value of authentication algorithm is set to 'disabled', value of encryption algorithm must be a GCM variant i.e aes128gcm16, aes192gcm16, aes256gcm16."
  }
}