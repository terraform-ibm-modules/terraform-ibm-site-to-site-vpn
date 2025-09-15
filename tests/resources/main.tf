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
  address_prefix_cidr_1 = "10.100.10.0/24"
  address_prefix_cidr_2 = "192.168.0.0/16"
}

resource "ibm_is_vpc" "test_vpc" {
  count          = var.create_multiple_vpn_gateways ? 2 : 1
  name           = "${var.prefix}-vpc-${count.index + 1}"
  resource_group = module.resource_group.resource_group_id
}

resource "ibm_is_vpc_address_prefix" "prefix" {
  count = var.create_multiple_vpn_gateways ? 2 : 1
  name  = "${var.prefix}-test-${count.index + 1}"
  zone  = "${var.region}-1"
  vpc   = ibm_is_vpc.test_vpc[count.index].id
  cidr  = count.index == 0 ? local.address_prefix_cidr_1 : local.address_prefix_cidr_2
}

resource "ibm_is_subnet" "subnet_zone_1" {
  depends_on = [
    ibm_is_vpc_address_prefix.prefix
  ]
  count           = var.create_multiple_vpn_gateways ? 2 : 1
  resource_group  = module.resource_group.resource_group_id
  name            = "${var.prefix}-subnet-${count.index + 1}"
  vpc             = ibm_is_vpc.test_vpc[count.index].id
  zone            = "${var.region}-1"
  ipv4_cidr_block = count.index == 0 ? local.address_prefix_cidr_1 : local.address_prefix_cidr_2
  tags            = var.resource_tags
}

##############################################################################
# Provision VPN Gateway to serve as remote VPN Gateway
###########################################################################

resource "ibm_is_vpn_gateway" "remote_vpn_gateway" {
  count          = var.create_multiple_vpn_gateways ? 2 : 1
  name           = "${var.prefix}-vpn-gw-${count.index + 1}"
  resource_group = module.resource_group.resource_group_id
  mode           = "route"
  subnet         = ibm_is_subnet.subnet_zone_1[count.index].id
  tags           = var.resource_tags
  timeouts {
    delete = "1h"
  }
}
