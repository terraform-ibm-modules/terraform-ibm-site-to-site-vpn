########################################################################################################################
# Input variables - Simplified for testing
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable."
  default     = null
}

variable "prefix" {
  type        = string
  description = "A string value to prefix to all resources created by this example."
  default     = "test-existing-gw"
}

variable "existing_vpn_gateway_region" {
  type        = string
  description = "Region where the public gateway is located."
}

variable "existing_vpn_gateway_id" {
  type        = string
  description = "ID of the existing VPN gateway to add the new connection to."
}

variable "preshared_key" {
  description = "VPN connection pre-shared key (secret) for the new connection"
  type        = string
  default     = "test-preshared-key-123"
  sensitive   = true
}

variable "local_gateway_ip" {
  type        = string
  description = "Public IP address of the existing VPN gateway."
  default     = "1.2.3.4" # Placeholder - user should replace with actual IP
}

variable "local_gateway_secondary_ip" {
  type        = string
  description = "Secondary Public IP address of the existing VPN gateway."
  default     = "1.2.3.4" # Placeholder - user should replace with actual IP
}

variable "remote_site_c_ip" {
  type        = string
  description = "Public IP address of the remote site C VPN gateway."
  default     = "203.0.113.50"
}

variable "existing_ike_policy_id" {
  type        = string
  description = "ID of the existing IKE policy to add to VPN Connection."
}

variable "existing_ipsec_policy_id" {
  type        = string
  description = "ID of the existing IPSec policy to add to VPN Connection."
}
