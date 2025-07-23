locals {
  # Convert the vpn inputs from list to a map
  vpn_gateway_map     = { for gateway in var.vpn_gateways : gateway.name => gateway }
  vpn_connections_map = { for conn in var.vpn_connections : conn.vpn_gateway_connection_name => conn }
  ike_policy_map      = { for ike_policy in var.ike_policies : ike_policy.name => ike_policy }
  ipsec_policy_map    = { for ipsec_policy in var.ipsec_policies : ipsec_policy.name => ipsec_policy }
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.1"
  existing_resource_group_name = var.existing_resource_group_name
}

##############################################################################
# IPSec and IKE Policies
##############################################################################

module "ike_policies" {
  source                       = "./modules/vpn_policies/ike_policy"
  for_each                     = local.ike_policy_map
  resource_group_id            = module.resource_group.resource_group_id
  ike_policy_name              = each.value.name
  ike_version                  = each.value.ike_version
  ike_encryption_algorithm     = each.value.encryption_algorithm
  ike_authentication_algorithm = each.value.authentication_algorithm
  ike_dh_group                 = each.value.dh_group
  ike_key_lifetime             = each.value.key_lifetime
}

module "ipsec_policies" {
  source                         = "./modules/vpn_policies/ipsec_policy"
  for_each                       = local.ipsec_policy_map
  resource_group_id              = module.resource_group.resource_group_id
  ipsec_policy_name              = each.value.name
  ipsec_encryption_algorithm     = each.value.encryption_algorithm
  ipsec_authentication_algorithm = each.value.authentication_algorithm
  ipsec_pfs                      = each.value.pfs
  ipsec_key_lifetime             = each.value.key_lifetime
}

##############################################################################
# VPN Gateways
##############################################################################

# data "ibm_is_vpn_gateway" "existing_vpn_gateway" {
#   count = var.use_existing_vpn_gateway? 1: 0
#   vpn_gateway_name = var.existing_vpn_gateway_name
# }

module "vpn_gateway" {
  source            = "./modules/gateway"
  for_each          = local.vpn_gateway_map
  resource_group_id = module.resource_group.resource_group_id
  vpn_gateway_name  = each.key
  vpn_gateway_mode  = each.value.mode
  subnet_id         = each.value.subnet_id
  tags              = var.tags
}

##############################################################################
# VPN Gateway Connections
##############################################################################

module "vpn_connections" {
  source                      = "./modules/gateway_connection"
  for_each                    = local.vpn_connections_map
  vpn_gateway_connection_name = each.key
  vpn_gateway_id              = var.use_existing_vpn_gateway ? each.value.vpn_gateway_id : module.vpn_gateway.vpn_gateway_id
  preshared_key               = each.value.preshared_key
  establish_mode              = each.value.establish_mode
  is_admin_state_up           = each.value.is_admin_state_up
  enable_distribute_traffic   = each.value.enable_distribute_traffic
  ike_policy_id               = var.use_existing_ike_policies ? each.value.ike_policy_id : module.ike_policies.ike_policy_id
  ipsec_policy_id             = var.use_existing_ipsec_policies ? each.value.ipsec_policy_id : module.ipsec_policies.ipsec_policy_id
  peer_config                 = each.value.peer_config
  local_config                = each.value.local_config
  dpd_action                  = each.value.dpd_action
  dpd_check_interval          = each.value.dpd_check_interval
  dpd_max_timeout             = each.value.dpd_max_timeout
}
