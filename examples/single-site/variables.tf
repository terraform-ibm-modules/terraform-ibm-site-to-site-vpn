variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix for all resources created by this example."
  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "region" {
  type        = string
  description = "Region where resources are created."
}

variable "tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "preshared_key" {
  description = "VPN connection pre-shared key (secret)"
  type        = string
  sensitive   = true
}

variable "remote_gateway_ip" {
  type        = string
  description = "An existing remote VPN gateway IP to connect with."
}

variable "remote_cidr" {
  type        = string
  description = "An existing destination CIDR to create route from VPN."
}
