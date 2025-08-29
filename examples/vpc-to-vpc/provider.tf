##############################################################################
# Provider config
##############################################################################

provider "ibm" {
  alias            = "site_a"
  region           = var.region_site_a
  ibmcloud_api_key = var.ibmcloud_api_key
}

provider "ibm" {
  alias            = "site_b"
  region           = var.region_site_b
  ibmcloud_api_key = var.ibmcloud_api_key
}
