##############################################################################
# Account variables
##############################################################################

variable "resource_group_id" {
  description = "The ID of the resource group to use where you want to create the VPN gateway."
  type        = string
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
  description = "Name of the VPN gateway."
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
