##############################################################################
# Account variables
##############################################################################

variable "resource_group_id" {
  description = "The ID of the resource group to use where you want to create the VPN gateway."
  type        = string
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the VPN resources created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

variable "tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

##############################################################################
# VPN Gateway variables
##############################################################################

variable "vpn_gateway_name" {
  description = "The user-defined name for the VPN gateway. If unspecified, the name will be a hyphenated list of randomly-selected words. Names must be unique within the VPC the VPN server is serving."
  type        = string
}

variable "vpn_gateway_mode" {
  description = "Specifies the VPN configuration mode for IBM Cloud VPN for VPC. Use 'route' for a static, route-based IPsec tunnel or 'policy' for a policy-based tunnel to connect your VPC to another private network."
  type        = string
  default     = "route"
  validation {
    condition     = contains(["route", "policy"], var.vpn_gateway_mode)
    error_message = "vpn_gateway_mode value must be either 'route' or 'policy'."
  }
}

variable "subnet_id" {
  description = "The ID of the subnet where the VPN gateway will reside in"
  type        = string
}

#######################################################################################################