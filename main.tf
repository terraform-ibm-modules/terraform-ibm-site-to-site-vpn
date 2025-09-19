##############################################################################
# VPN Policies (IPSec and IKE)
##############################################################################

module "vpn_policies" {

  count          = length([for conn in var.vpn_connections : conn if conn.create_ike_policy || conn.create_ipsec_policy]) > 0 ? 1 : 0
  source         = "./modules/vpn_policies"
  resource_group = var.resource_group_id
  vpn_connections = [
    for conn in var.vpn_connections : {
      name = conn.name

      # IKE Policy
      create_ike_policy = conn.create_ike_policy
      ike_policy_config = conn.create_ike_policy ? {
        name                     = conn.ike_policy_config.name
        authentication_algorithm = conn.ike_policy_config.authentication_algorithm
        encryption_algorithm     = conn.ike_policy_config.encryption_algorithm
        dh_group                 = conn.ike_policy_config.dh_group
        version                  = conn.ike_policy_config.ike_version
        key_lifetime             = conn.ike_policy_config.key_lifetime
      } : null

      # IPSec Policy
      create_ipsec_policy = conn.create_ipsec_policy
      ipsec_policy_config = conn.create_ipsec_policy ? {
        name                     = conn.ipsec_policy_config.name
        encryption_algorithm     = conn.ipsec_policy_config.encryption_algorithm
        authentication_algorithm = conn.ipsec_policy_config.authentication_algorithm
        pfs                      = conn.ipsec_policy_config.pfs
        key_lifetime             = conn.ipsec_policy_config.key_lifetime
      } : null
    }
  ]
}

##############################################################################
# VPN Gateway
##############################################################################

resource "ibm_is_vpn_gateway" "vpn_gateway" {
  count          = var.create_vpn_gateway ? 1 : 0
  name           = var.vpn_gateway_name
  resource_group = var.resource_group_id
  mode           = var.vpn_gateway_mode
  subnet         = var.vpn_gateway_subnet_id
  tags           = var.tags
  timeouts {
    create = "1h"
    delete = "1h"
  }
}

resource "time_sleep" "wait_for_gateway_creation" {
  count           = var.create_vpn_gateway ? 1 : 0
  depends_on      = [ibm_is_vpn_gateway.vpn_gateway]
  create_duration = "30s"
}

##############################################################################
# Site to Site VPN Gateway Connection
##############################################################################

locals {

  vpn_gateway_id = (
    var.create_vpn_gateway ? ibm_is_vpn_gateway.vpn_gateway[0].id :
    var.existing_vpn_gateway_id != null ? var.existing_vpn_gateway_id : null
  )

  connection_policies = {
    for conn in var.vpn_connections : conn.name => {
      ike_policy_id   = conn.create_ike_policy ? module.vpn_policies[0].ike_policy_ids[conn.name] : conn.existing_ike_policy_id
      ipsec_policy_id = conn.create_ipsec_policy ? module.vpn_policies[0].ipsec_policy_ids[conn.name] : conn.existing_ipsec_policy_id
    }
  }
}

resource "ibm_is_vpn_gateway_connection" "vpn_site_to_site_connection" {
  depends_on         = [module.vpn_policies, time_sleep.wait_for_gateway_creation]
  for_each           = { for conn in var.vpn_connections : conn.name => conn }
  vpn_gateway        = local.vpn_gateway_id
  ike_policy         = local.connection_policies[each.key].ike_policy_id
  ipsec_policy       = local.connection_policies[each.key].ipsec_policy_id
  name               = each.key
  admin_state_up     = each.value.is_admin_state_up
  preshared_key      = sensitive(each.value.preshared_key)
  establish_mode     = each.value.establish_mode
  distribute_traffic = var.vpn_gateway_mode == "route" ? each.value.enable_distribute_traffic : false

  dynamic "peer" {
    for_each = each.value.peer_config
    content {
      address = peer.value.address
      fqdn    = peer.value.fqdn
      cidrs   = peer.value.cidrs
      dynamic "ike_identity" {
        for_each = peer.value.ike_identity
        content {
          type  = ike_identity.value.type
          value = ike_identity.value.value
        }
      }
    }
  }

  dynamic "local" {
    for_each = each.value.local_config
    content {
      cidrs = local.value.cidrs
      dynamic "ike_identities" {
        for_each = distinct(local.value.ike_identities)
        content {
          type  = ike_identities.value.type
          value = ike_identities.value.value
        }
      }
    }
  }

  # DPD settings
  action   = each.value.dpd_action
  interval = each.value.dpd_check_interval
  timeout  = each.value.dpd_max_timeout

  timeouts {
    delete = "1h"
  }
}

##############################################################################
# VPC Routing Table and VPN Routes
##############################################################################

locals {
  vpn_connection_ids = {
    for k, v in ibm_is_vpn_gateway_connection.vpn_site_to_site_connection : k => v.gateway_connection
  }
}

module "vpn_routes" {
  count                   = var.create_routes ? 1 : 0
  depends_on              = [ibm_is_vpn_gateway_connection.vpn_site_to_site_connection]
  source                  = "./modules/vpn_routing"
  vpc_id                  = var.vpc_id
  existing_route_table_id = var.existing_route_table_id
  create_route_table      = var.create_route_table
  routing_table_name      = var.routing_table_name
  route_attach_subnet     = var.route_attach_subnet
  subnet_id_to_attach     = var.route_subnet_id
  vpn_gateway_mode        = var.vpn_gateway_mode
  vpn_connection_ids      = local.vpn_connection_ids

  vpn_routes = [
    for route in var.routes : {
      name                = route.name
      zone                = route.zone
      destination         = route.destination
      action              = route.action
      advertise           = route.advertise
      priority            = route.priority
      next_hop            = route.next_hop
      vpn_connection_name = lookup(route, "vpn_connection_name", null)
    }
  ]

  existing_routes = []

  # Routing table configuration
  accept_routes_from_resource_type = var.accept_routes_from_resource_type
  advertise_routes_to              = var.advertise_routes_to
  route_direct_link_ingress        = var.route_direct_link_ingress
  route_transit_gateway_ingress    = var.route_transit_gateway_ingress
  route_vpc_zone_ingress           = var.route_vpc_zone_ingress
  route_internet_ingress           = var.route_internet_ingress
  tags                             = var.tags
}
