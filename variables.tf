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

variable "vpn_connections" {
  description = "List of VPN connections to attach to the VPN gateway."
  type = list(object({
    name                      = string                            # Name of the VPN connection
    preshared_key             = string                            # Required to specify the authentication key of the VPN gateway for the network outside your VPC. [Learn More](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-create-gateway&interface=ui#planning-considerations-vpn)
    is_admin_state_up         = optional(bool, false)             # Flag to control the administrative state of the VPN gateway connection. If set to false (default), the connection is shut down. Set to true to enable the connection.
    establish_mode            = optional(string, "bidirectional") # Determines IKE negotiation behavior for the VPN gateway connection. Use 'bidirectional' to allow both sides to initiate IKE negotiations and rekeying. Use 'peer_only' to restrict initiation and rekeying to the peer side.
    enable_distribute_traffic = optional(bool, false)             # Flag for route-based VPN gateway connections to control traffic distribution across active tunnels. When true, traffic is load-balanced otherwise, it flows through the tunnel with the lower public IP.
    dpd_action                = optional(string, "restart")       # Action to perform when the peer is unresponsive. Possible values are - 'restart', 'clear', 'hold', or 'none'.
    dpd_check_interval        = optional(number, 2)               # Interval in seconds between dead peer detection checks for peer responsiveness.
    dpd_max_timeout           = optional(number, 10)              # Time in seconds to wait before considering the peer unreachable.

    # Policy configuration per connection

    # IKE Policy
    create_ike_policy      = optional(bool, false)  # Flag to create new IKE policy.
    existing_ike_policy_id = optional(string, null) # ID of existing IKE policy to use (mutually exclusive with create_ike_policy)

    ike_policy_config = optional(object({
      name                     = string
      authentication_algorithm = string # sha256, sha384, sha512
      encryption_algorithm     = string # aes128, aes192, aes256
      dh_group                 = number # 14-24, 31
      ike_version              = optional(number, 2)
      key_lifetime             = optional(number, 28800)
    }), null) # Provide config only if create_ike_policy is true

    # IPSec policy
    create_ipsec_policy      = optional(bool, false)  # Flag to create new IPSec policy
    existing_ipsec_policy_id = optional(string, null) # ID of existing IPSec policy to use (mutually exclusive with create_ipsec_policy)

    ipsec_policy_config = optional(object({
      name                     = string
      encryption_algorithm     = string # aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16
      authentication_algorithm = string # sha256, sha384, sha512, disabled
      pfs                      = string # disabled, group_2, group_5, group_14
      key_lifetime             = optional(number, 3600)
    }), null) # Provide config only if create_ipsec_policy is true

    # Peer and Local Configuration
    peer_config = optional(list(object({
      address = optional(string)
      fqdn    = optional(string)
      cidrs   = optional(list(string), [])
      ike_identity = list(object({
        type  = string
        value = optional(string)
      }))
    })), [])

    local_config = optional(list(object({
      cidrs = optional(list(string), [])
      ike_identities = list(object({
        type  = string
        value = optional(string)
      }))
    })), [])
  }))
  default  = []
  nullable = false

  # Preshared key Validations
  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      length(conn.preshared_key) >= 6 && length(conn.preshared_key) <= 128
    ])
    error_message = "Preshared key must be 6–128 characters long."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      !startswith(conn.preshared_key, "0x") && !startswith(conn.preshared_key, "0s")
    ])
    error_message = "Preshared key should not begin with '0x' or '0s'."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      can(regex("^[-+&!@#$%^*().,:a-zA-Z0-9]+$", conn.preshared_key))
    ])
    error_message = "Preshared key can only contain digits, letters (a-z, A-Z), and these special characters: - + & ! @ # $ % ^ * ( ) . , :"
  }

  # Establish mode Validation
  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      contains(["bidirectional", "peer_only"], conn.establish_mode)
    ])
    error_message = "establish_mode must be either 'bidirectional' or 'peer_only'."
  }

  # DPD (Dead Peer Detection) Validation
  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      contains(["restart", "clear", "hold", "none"], conn.dpd_action)
    ])
    error_message = "Please provide the correct dpd action value. Allowed values are - 'restart', 'clear', 'hold', or 'none'."
  }

  # Peer config Validations
  validation {
    condition = alltrue([
      for conn in var.vpn_connections : alltrue([
        for peer in conn.peer_config :
        (peer.address != null && peer.address != "") || (peer.fqdn != null && peer.fqdn != "")
      ])
    ])
    error_message = "Each peer must have either 'address' or 'fqdn' specified."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections : alltrue([
        for peer in conn.peer_config : alltrue([
          for id in peer.ike_identity : contains(["fqdn", "hostname", "ipv4_address", "key_id"], id.type)
        ])
      ])
    ])
    error_message = "Each peer_config.ike_identity.type must be one of: fqdn, hostname, ipv4_address, key_id."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections : length(conn.peer_config) <= 1
    ])
    error_message = "Only one Peer Configuration is allowed per connection."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections : alltrue([
        for peer in conn.peer_config : alltrue([
          var.vpn_gateway_mode == "route" || (peer.cidrs != null && length(coalesce(peer.cidrs, [])) > 0)
        ])
      ])
    ])
    error_message = "For Policy based VPN, each peer_config must define at least one CIDR."
  }

  # Local config Validations
  validation {
    condition = alltrue([
      for conn in var.vpn_connections : alltrue([
        for member in conn.local_config : alltrue([
          for id in member.ike_identities : contains(["fqdn", "hostname", "ipv4_address", "key_id"], id.type)
        ])
      ])
    ])
    error_message = "Each local_config.ike_identity.type must be one of: fqdn, hostname, ipv4_address, key_id."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections : alltrue([
        for member in conn.local_config : alltrue([
          var.vpn_gateway_mode == "route" ? length(member.ike_identities) == 2 : length(member.ike_identities) <= 1
        ])
      ])
    ])
    error_message = "For Route based VPN gateways, each 'local' entry must have exactly two ike_identities. For policy-based gateways, each 'local' entry may have at most one ike_identity."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections : alltrue([
        for member in conn.local_config : alltrue([
          var.vpn_gateway_mode == "route" || (member.cidrs != null && length(coalesce(member.cidrs, [])) > 0)
        ])
      ])
    ])
    error_message = "For Policy based VPN, each local_config must define at least one CIDR."
  }

  # IKE/IPSec Policies validations

  # Mutually Exclusive validations
  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      !(conn.create_ike_policy && conn.existing_ike_policy_id != null && conn.existing_ike_policy_id != "")
    ])
    error_message = "Please provide either create_ike_policy or an existing_ike_policy_id, but not both for one connection."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      !(conn.create_ipsec_policy && conn.existing_ipsec_policy_id != null && conn.existing_ipsec_policy_id != "")
    ])
    error_message = "Please provide either create_ipsec_policy or an existing_ipsec_policy_id, but not both for one connection."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ike_policy_config != null ? (
        conn.create_ike_policy &&
        conn.ike_policy_config.name != null &&
        conn.ike_policy_config.authentication_algorithm != null &&
        conn.ike_policy_config.encryption_algorithm != null &&
        conn.ike_policy_config.dh_group != null
      ) : (!conn.create_ike_policy && conn.existing_ike_policy_id != null)
    ])
    error_message = "When create_ike_policy=true, ike_policy_config must be provided with all required fields: name, authentication_algorithm, encryption_algorithm, dh_group. If false, use existing IKE Policy Id."
  }

  validation {
    condition = alltrue([
      for conn in var.vpn_connections :
      conn.ipsec_policy_config != null ? (
        conn.create_ipsec_policy &&
        conn.ipsec_policy_config.name != null &&
        conn.ipsec_policy_config.authentication_algorithm != null &&
        conn.ipsec_policy_config.encryption_algorithm != null &&
        conn.ipsec_policy_config.pfs != null
      ) : (!conn.create_ipsec_policy && conn.existing_ipsec_policy_id != null)
    ])
    error_message = "When create_ipsec_policy=true, ipsec_policy_config must be provided with all required fields: name, encryption_algorithm, authentication_algorithm, pfs. If false, use existing IPSec Policy Id."
  }
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
    name                = string
    zone                = string
    destination         = string
    next_hop            = string
    action              = optional(string, "deliver")
    advertise           = optional(bool, false)
    priority            = optional(number, 2)
    vpn_connection_name = optional(string, null)
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
