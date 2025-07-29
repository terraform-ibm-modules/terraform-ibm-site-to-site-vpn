variable "vpn_gateway_id" {
  description = "ID of the VPN gateway"
  type        = string
}

variable "vpn_gateway_connection_name" {
  description = "Name of the VPN gateway connection."
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

variable "peer" {
  description = "Optional configuration for the remote peer VPN gateway. Includes peer address/FQDN, IKE identity type, and optional identity value."
  type = list(object({
    address = optional(string)
    fqdn    = optional(string)
    ike_identity = list(object({
      type  = string
      value = optional(string)
    }))
  }))
  default = []
  validation {
    condition = length(var.peer) == 0 || alltrue([
      for peer in var.peer : alltrue([
        for id in peer.ike_identity : contains(["fqdn", "hostname",
        "ipv4_address", "key_id"], id.type)
      ])
    ])
    error_message = "Each ike_identity 'type' must be one of: fqdn, hostname, ipv4_address, or key_id."
  }

  validation {
    condition = length(var.peer) == 0 || alltrue([
      for peer in var.peer : (peer.address != null && peer.address != "") || (peer.fqdn != null && peer.fqdn != "")
    ])
    error_message = "Each peer must have either 'address' or 'fqdn' specified."
  }
}

variable "local" {
  description = "Optional configuration for local IKE identities. Each entry in the list represents a VPN gateway member in active-active mode, containing one or more IKE identities."
  type = list(object({
    ike_identities = list(object({
      type  = string
      value = optional(string)
    }))
  }))
  default = []
  validation {
    condition = length(var.local) == 0 || alltrue([
      for member in var.local : alltrue([
        for id in member.ike_identities : contains(["fqdn", "hostname",
        "ipv4_address", "key_id"], id.type)
      ])
    ])
    error_message = "Each ike_identity 'type' must be one of: fqdn, hostname, ipv4_address, or key_id."
  }
}

variable "is_admin_state_up" {
  description = "Optional flag to control the administrative state of the VPN gateway connection. If set to false (default), the connection is shut down. Set to true to enable the connection."
  type        = bool
  default     = false
}

####################################################
# Policies
####################################################

variable "ike_policy_id" {
  description = "ID of the IKE policy to associate with the VPN gateway. Leave empty ('') or null to remove the existing policy."
  type        = string
  default     = null
}

variable "ipsec_policy_id" {
  description = "ID of the IPsec policy to associate with the VPN gateway. Leave empty ('') or null to remove the existing policy."
  type        = string
  default     = null
}

####################################################
# DPD (Dead Peer Detection)
####################################################

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

########################################################################################################
