#####################################################################################
# Account Variables
#####################################################################################

variable "region" {
  description = "The region to which to deploy the resources."
  type        = string
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the resources created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

variable "tags" {
  description = "List of Tags for the resource created."
  type        = list(string)
  default     = null
}

#####################################################################################
# Routing Table Variables
#####################################################################################

variable "vpc_id" {
  description = "The ID of the VPC where the routing table will be created."
  type        = string
}

variable "routing_table_name" {
  description = "Name of the routing table to create"
  type        = string
}

variable "advertise_routes_to" {
  description = "Ingress sources to which routes in this table (with advertise enabled) should be advertised. Allowed values: direct_link, transit_gateway. Requires corresponding ingress flag to be true."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for source in var.advertise_routes_to : contains(["direct_link", "transit_gateway"], source)])
    error_message = "Values for advertise_routes_to must be 'direct_link' or 'transit_gateway'."
  }
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

#####################################################################################
# Routes Variables
#####################################################################################

variable "enable_multiple_routes" {
  description = "If true, use 'routes' list to provision multiple routes. Otherwise use single route inputs."
  type        = bool
  default     = false
}

# Multiple route inputs (used if enable_multiple_routes is true)
variable "routes" {
  description = "List of routes to create in the table. To be used only when enable_multiple_routes is set to true."
  type = list(object({
    name        = string
    zone        = string
    destination = string
    next_hop    = string
    action      = string
    advertise   = optional(bool, false)
    priority    = optional(number, 2)
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.routes :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]+$", r.destination))
    ])
    error_message = "Each route's 'destination' must be a valid CIDR block."
  }

  validation {
    condition = alltrue([
      for r in var.routes :
      contains(["deliver", "delegate", "delegate_vpc", "drop"], r.action)
    ])
    error_message = "Each route's 'action' must be one of: deliver, delegate, delegate_vpc or drop."
  }

  validation {
    condition = alltrue([
      for r in var.routes :
      lookup(r, "priority", 2) >= 0 && lookup(r, "priority", 2) <= 4
    ])
    error_message = "Each route's 'priority' must be between 0 and 4."
  }
}

# Single-route inputs (to be used if enable_multiple_routes is false)

variable "routing_table_id" {
  description = "The ID of the routing table where this route belongs"
  type        = string
}

variable "route_action" {
  description = "Route action. Allowed values are: deliver, delegate, delegate_vpc, drop"
  type        = string
  default     = "deliver"
  validation {
    condition     = contains(["deliver", "delegate", "delegate_vpc", "drop"], var.route_action)
    error_message = "Route action value must be one of 'deliver', 'delegate', 'delegate_vpc' or 'drop'"
  }
}

variable "route_zone" {
  description = "The zone name where the route is applied."
  type        = string
}

variable "route_name" {
  description = "Name of the route; must be unique within the routing table"
  type        = string
}

variable "route_destination" {
  description = "The destination CIDR for this route"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]+$", var.route_destination))
    error_message = "Destination must be a valid CIDR block"
  }
}

variable "route_next_hop" {
  description = "Next hop IP or VPN Gateway connection ID"
  type        = string
}

variable "is_route_advertise" {
  description = "Whether this route should be advertised to ingress sources"
  type        = bool
  default     = false
}

variable "route_priority" {
  description = "Route priority (0-4); lower is higher priority"
  type        = number
  default     = 2
  validation {
    condition     = var.route_priority >= 0 && var.route_priority <= 4
    error_message = "Route Priority must be between 0 and 4"
  }
}
