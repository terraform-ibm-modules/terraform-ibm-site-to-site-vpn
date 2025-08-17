#####################################################################################
# Input Variables
#####################################################################################

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

variable "create_vpn_gateway" {
  description = "Whether to create a new VPN Gateway. Set to false to use an existing gateway."
  type        = bool
  default     = true
}

variable "existing_vpn_gateway_id" {
  description = "ID of existing VPN Gateway to use. Required if create_vpn_gateway is false and vpn_gateway_name is not provided."
  type        = string
  default     = null
}

variable "vpn_gateway_name" {
  description = "Name of the VPN gateway to create. Required if create_vpn_gateway is true."
  type        = string
  default     = null

  validation {
    condition = (
      var.vpn_gateway_name != null ||
      var.existing_vpn_gateway_id != null
    )
    error_message = "Either vpn_gateway_name or existing_vpn_gateway_id must be provided."
  }
}

variable "vpn_gateway_subnet_id" {
  description = "Subnet ID where VPN gateway will be created. Required if create_vpn_gateway is true."
  type        = string
  default     = null
}

variable "vpn_gateway_mode" {
  description = "Mode of the VPN gateway (route or policy)."
  type        = string
  default     = "route"
  validation {
    condition     = contains(["route", "policy"], var.vpn_gateway_mode)
    error_message = "VPN gateway mode must be either 'route' or 'policy'."
  }
}

##############################################################################
# Peer Connection Configuration
##############################################################################

variable "create_connection" {
  description = "Whether to create a VPN connection. Set to false if only managing gateway/policies."
  type        = bool
  default     = false
}

variable "connection_name" {
  description = "Name of the VPN connection."
  type        = string
  default     = null
}

variable "preshared_key" {
  description = "Pre-shared key for the VPN connection."
  type        = string
  sensitive   = true
  default     = null
}

variable "peer_config" {
  description = "Peer configuration for the VPN connection."
  type = list(object({
    address = optional(string)
    fqdn    = optional(string)
    cidrs   = optional(list(string), [])
    ike_identity = list(object({
      type  = string
      value = optional(string)
    }))
  }))
  default = []

  validation {
    condition     = length(var.peer_config) == 0 || length(var.peer_config) == 1
    error_message = "Only one peer configuration is allowed per connection."
  }
}

variable "local_config" {
  description = "Local configuration for the VPN connection."
  type = list(object({
    ike_identities = list(object({
      type  = string
      value = optional(string)
    }))
  }))
  default = []
}

variable "establish_mode" {
  description = "IKE negotiation behavior. 'bidirectional' allows both sides to initiate, 'peer_only' restricts to peer side."
  type        = string
  default     = "bidirectional"
  validation {
    condition     = contains(["bidirectional", "peer_only"], var.establish_mode)
    error_message = "establish_mode must be either 'bidirectional' or 'peer_only'."
  }
}

variable "enable_distribute_traffic" {
  description = "Enable traffic distribution across active tunnels for route-based VPN."
  type        = bool
  default     = false
}

variable "is_admin_state_up" {
  description = "Administrative state of the VPN connection."
  type        = bool
  default     = true
}

# DPD settings
variable "dpd_action" {
  description = "Action when peer is unresponsive: 'restart', 'clear', 'hold', or 'none'."
  type        = string
  default     = "restart"
  validation {
    condition     = contains(["restart", "clear", "hold", "none"], var.dpd_action)
    error_message = "dpd_action must be one of: restart, clear, hold, none."
  }
}

variable "dpd_check_interval" {
  description = "Dead peer detection check interval in seconds."
  type        = number
  default     = 2
}

variable "dpd_max_timeout" {
  description = "Dead peer detection timeout in seconds."
  type        = number
  default     = 10
}

# ##############################################################################
# Policies
# ##############################################################################

variable "existing_ike_policy_id" {
  description = "ID of existing IKE policy to use instead of creating new one."
  type        = string
  default     = null
}

variable "existing_ipsec_policy_id" {
  description = "ID of existing IPSec policy to use instead of creating new one."
  type        = string
  default     = null
}

variable "create_vpn_policies" {
  description = "Whether to create a new IKE and IPSec policy."
  type        = bool
  default     = false

  validation {
    condition = !var.create_vpn_policies || (
      var.ike_policy_name != null &&
      var.ike_authentication_algorithm != null &&
      var.ike_encryption_algorithm != null &&
      var.ike_dh_group != null &&
      var.ipsec_policy_name != null &&
      var.ipsec_encryption_algorithm != null &&
      var.ipsec_authentication_algorithm != null &&
      var.ipsec_pfs != null
    )
    error_message = "When create_vpn_policies is true, all policy configuration variables must be provided: ike_policy_name, ike_authentication_algorithm, ike_encryption_algorithm, ike_dh_group, ipsec_policy_name, ipsec_encryption_algorithm, ipsec_authentication_algorithm, ipsec_pfs."
  }
}

# IKE Policy inputs
variable "ike_policy_name" {
  description = "Name of the IKE policy to create."
  type        = string
  default     = null
}

variable "ike_authentication_algorithm" {
  description = "The authentication algorithm used in the IKE policy. Valid values: sha256, sha384, sha512."
  type        = string
  default     = null
}

variable "ike_encryption_algorithm" {
  description = "The encryption algorithm used in the IKE policy. Valid values: aes128, aes192, aes256."
  type        = string
  default     = null
}

variable "ike_dh_group" {
  description = "The Diffie-Hellman group to use. Valid values: 14 to 24, or 31."
  type        = number
  default     = null
}

variable "ike_version" {
  description = "The IKE protocol version to use. Valid values: 1 or 2."
  type        = number
  default     = 2
}

variable "ike_key_lifetime" {
  description = "The key lifetime in seconds. Must be between 1800 and 86400."
  type        = number
  default     = 28800
}

# IPSec Policy inputs
variable "ipsec_policy_name" {
  description = "Name of the IPSec policy to create."
  type        = string
  default     = null
}

variable "ipsec_encryption_algorithm" {
  description = "The encryption algorithm for the IPSec policy. Valid values: aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16."
  type        = string
  default     = null
}

variable "ipsec_authentication_algorithm" {
  description = "The authentication algorithm for the IPSec policy. Valid values: sha256, sha384, sha512, disabled."
  type        = string
  default     = null
}

variable "ipsec_pfs" {
  description = "The Perfect Forward Secrecy (PFS) protocol for the IPSec policy. Valid values: disabled, group_2, group_5, group_14."
  type        = string
  default     = null # Optional unless create_vpn_policies is true
}

variable "ipsec_key_lifetime" {
  description = "The key lifetime for the IPSec policy in seconds. Must be between 300 and 86400."
  type        = number
  default     = 3600
}

# ##############################################################################
# VPN Routes Configuration
# ##############################################################################

variable "vpc_id" {
  description = "VPC ID where routes will be created."
  type        = string
  default     = null
}

variable "create_routes" {
  description = "Whether to create VPN routes."
  type        = bool
  default     = false
}

variable "routes" {
  description = "List of routes to create."
  type = list(object({
    name        = string
    zone        = string
    destination = string
    action      = optional(string, "delegate")
    advertise   = optional(bool, false)
    priority    = optional(number, 2)
  }))
  default = []
}

##############################################################################
# VPN Route Table Configuration
##############################################################################

variable "create_route_table" {
  description = "Whether to create a new route table."
  type        = bool
  default     = false
}

variable "existing_route_table_id" {
  description = "ID of existing route table to use."
  type        = string
  default     = null
}

variable "routing_table_name" {
  description = "Name of the routing table to create."
  type        = string
  default     = null
}

variable "advertise_routes_to" {
  description = "Ingress sources to which routes should be advertised."
  type        = list(string)
  default     = []
}

variable "accept_routes_from_resource_type" {
  description = "List of resource types allowed to create routes in this table."
  type        = list(string)
  default     = []
}

variable "route_direct_link_ingress" {
  description = "Allow routing from Direct Link."
  type        = bool
  default     = false
}

variable "route_transit_gateway_ingress" {
  description = "Allow routing from Transit Gateway."
  type        = bool
  default     = false
}

variable "route_vpc_zone_ingress" {
  description = "Allow routing from other zones within the VPC."
  type        = bool
  default     = false
}

variable "route_internet_ingress" {
  description = "Allow routing from Internet."
  type        = bool
  default     = false
}

variable "attach_subnet" {
  description = "Whether to attach subnet to the VPN route table."
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID to attach to the routing table."
  type        = string
  default     = null
  validation {
    condition     = !var.attach_subnet || var.subnet_id != null
    error_message = "When attach_subnet is true, you must provide a valid subnet ID."
  }
}
