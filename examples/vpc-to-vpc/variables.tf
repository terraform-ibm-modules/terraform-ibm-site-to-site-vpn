########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

variable "region_site_a" {
  type        = string
  description = "IBM Cloud region to provision all resources in Site A."
  default     = "eu-de"
}

variable "region_site_b" {
  type        = string
  description = "IBM Cloud region to provision all resources in Site B."
  default     = "eu-es"
}

variable "prefix" {
  type        = string
  description = "A string value to prefix to all resources created by this example."
  default     = "vpc-to-vpc"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable."
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "List of resource tag to associate with all resource instances created by this example."
  default     = []
}

variable "preshared_key" {
  description = "VPN connection pre-shared key (secret)"
  type        = string
  default     = "somestring"
  sensitive   = true
}
