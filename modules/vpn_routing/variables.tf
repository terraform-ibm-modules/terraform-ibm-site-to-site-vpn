#####################################################################################
# Account Variables
#####################################################################################

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

variable "existing_route_table_id" {
  description = "ID of existing route table to use. If not provided, a new route table will be created"
  type        = string
  default     = null
}

variable "create_route_table" {
  description = "Whether to create a new route table. Ignored if existing_route_table_id is provided"
  type        = bool
  default     = true
}

variable "routing_table_name" {
  description = "Name of the routing table to create. Required when creating a new route table."
  type        = string
  default     = null

  validation {
    condition = (
      var.existing_route_table_id != null ||
      !var.create_route_table ||
      var.routing_table_name != null
    )
    error_message = "routing_table_name is required when creating a new route table i.e. create_route_table is true and existing_route_table_id is null ."
  }
}

variable "advertise_routes_to" {
  description = "Ingress sources to which routes in this table (with advertise enabled) should be advertised. Allowed values: direct_link, transit_gateway. Requires corresponding ingress flag to be true."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for source in var.advertise_routes_to : contains(["direct_link", "transit_gateway"], source)
    ])
    error_message = "Values for advertise_routes_to must be 'direct_link' or 'transit_gateway'."
  }
}

variable "accept_routes_from_resource_type" {
  description = "List of resource types allowed to create routes in this table."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for resource_type in var.accept_routes_from_resource_type :
      contains(["vpn_gateway", "vpn_server"], resource_type)
    ])
    error_message = "Accepted resource types are 'vpn_gateway' and 'vpn_server'."
  }
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

variable "route_attach_subnet" {
  description = "Whether to attach subnet to the VPN route table."
  type        = bool
  default     = false
}

variable "subnet_id_to_attach" {
  description = "Subnet ID to attach to the routing table."
  type        = string
  default     = null

  validation {
    condition     = !var.route_attach_subnet || var.subnet_id_to_attach != null
    error_message = "When route_attach_subnet is true, you must provide a valid subnet ID."
  }
}

#####################################################################################
# Routes Variables
#####################################################################################

variable "vpn_gateway_mode" {
  description = "Mode of the VPN gateway. Allowed values: policy, route"
  type        = string
  default     = "route"
  validation {
    condition     = contains(["route", "policy"], var.vpn_gateway_mode)
    error_message = "vpn_gateway_mode value must be either 'route' or 'policy'."
  }
}

variable "existing_routes" {
  description = "List of existing route configurations to use."
  type = list(object({
    destination         = string
    next_hop            = string
    zone                = string
    name                = optional(string)
    action              = optional(string, "deliver")
    advertise           = optional(bool, false)
    priority            = optional(number, 2)
    vpn_connection_name = optional(string, null)
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for route in var.existing_routes : contains(["deliver", "delegate", "delegate_vpc", "drop"], route.action)
    ])
    error_message = "Route action must be one of 'deliver', 'delegate', 'delegate_vpc' or 'drop'."
  }

  validation {
    condition = alltrue([
      for route in var.existing_routes : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]+$", route.destination))
    ])
    error_message = "Destination must be a valid CIDR block."
  }

  validation {
    condition = alltrue([
      for route in var.existing_routes : route.priority >= 0 && route.priority <= 4
    ])
    error_message = "Route Priority must be between 0 and 4."
  }
}

variable "vpn_connection_ids" {
  description = "Map of VPN connection names to their IDs."
  type        = map(string)
  default     = {}
}

variable "vpn_routes" {
  description = "List of VPN routes to create."
  type = list(object({
    destination         = string
    next_hop            = string
    zone                = string
    name                = optional(string)
    action              = optional(string, "deliver")
    advertise           = optional(bool, false)
    priority            = optional(number, 2)
    vpn_connection_name = optional(string, null) # This is required to attach routes with multiple connections.
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for route in var.vpn_routes : contains(["deliver", "delegate", "delegate_vpc", "drop"], route.action)
    ])
    error_message = "Route action must be one of 'deliver', 'delegate', 'delegate_vpc' or 'drop'."
  }

  validation {
    condition = alltrue([
      for route in var.vpn_routes : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]+$", route.destination))
    ])
    error_message = "Destination must be a valid CIDR block."
  }

  validation {
    condition = alltrue([
      for route in var.vpn_routes : route.priority >= 0 && route.priority <= 4
    ])
    error_message = "Route Priority must be between 0 and 4."
  }
}
