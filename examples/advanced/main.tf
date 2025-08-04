##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Common Resources across both sites
##############################################################################

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "ibm_is_ssh_key" "public_key" {
  name           = "${var.prefix}-key"
  public_key     = trimspace(tls_private_key.ssh_key.public_key_openssh)
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

data "ibm_is_image" "image" {
  name = "ibm-ubuntu-22-04-3-minimal-amd64-1"
}

locals {
  cidr_block_site_a = "10.100.10.0/24"
  cidr_block_site_b = "172.16.10.0/24"
  vsi_profile       = "bx2-2x8"
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
  group     = ibm_is_security_group.sg_site_b.id
  direction = "outbound"
  remote    = local.cidr_block_site_b
}

# SGs for Site B follows heree

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
  group     = ibm_is_security_group.sg_site_a.id
  direction = "outbound"
  remote    = local.cidr_block_site_a
}

##############################################################################
# VSIs
##############################################################################

resource "ibm_is_instance" "vsi_site_a" {
  provider = ibm.site_a
  count    = 1
  name     = "${var.prefix}-vsi-site-a-${count.index}"
  image    = data.ibm_is_image.image.id
  profile  = local.vsi_profile

  primary_network_attachment {
    name = "${var.prefix}-vsi-site-a-${count.index}"
    virtual_network_interface {
      subnet          = ibm_is_subnet.subnet_site_a.id
      security_groups = [ibm_is_security_group.sg_site_a.id]
    }
  }

  vpc            = local.vpc_id_site_a
  resource_group = module.resource_group.resource_group_id
  zone           = "${var.region_site_a}-1"
  keys           = [ibm_is_ssh_key.public_key.id]
}

resource "ibm_is_instance" "vsi_site_b" {
  provider = ibm.site_b
  count    = 1
  name     = "${var.prefix}-vsi-site-b-${count.index}"
  image    = data.ibm_is_image.image.id
  profile  = local.vsi_profile

  primary_network_attachment {
    name = "${var.prefix}-vsi-site-b-${count.index}"
    virtual_network_interface {
      subnet          = ibm_is_subnet.subnet_site_b.id
      security_groups = [ibm_is_security_group.sg_site_b.id]
    }
  }

  vpc            = local.vpc_id_site_b
  resource_group = module.resource_group.resource_group_id
  zone           = "${var.region_site_b}-1"
  keys           = [ibm_is_ssh_key.public_key.id]
}

##############################################################################
# Site-to-Site VPN
##############################################################################

locals {
  # Common policies to be used for both sites
  ike_policy_name   = "${var.prefix}-ike-policy"
  ipsec_policy_name = "${var.prefix}-ipsec-policy"
  ike_policy_map    = { for policy in module.site_to_site_vpn.ike_policies : policy.name => policy }
  ipsec_policy_map  = { for policy in module.site_to_site_vpn.ipsec_policies : policy.name => policy }

  # Site A related configuration
  vpn_gateway_site_a_name = "${var.prefix}-vpn-gw-site-a"
  vpn_gateway_site_a_map  = { for gw in module.site_to_site_vpn.vpn_gateways : gw.vpn_gateway_site_a_name => gw }
  vpn_gateway_site_a_id   = local.vpn_gateway_site_a_map[local.vpn_gateway_site_a_name].id
  vpn_gateway_site_a_ip   = module.site_to_site_vpn.vpn_gateways[local.vpn_gateway_site_a_name].public_ip_address

  # Site B related configuration
  vpn_gateway_site_b_name = "${var.prefix}-vpn-gw-site-b"
  vpn_gateway_site_b_map  = { for gw in module.site_to_site_vpn.vpn_gateways : gw.vpn_gateway_site_b_name => gw }
  vpn_gateway_site_b_id   = local.vpn_gateway_site_b_map[local.vpn_gateway_site_b_name].id
  vpn_gateway_site_b_ip   = module.site_to_site_vpn.vpn_gateways[local.vpn_gateway_site_b_name].public_ip_address
}

locals {
  vpn_gateways = [
    {
      name      = local.vpn_gateway_site_a_name
      subnet_id = ibm_is_subnet.subnet_site_a.id
      mode      = "route"
    },
    {
      name      = local.vpn_gateway_site_b_name
      subnet_id = ibm_is_subnet.subnet_site_b.id
      mode      = "route"
    }
  ]

  ike_policies = [{
    name                     = local.ike_policy_name
    encryption_algorithm     = "aes256"
    authentication_algorithm = "sha256"
    dh_group                 = 14
  }]

  ipsec_policies = [{
    name                     = local.ipsec_policy_name
    encryption_algorithm     = "aes256"
    authentication_algorithm = "sha256"
    pfs                      = "group_14"
  }]

  vpn_connections = [
    # Site A to Site B connection
    {
      vpn_gateway_connection_name = "${var.prefix}-vpn-conn-a-to-b"
      vpn_gateway_site_a_name     = local.vpn_gateway_site_a_name
      vpn_gateway_site_a_id       = local.vpn_gateway_site_a_id
      preshared_key               = var.preshared_key
      ike_policy_id               = local.ike_policy_map[local.ike_policy_name].id
      ipsec_policy_id             = local.ipsec_policy_map[local.ipsec_policy_name].id

      peer = [
        {
          address = local.vpn_gateway_site_b_ip
          ike_identity = [
            {
              type  = "ipv4_address"
              value = local.vpn_gateway_site_b_ip
          }]
      }]

      local = [
        {
          ike_identities = [
            {
              type  = "ipv4_address"
              value = local.vpn_gateway_site_a_ip
          }]
      }]
    },
    # Site B to Site A connection
    {
      vpn_gateway_connection_name = "${var.prefix}-vpn-conn-b-to-a"
      vpn_gateway_site_a_name     = local.vpn_gateway_site_b_name
      vpn_gateway_site_a_id       = local.vpn_gateway_site_b_id
      preshared_key               = var.preshared_key
      ike_policy_id               = local.ike_policy_map[local.ike_policy_name].id
      ipsec_policy_id             = local.ipsec_policy_map[local.ipsec_policy_name].id

      peer = [
        {
          address = local.vpn_gateway_site_a_ip
          ike_identity = [
            {
              type  = "ipv4_address"
              value = local.vpn_gateway_site_a_ip
          }]
      }]

      local = [
        {
          ike_identities = [
            {
              type  = "ipv4_address"
              value = local.vpn_gateway_site_b_ip
          }]
      }]
    }
  ]

  # VPN ROUTES
  vpn_routes = [
    # Route from Site A to Site B
    {
      name             = "${var.prefix}-route-site-a-to-site-b"
      vpn_gateway_name = local.vpn_gateway_site_a_name
      zone             = "${var.region_site_a}-1"
      next_hop         = local.vpn_gateway_site_a_id
      vpc_id           = local.vpc_id_site_a
      destination      = local.cidr_block_site_b
    },
    # Route from Site B to Site A
    {
      name             = "${var.prefix}-route-site-b-to-site-a"
      vpn_gateway_name = local.vpn_gateway_site_b_name
      zone             = "${var.region_site_b}-1"
      next_hop         = local.vpn_gateway_site_b_id
      vpc_id           = local.vpc_id_site_b
      destination      = local.cidr_block_site_a
    }
  ]
}

module "site_to_site_vpn" {
  source            = "../.."
  region            = var.region_site_a
  resource_group_id = module.resource_group.resource_group_id
  tags              = var.resource_tags

  ike_policies   = local.ike_policies
  ipsec_policies = local.ipsec_policies

  vpn_gateways    = local.vpn_gateways
  vpn_connections = local.vpn_connections

  vpn_routes                       = local.vpn_routes
  create_route_table               = true
  accept_routes_from_resource_type = ["vpn_gateway"]
  route_vpc_zone_ingress           = true
}

##############################################################################
# Test Connectivity
##############################################################################

resource "terraform_data" "test_vsi_communication" {

  input = {
    ip_addr_site_a = module.site_to_site_vpn.vsi_private_ip_site_a
    ip_addr_site_b = module.site_to_site_vpn.vsi_private_ip_site_b
    ssh_key        = tls_private_key.ssh_key.private_key_pem
  }

  provisioner "local-exec" {
    command     = "./scripts/test_connectivity.s ${self.input.ip_addr_site_a} ${self.input.ip_addr_site_b} ${self.input.ssh_key}"
    interpreter = ["/bin/bash", "-c"]
  }
}
