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
# VPN Gateway
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
  validation {
    condition     = (var.create_vpn_gateway && var.vpn_gateway_name != null) || (var.existing_vpn_gateway_id != null && !var.create_vpn_gateway && var.vpn_gateway_name == null)
    error_message = "existing_vpn_gateway_id is required if create_vpn_gateway is false and vpn_gateway_name is not provided."
  }
}

variable "vpn_gateway_name" {
  description = "Name of the VPN gateway. Only required if creating a new VPN Gateway."
  type        = string
  default     = null
  validation {
    condition     = var.vpn_gateway_name == null || (var.create_vpn_gateway && var.vpn_gateway_name != null)
    error_message = "When create_vpn_gateway is true, you must provide vpn_gateway_name."
  }
}

variable "vpn_gateway_subnet_id" {
  description = "The ID of the subnet where the VPN gateway will reside in."
  type        = string
  default     = null
  validation {
    condition     = var.vpn_gateway_subnet_id == null || (var.create_vpn_gateway && var.vpn_gateway_subnet_id != null)
    error_message = "When create_vpn_gateway is true, you must provide vpn_gateway_subnet_id."
  }
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

##############################################################################
# VPN Gateway Connection Configuration
##############################################################################

variable "vpn_gateway_connection_name" {
  description = "Name of the VPN connection."
  type        = string
}

variable "preshared_key" {
  description = "Required to specify the authentication key of the VPN gateway for the network outside your VPC. [Learn More](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-create-gateway&interface=ui#planning-considerations-vpn)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.preshared_key) >= 6 && length(var.preshared_key) <= 128
    error_message = "Preshared key must be 6–128 characters long."
  }

  validation {
    condition     = !startswith(var.preshared_key, "0x") && !startswith(var.preshared_key, "0s")
    error_message = "Preshared key should not begin with '0x' or '0s'."
  }

  validation {
    condition     = can(regex("^[-+&!@#$%^*().,:a-zA-Z0-9]+$", var.preshared_key))
    error_message = "Preshared key can only contain digits, letters (a-z, A-Z), and these special characters: - + & ! @ # $ % ^ * ( ) . , :"
  }
}

variable "peer_config" {
  description = "Optional configuration for the remote peer VPN gateway. Includes peer address/FQDN, CIDRs, IKE identity type, and optional identity value."
  type = list(object({
    address = optional(string)
    fqdn    = optional(string)
    cidrs   = optional(list(string))
    ike_identity = list(object({
      type  = string
      value = optional(string)
    }))
  }))
  default  = []
  nullable = false
  validation {
    condition = length(var.peer_config) == 0 || alltrue([
      for peer in var.peer_config : alltrue([
        for id in peer.ike_identity : contains(["fqdn", "hostname",
        "ipv4_address", "key_id"], id.type)
      ])
    ])
    error_message = "Each ike_identity 'type' must be one of: fqdn, hostname, ipv4_address, or key_id."
  }

  validation {
    condition = length(var.peer_config) == 0 || alltrue([
      for peer in var.peer_config : (peer.address != null && peer.address != "") || (peer.fqdn != null && peer.fqdn != "")
    ])
    error_message = "Each peer must have either 'address' or 'fqdn' specified."
  }

  validation {
    condition     = length(var.peer_config) <= 1
    error_message = "Only one peer configuration is allowed per connection."
  }
}

variable "local_config" {
  description = "Optional configuration for local IKE identities. Each entry in the list represents a VPN gateway member in active-active mode, containing one or more IKE identities."
  type = list(object({
    cidrs = optional(list(string), [])
    ike_identities = list(object({
      type  = string
      value = optional(string)
    }))
  }))
  default  = []
  nullable = false

  validation {
    condition = length(var.local_config) == 0 || alltrue([
      for member in var.local_config : alltrue([
        for id in member.ike_identities : contains(["fqdn", "hostname",
        "ipv4_address", "key_id"], id.type)
      ])
    ])
    error_message = "Each ike_identity 'type' must be one of: fqdn, hostname, ipv4_address, or key_id."
  }

  validation {
    condition = length(var.local_config) == 0 || alltrue([
      for member in var.local_config : length(member.ike_identities) == 2
    ])
    error_message = "Each 'local' entry must have exactly 2 ike_identities."
  }
}

variable "establish_mode" {
  description = "Optional field to determine the IKE negotiation behavior for the VPN gateway connection. Use 'bidirectional' to allow both sides to initiate IKE negotiations and rekeying. Use 'peer_only' to restrict initiation and rekeying to the peer side."
  type        = string
  default     = "bidirectional"
  validation {
    condition     = contains(["bidirectional", "peer_only"], var.establish_mode)
    error_message = "establish_mode must be either 'bidirectional' or 'peer_only'."
  }
}


variable "enable_distribute_traffic" {
  description = "Optional flag for route-based VPN gateway connections to control traffic distribution across active tunnels. When true, traffic is load-balanced otherwise, it flows through the tunnel with the lower public IP."
  type        = bool
  default     = false
}

variable "is_admin_state_up" {
  description = "Optional flag to control the administrative state of the VPN gateway connection. If set to false (default), the connection is shut down. Set to true to enable the connection."
  type        = bool
  default     = false
}

# DPD settings
variable "dpd_action" {
  description = "Optional action to perform when the peer is unresponsive. Possible values are - 'restart', 'clear', 'hold', or 'none'."
  type        = string
  default     = "restart"

  validation {
    condition     = contains(["restart", "clear", "hold", "none"], var.dpd_action)
    error_message = "Please provide the correct dpd action value. Allowed values are - 'restart', 'clear', 'hold', or 'none'"
  }
}

variable "dpd_check_interval" {
  description = "Optional interval in seconds between dead peer detection checks for peer responsiveness."
  type        = number
  default     = 2
}

variable "dpd_max_timeout" {
  description = "Optional time in seconds to wait before considering the peer unreachable."
  type        = number
  default     = 10
}

###############################################################################
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
  description = "Name of the IKE policy to create. Applicable when create_vpn_policies is true"
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
  default     = null
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
    next_hop    = string
    action      = optional(string, "deliver")
    advertise   = optional(bool, false)
    priority    = optional(number, 2)
  }))
  default  = []
  nullable = false
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

variable "route_attach_subnet" {
  description = "Whether to attach subnet to the VPN route table."
  type        = bool
  default     = false
}

variable "route_subnet_id" {
  description = "Subnet ID to attach to the routing table."
  type        = string
  default     = null
  validation {
    condition     = !var.route_attach_subnet || var.route_subnet_id != null
    error_message = "When route_attach_subnet is true, you must provide a valid subnet ID."
  }
}
