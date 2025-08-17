##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.3.0"
  existing_resource_group_name = var.resource_group
  providers = {
    ibm = ibm.site_a
  }
}

##############################################################################
# Common Resources across both sites
##############################################################################
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

locals {
  cidr_block_site_a = "10.100.10.0/24"
  cidr_block_site_b = "172.16.10.0/24"
  vsi_profile       = "bx2-2x8"
  vsi_image         = "ibm-ubuntu-22-04-3-minimal-amd64-1"
  vpc_id_site_a     = ibm_is_vpc.vpc_site_a.id
  vpc_id_site_b     = ibm_is_vpc.vpc_site_b.id

  inbound_rules_site_a = [
    {
      protocol = "tcp"
      port_min = 22
      port_max = 22
      remote   = local.cidr_block_site_b
    },
    {
      protocol = "icmp"
      type     = 8
      remote   = local.cidr_block_site_b
    }
  ]

  inbound_rules_site_b = [
    {
      protocol = "tcp"
      port_min = 22
      port_max = 22
      remote   = local.cidr_block_site_a
    },
    {
      protocol = "icmp"
      type     = 8
      remote   = local.cidr_block_site_a
    }
  ]
}

##############################################################################
# SSH Keys
##############################################################################
resource "ibm_is_ssh_key" "public_key_site_a" {
  provider       = ibm.site_a
  name           = "${var.prefix}-key-site-a"
  public_key     = trimspace(tls_private_key.ssh_key.public_key_openssh)
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_ssh_key" "public_key_site_b" {
  provider       = ibm.site_b
  name           = "${var.prefix}-key-site-b"
  public_key     = trimspace(tls_private_key.ssh_key.public_key_openssh)
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

##############################################################################
# VSI Image
##############################################################################
data "ibm_is_image" "image_site_a" {
  provider = ibm.site_a
  name     = local.vsi_image
}

data "ibm_is_image" "image_site_b" {
  provider = ibm.site_b
  name     = local.vsi_image
}

##############################################################################
# VPCs
##############################################################################

resource "ibm_is_vpc" "vpc_site_a" {
  provider       = ibm.site_a
  name           = "${var.prefix}-vpc-site-a"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_vpc" "vpc_site_b" {
  provider       = ibm.site_b
  name           = "${var.prefix}-vpc-site-b"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

##############################################################################
# Address Prefixes
##############################################################################

resource "ibm_is_vpc_address_prefix" "prefix_site_a" {
  provider = ibm.site_a
  name     = "${var.prefix}-prefix-site-a"
  zone     = "${var.region_site_a}-1"
  vpc      = local.vpc_id_site_a
  cidr     = local.cidr_block_site_a
}

resource "ibm_is_vpc_address_prefix" "prefix_site_b" {
  provider = ibm.site_b
  name     = "${var.prefix}-prefix-site-b"
  zone     = "${var.region_site_b}-1"
  vpc      = local.vpc_id_site_b
  cidr     = local.cidr_block_site_b
}

##############################################################################
# Subnets
##############################################################################

resource "ibm_is_subnet" "subnet_site_a" {
  provider        = ibm.site_a
  depends_on      = [ibm_is_vpc_address_prefix.prefix_site_a]
  name            = "${var.prefix}-subnet-site-a"
  vpc             = local.vpc_id_site_a
  zone            = "${var.region_site_a}-1"
  ipv4_cidr_block = local.cidr_block_site_a
  resource_group  = module.resource_group.resource_group_id
  tags            = var.resource_tags
}

resource "ibm_is_subnet" "subnet_site_b" {
  provider = ibm.site_b
  depends_on = [
    ibm_is_vpc_address_prefix.prefix_site_b
  ]
  name            = "${var.prefix}-subnet-site-b"
  vpc             = local.vpc_id_site_b
  zone            = "${var.region_site_b}-1"
  ipv4_cidr_block = local.cidr_block_site_b
  resource_group  = module.resource_group.resource_group_id
  tags            = var.resource_tags
}

##############################################################################
# Security Groups
##############################################################################

resource "ibm_is_security_group" "sg_site_a" {
  provider       = ibm.site_a
  name           = "${var.prefix}-sg-site-a"
  vpc            = local.vpc_id_site_a
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_security_group_rule" "sg_inbound_site_a" {
  provider  = ibm.site_a
  for_each  = { for idx, rule in local.inbound_rules_site_a : idx => rule }
  group     = ibm_is_security_group.sg_site_a.id
  direction = "inbound"
  remote    = each.value.remote

  dynamic "tcp" {
    for_each = each.value.protocol == "tcp" ? [1] : []
    content {
      port_min = each.value.port_min
      port_max = each.value.port_max
    }
  }
  dynamic "icmp" {
    for_each = each.value.protocol == "icmp" ? [1] : []
    content {
      type = each.value.type
    }
  }
}

resource "ibm_is_security_group_rule" "sg_outbound_site_a" {
  provider  = ibm.site_a
  group     = ibm_is_security_group.sg_site_a.id
  direction = "outbound"
  remote    = local.cidr_block_site_b
}

resource "ibm_is_security_group" "sg_site_b" {
  provider       = ibm.site_b
  name           = "${var.prefix}-sg-site-b"
  vpc            = local.vpc_id_site_b
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_security_group_rule" "sg_inbound_site_b" {
  provider  = ibm.site_b
  for_each  = { for idx, rule in local.inbound_rules_site_b : idx => rule }
  group     = ibm_is_security_group.sg_site_b.id
  direction = "inbound"
  remote    = each.value.remote

  dynamic "tcp" {
    for_each = each.value.protocol == "tcp" ? [1] : []
    content {
      port_min = each.value.port_min
      port_max = each.value.port_max
    }
  }
  dynamic "icmp" {
    for_each = each.value.protocol == "icmp" ? [1] : []
    content {
      type = each.value.type
    }
  }
}

resource "ibm_is_security_group_rule" "sg_outbound_site_b" {
  provider  = ibm.site_b
  group     = ibm_is_security_group.sg_site_b.id
  direction = "outbound"
  remote    = local.cidr_block_site_a
}

##############################################################################
# VSIs
##############################################################################

resource "ibm_is_instance" "vsi_site_a" {
  provider = ibm.site_a
  count    = 1
  name     = "${var.prefix}-vsi-site-a"
  image    = data.ibm_is_image.image_site_a.id
  profile  = local.vsi_profile

  primary_network_attachment {
    name = "${var.prefix}-vsi-site-a"
    virtual_network_interface {
      subnet          = ibm_is_subnet.subnet_site_a.id
      security_groups = [ibm_is_security_group.sg_site_a.id]
    }
  }

  vpc            = local.vpc_id_site_a
  resource_group = module.resource_group.resource_group_id
  zone           = "${var.region_site_a}-1"
  keys           = [ibm_is_ssh_key.public_key_site_a.id]
}

resource "ibm_is_instance" "vsi_site_b" {
  provider = ibm.site_b
  count    = 1
  name     = "${var.prefix}-vsi-site-b"
  image    = data.ibm_is_image.image_site_b.id
  profile  = local.vsi_profile

  primary_network_attachment {
    name = "${var.prefix}-vsi-site-b"
    virtual_network_interface {
      subnet          = ibm_is_subnet.subnet_site_b.id
      security_groups = [ibm_is_security_group.sg_site_b.id]
    }
  }

  vpc            = local.vpc_id_site_b
  resource_group = module.resource_group.resource_group_id
  zone           = "${var.region_site_b}-1"
  keys           = [ibm_is_ssh_key.public_key_site_b.id]
}

##############################################################################
# Floating IPs
##############################################################################

resource "ibm_is_floating_ip" "floating_ip_vsi_site_a" {
  provider = ibm.site_a
  name     = "${var.prefix}-fip-site-a"
  target   = ibm_is_instance.vsi_site_a[0].primary_network_attachment[0].virtual_network_interface[0].id
}

resource "ibm_is_floating_ip" "floating_ip_vsi_site_b" {
  provider = ibm.site_b
  name     = "${var.prefix}-fip-site-b"
  target   = ibm_is_instance.vsi_site_b[0].primary_network_attachment[0].virtual_network_interface[0].id
}

##############################################################################
