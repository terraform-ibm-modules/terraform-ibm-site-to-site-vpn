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

variable "use_existing_vpn_gateway" {
  description = "If true, use a pre-existing VPN Gateway."
  type        = bool
  default     = false
}

variable "vpn_gateways" {
  description = "List of VPN gateways to create."
  nullable    = false
  type = list(
    object({
      name              = string
      subnet_id         = string
      mode              = optional(string)
      resource_group_id = optional(string)
      tags              = optional(list(string), [])
    })
  )
  default = []
}

##############################################################################
# VPN Connection variables
##############################################################################

variable "use_existing_ike_policy" {
  description = "If true, use pre-created IKE policy IDs instead of creating new ones."
  type        = bool
  default     = false
}

variable "use_existing_ipsec_policy" {
  description = "If true, use pre-created IPSec policy IDs instead of creating new ones."
  type        = bool
  default     = false
}

variable "vpn_connections" {
  description = "List of VPN gateway connections to be created."
  type = list(object({
    vpn_gateway_name            = optional(string)
    vpn_gateway_id              = optional(string)
    ike_policy_name             = optional(string)
    ipsec_policy_name           = optional(string)
    ike_policy_id               = optional(string)
    ipsec_policy_id             = optional(string)
    vpn_gateway_connection_name = string
    preshared_key               = string
    establish_mode              = optional(string, "bidirectional")
    enable_distribute_traffic   = optional(bool, false)
    is_admin_state_up           = optional(bool, false)
    peer = optional(list(object({
      address = optional(string)
      fqdn    = optional(string)
      ike_identity = list(object({
        type  = string
        value = optional(string)
      }))
    })), [])
    local = optional(list(object({
      ike_identities = list(object({
        type  = string
        value = optional(string)
      }))
    })), [])
    dpd_action         = optional(string, "restart")
    dpd_check_interval = optional(number, 2)
    dpd_max_timeout    = optional(number, 10)
  }))

  validation {
    condition = length(var.vpn_connections) > 0 && alltrue([
      for conn in var.vpn_connections :
      var.use_existing_vpn_gateway ? (conn.vpn_gateway_id != null && conn.vpn_gateway_id != "") : (conn.vpn_gateway_name != null && conn.vpn_gateway_name != "")
    ])
    error_message = "When use_existing_vpn_gateway=true, vpn_gateway_id must be provided. When false, vpn_gateway_name must be provided."
  }

  validation {
    condition = length(var.vpn_connections) > 0 && alltrue([
      for conn in var.vpn_connections :
      var.use_existing_ike_policy ? conn.ike_policy_id != null : true
    ])
    error_message = "When use_existing_ike_policy=true, ike_policy_id must be provided."
  }

  validation {
    condition = length(var.vpn_connections) > 0 && alltrue([
      for conn in var.vpn_connections :
      var.use_existing_ipsec_policy ? conn.ipsec_policy_id != null : true
    ])
    error_message = "When use_existing_ipsec_policy=true, ipsec_policy_id must be provided."
  }
}

# ##############################################################################
# Policies
# ##############################################################################

variable "ike_policies" {
  description = "List of IKE policies to be created."
  type = list(object({
    name                     = string
    resource_group           = optional(string)
    ike_version              = optional(number, 2)
    key_lifetime             = optional(number, 28800)
    encryption_algorithm     = string
    authentication_algorithm = string
    dh_group                 = number
  }))
  default = []
}

variable "ipsec_policies" {
  description = "List of IPSec policies to be created."
  type = list(object({
    name                     = string
    resource_group           = optional(string)
    encryption_algorithm     = string
    authentication_algorithm = string
    pfs                      = string
    key_lifetime             = optional(number, 3600)
  }))
  default = []
}

# ##############################################################################
# # VPN Routes Configuration
# ##############################################################################

variable "vpn_routes" {
  description = "List of routes to create in the table."
  type = list(object({
    name             = string
    zone             = string
    vpc_id           = string
    destination      = string
    next_hop         = string
    vpn_gateway_name = optional(string)
    action           = optional(string, "delegate")
    advertise        = optional(bool, false)
    priority         = optional(number, 2)
  }))
  default = []

  validation {
    condition = alltrue([
      for route in var.vpn_routes :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]+$", route.destination))
    ])
    error_message = "Each route's 'destination' must be a valid CIDR block."
  }

  validation {
    condition = alltrue([
      for route in var.vpn_routes :
      contains(["deliver", "delegate", "delegate_vpc", "drop"], route.action)
    ])
    error_message = "Each route's 'action' must be one of: deliver, delegate, delegate_vpc or drop."
  }

  validation {
    condition = alltrue([
      for route in var.vpn_routes :
      lookup(route, "priority", 2) >= 0 && lookup(route, "priority", 2) <= 4
    ])
    error_message = "Each route's 'priority' must be between 0 and 4."
  }

  validation {
    condition = alltrue([
      for route in var.vpn_routes :
      route.next_hop != null || route.vpn_gateway_name != null
    ])
    error_message = "Each route must specify either 'next_hop' or 'vpn_gateway_name'."
  }
}

##############################################################################
# VPN Route Table
##############################################################################

variable "create_route_table" {
  description = "Whether to create a new route table. Ignored if existing_route_table_id is provided"
  type        = bool
  default     = true
}
variable "existing_route_table_id" {
  description = "ID of existing route table to use. If not provided, a new route table will be created"
  type        = string
  default     = null
}

variable "routing_table_name" {
  description = "Name of the routing table to create. Only needed when create_route_table is true. "
  type        = string
  default     = null
}

variable "advertise_routes_to" {
  description = "Ingress sources to which routes in this table (with advertise enabled) should be advertised. Allowed values: direct_link, transit_gateway. Requires corresponding ingress flag to be true."
  type        = list(string)
  default     = []
}

variable "accept_routes_from_resource_type" {
  description = "List of resource types allowed to create routes in this table. Example: 'vpn_gateway', 'vpn_server'."
  type        = list(string)
  default     = []
}

variable "route_direct_link_ingress" {
  description = "If true, allows routing table to route traffic from Direct Link into the VPC."
  type        = bool
  default     = false
}

variable "route_transit_gateway_ingress" {
  description = "If true, allows routing table to route traffic from Transit Gateway into the VPC."
  type        = bool
  default     = false
}

variable "route_vpc_zone_ingress" {
  description = "If true, allows routing table to route traffic from other zones within the VPC."
  type        = bool
  default     = false
}

variable "route_internet_ingress" {
  description = "If true, allows routing table to route traffic that originates from the Internet."
  type        = bool
  default     = false
}
