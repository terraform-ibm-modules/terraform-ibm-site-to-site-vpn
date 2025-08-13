##############################################################################
# Site-to-Site VPN Configuration
##############################################################################

locals {

  ike_policy_name   = "${var.prefix}-ike-policy"
  ipsec_policy_name = "${var.prefix}-ipsec-policy"

  vpn_gateway_site_a_name = "${var.prefix}-vpn-gw-site-a"
  vpn_gateway_site_b_name = "${var.prefix}-vpn-gw-site-b"

  vpn_connection_name_site_a   = "${var.prefix}-vpn-conn-a-to-b"
  vpn_connection_name_site_b   = "${var.prefix}-vpn-conn-b-to-a"
  vpn_route_site_a_to_site_b   = "${var.prefix}-route-a-to-b"
  vpn_route_site_b_to_site_a   = "${var.prefix}-route-b-to-a"
  route_table_site_a_to_site_b = "${var.prefix}-a-to-b-rt"
  route_table_site_b_to_site_a = "${var.prefix}-b-to-a-rt"

}

module "vpn_gateway_site_a" {
  source = "../.."
  providers = {
    ibm = ibm.site_a
  }

  resource_group_id              = module.resource_group.resource_group_id
  tags                           = var.resource_tags
  create_vpn_gateway             = true
  vpn_gateway_name               = local.vpn_gateway_site_a_name
  vpn_gateway_subnet_id          = ibm_is_subnet.subnet_site_a.id
  vpn_gateway_mode               = "route"
  create_vpn_policies            = true
  ike_policy_name                = local.ike_policy_name
  ike_authentication_algorithm   = "sha256"
  ike_encryption_algorithm       = "aes256"
  ike_dh_group                   = 14
  ipsec_policy_name              = local.ipsec_policy_name
  ipsec_encryption_algorithm     = "aes256"
  ipsec_authentication_algorithm = "sha256"
  ipsec_pfs                      = "group_14"
}

module "vpn_gateway_site_b" {
  source = "../.."
  providers = {
    ibm = ibm.site_b
  }

  resource_group_id = module.resource_group.resource_group_id
  tags              = var.resource_tags

  create_vpn_gateway             = true
  vpn_gateway_name               = local.vpn_gateway_site_b_name
  vpn_gateway_subnet_id          = ibm_is_subnet.subnet_site_b.id
  vpn_gateway_mode               = "route"
  create_vpn_policies            = true
  ike_policy_name                = local.ike_policy_name
  ike_authentication_algorithm   = "sha256"
  ike_encryption_algorithm       = "aes256"
  ike_dh_group                   = 14
  ipsec_policy_name              = local.ipsec_policy_name
  ipsec_encryption_algorithm     = "aes256"
  ipsec_authentication_algorithm = "sha256"
  ipsec_pfs                      = "group_14"
}

module "site_a_to_site_b" {
  source = "../.."
  providers = {
    ibm = ibm.site_a
  }

  depends_on        = [module.vpn_gateway_site_a, module.vpn_gateway_site_b]
  resource_group_id = module.resource_group.resource_group_id

  create_vpn_gateway      = false
  existing_vpn_gateway_id = module.vpn_gateway_site_a.vpn_gateway_id

  create_vpn_policies      = false
  existing_ike_policy_id   = module.vpn_gateway_site_a.ike_policy_id
  existing_ipsec_policy_id = module.vpn_gateway_site_a.ipsec_policy_id

  # Create connection from A to B
  create_connection = true
  connection_name   = local.vpn_connection_name_site_a
  preshared_key     = var.preshared_key

  peer_config = [
    {
      address = module.vpn_gateway_site_b.vpn_gateway_public_ip
      ike_identity = [
        {
          type  = "ipv4_address"
          value = module.vpn_gateway_site_b.vpn_gateway_public_ip
        }
      ]
    }
  ]

  local_config = [
    {
      ike_identities = [
        {
          type  = "ipv4_address"
          value = module.vpn_gateway_site_a.vpn_gateway_public_ip
        },
        {
          type  = "ipv4_address"
          value = module.vpn_gateway_site_a.vpn_gateway_public_ip
        }
      ]
    }
  ]

  # Routes to Site B networks
  create_routes = true
  vpc_id        = local.vpc_id_site_a
  routes = [
    {
      name             = local.vpn_route_site_a_to_site_b
      vpn_gateway_name = local.vpn_gateway_site_a_name
      zone             = "${var.region_site_a}-1"
      next_hop         = module.vpn_gateway_site_a.vpn_gateway_id
      destination      = local.cidr_block_site_b
    }
  ]

  create_route_table               = true
  accept_routes_from_resource_type = ["vpn_gateway"]
  routing_table_name               = local.route_table_site_a_to_site_b
  attach_subnet                    = true
  subnet_id                        = ibm_is_subnet.subnet_site_a.id
}

module "site_b_to_site_a" {
  source = "../.."
  providers = {
    ibm = ibm.site_b
  }

  depends_on        = [module.vpn_gateway_site_a, module.vpn_gateway_site_b]
  resource_group_id = module.resource_group.resource_group_id

  create_vpn_gateway      = false
  existing_vpn_gateway_id = module.vpn_gateway_site_b.vpn_gateway_id

  # Use existing policies
  create_vpn_policies      = false
  existing_ike_policy_id   = module.vpn_gateway_site_b.ike_policy_id
  existing_ipsec_policy_id = module.vpn_gateway_site_b.ipsec_policy_id

  # Create connection from B to A
  create_connection = true
  connection_name   = local.vpn_connection_name_site_b
  preshared_key     = var.preshared_key

  peer_config = [
    {
      address = module.vpn_gateway_site_a.vpn_gateway_public_ip
      ike_identity = [
        {
          type  = "ipv4_address"
          value = module.vpn_gateway_site_a.vpn_gateway_public_ip
        }
      ]
    }
  ]

  local_config = [
    {
      ike_identities = [
        {
          type  = "ipv4_address"
          value = module.vpn_gateway_site_b.vpn_gateway_public_ip
        },
        {
          type  = "ipv4_address"
          value = module.vpn_gateway_site_b.vpn_gateway_public_ip
        }
      ]
    }
  ]

  # Routes to Site A networks
  create_routes = true
  vpc_id        = local.vpc_id_site_b
  routes = [
    {
      name             = local.vpn_route_site_b_to_site_a
      vpn_gateway_name = local.vpn_gateway_site_b_name
      zone             = "${var.region_site_b}-1"
      next_hop         = module.vpn_gateway_site_b.vpn_gateway_id
      destination      = local.cidr_block_site_a
    }
  ]

  create_route_table               = true
  accept_routes_from_resource_type = ["vpn_gateway"]
  routing_table_name               = local.route_table_site_b_to_site_a
  attach_subnet                    = true
  subnet_id                        = ibm_is_subnet.subnet_site_b.id
}

##############################################################################
# Test Connectivity
##############################################################################

resource "terraform_data" "test_vsi_communication" {
  depends_on = [module.site_a_to_site_b, module.site_b_to_site_a]

  input = {
    public_ip_site_a = ibm_is_floating_ip.floating_ip_vsi_site_a.address
    public_ip_site_b = ibm_is_floating_ip.floating_ip_vsi_site_b.address
    pvt_ip_site_a    = ibm_is_instance.vsi_site_a[0].primary_network_attachment[0].primary_ip[0].address
    pvt_ip_site_b    = ibm_is_instance.vsi_site_b[0].primary_network_attachment[0].primary_ip[0].address
    ssh_key          = tls_private_key.ssh_key.private_key_pem
  }

  provisioner "local-exec" {
    command     = <<EOF
      key_file=$(mktemp)
      echo "${self.input.ssh_key}" > "$key_file"
      chmod 600 "$key_file"
      ./scripts/test_connectivity.sh "${self.input.public_ip_site_a}" "${self.input.public_ip_site_b}" "${self.input.pvt_ip_site_a}" "${self.input.pvt_ip_site_b}" "$key_file"
      rm -f "$key_file"
    EOF
    interpreter = ["/bin/bash", "-c"]
  }
}

##############################################################################
