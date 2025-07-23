#####################################################################################
# Input Variables
#####################################################################################
variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources."
  default     = "Default"
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

variable "vpn_connections" {
  description = "List of VPN gateway connections to be created."
  type = list(object({
    vpn_gateway_connection_name = string
    vpn_gateway_id              = string
    preshared_key               = string
    establish_mode              = string
    enable_distribute_traffic   = optional(bool)
    ike_policy_key_id           = string
    ipsec_policy_key_id         = string
    is_admin_state_up           = optional(bool)
    peer_config = optional(list(object({
      address = optional(string)
      fqdn    = optional(string)
      ike_identity = list(object({
        type  = string
        value = optional(string)
      }))
    })), [])
    local_config = optional(list(object({
      ike_identities = list(object({
        type  = string
        value = optional(string)
      }))
    })), [])
    dpd_action         = optional(string)
    dpd_check_interval = optional(number)
    dpd_max_timeout    = optional(number)
  }))
}

##############################################################################
# Policies
##############################################################################

variable "use_existing_ike_policies" {
  description = "If true, use pre-created IKE policy IDs instead of creating new ones."
  type        = bool
  default     = false
}

variable "use_existing_ipsec_policies" {
  description = "If true, use pre-created IPSec policy IDs instead of creating new ones."
  type        = bool
  default     = false
}

variable "ike_policies" {
  description = "List of IKE policies to create"
  type = list(object({
    name = string
    # resource_group           = string
    ike_version              = number
    encryption_algorithm     = string
    authentication_algorithm = string
    dh_group                 = number
    key_lifetime             = number
  }))
  default = []
}

variable "ipsec_policies" {
  description = "List of IPSec policies to create"
  type = list(object({
    name = string
    # resource_group           = string
    encryption_algorithm     = string
    authentication_algorithm = string
    pfs                      = string
    key_lifetime             = number
  }))
  default = []
}

##############################################################################
# VPN Routes Configuration
##############################################################################

variable "vpn_routes_config" {
  description = "Map of routing table configs for VPN routes."
  type = map(object({
    routing_table_name = string
    route_table_ingress_config = optional(object({
      route_direct_link_ingress     = optional(bool)
      route_transit_gateway_ingress = optional(bool)
      route_vpc_zone_ingress        = optional(bool)
    }))
    routes = list(object({
      name        = string
      zone        = string
      destination = string
      action      = string
      next_hop    = string
    }))
  }))
}
