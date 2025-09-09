################################################################################
# Resource Group
################################################################################
module "resource_group" {
  source              = "terraform-ibm-modules/resource-group/ibm"
  version             = "1.3.0"
  resource_group_name = "${var.prefix}-rg"
}

##############################################################################
# Provision VPC
##############################################################################

locals {
  address_prefix_cidr = "10.100.10.0/24"
}

resource "ibm_is_vpc" "test_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
}

resource "ibm_is_vpc_address_prefix" "prefix" {
  name = "${var.prefix}-prefix"
  zone = "${var.region}-1"
  vpc  = ibm_is_vpc.test_vpc.id
  cidr = local.address_prefix_cidr
}

resource "ibm_is_subnet" "subnet_zone_1" {
  depends_on = [
    ibm_is_vpc_address_prefix.prefix
  ]
  resource_group  = module.resource_group.resource_group_id
  name            = "${var.prefix}-subnet-1"
  vpc             = ibm_is_vpc.test_vpc.id
  zone            = "${var.region}-1"
  ipv4_cidr_block = local.address_prefix_cidr
  tags            = var.resource_tags
}

##############################################################################
# Provision VPN Gateway to serve as remote VPN Gateway
###########################################################################

resource "ibm_is_vpn_gateway" "remote_vpn_gateway" {
  name           = "${var.prefix}-vpn-gw"
  resource_group = module.resource_group.resource_group_id
  mode           = "route"
  subnet         = ibm_is_subnet.subnet_zone_1.id
  tags           = var.resource_tags
  timeouts {
    delete = "1h"
  }
}
