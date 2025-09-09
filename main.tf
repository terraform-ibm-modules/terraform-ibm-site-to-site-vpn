##############################################################################
# VPN Policies (IPSec and IKE)
##############################################################################

module "vpn_policies" {
  count                          = var.create_vpn_policies ? 1 : 0
  source                         = "./modules/vpn_policies"
  resource_group                 = var.resource_group_id
  ike_policy_name                = var.ike_policy_name
  ike_authentication_algorithm   = var.ike_authentication_algorithm
  ike_encryption_algorithm       = var.ike_encryption_algorithm
  ike_dh_group                   = var.ike_dh_group
  ike_version                    = var.ike_version
  ike_key_lifetime               = var.ike_key_lifetime
  ipsec_policy_name              = var.ipsec_policy_name
  ipsec_encryption_algorithm     = var.ipsec_encryption_algorithm
  ipsec_authentication_algorithm = var.ipsec_authentication_algorithm
  ipsec_pfs                      = var.ipsec_pfs
  ipsec_key_lifetime             = var.ipsec_key_lifetime
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

  ike_policy_id = (
    var.create_vpn_policies ? module.vpn_policies[0].ike_policy_id :
    var.existing_ike_policy_id != null ? var.existing_ike_policy_id : null
  )

  ipsec_policy_id = (
    var.create_vpn_policies ? module.vpn_policies[0].ipsec_policy_id :
    var.existing_ipsec_policy_id != null ? var.existing_ipsec_policy_id : null
  )
}

resource "ibm_is_vpn_gateway_connection" "vpn_site_to_site_connection" {
  depends_on         = [module.vpn_policies, time_sleep.wait_for_gateway_creation]
  name               = var.vpn_gateway_connection_name
  admin_state_up     = var.is_admin_state_up
  vpn_gateway        = local.vpn_gateway_id
  preshared_key      = var.preshared_key
  establish_mode     = var.establish_mode
  ike_policy         = local.ike_policy_id
  ipsec_policy       = local.ipsec_policy_id
  distribute_traffic = var.vpn_gateway_mode == "route" ? var.enable_distribute_traffic : false

  dynamic "peer" {
    for_each = var.peer_config
    content {
      address = lookup(peer.value, "address", null)
      fqdn    = lookup(peer.value, "fqdn", null)
      cidrs   = lookup(peer.value, "cidrs", [])
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
    for_each = var.local_config
    content {
      cidrs = local.value.cidrs
      dynamic "ike_identities" {
        for_each = local.value.ike_identities
        content {
          type  = ike_identities.value.type
          value = ike_identities.value.value
        }
      }
    }
  }

  # DPD settings
  action   = var.dpd_action
  interval = var.dpd_check_interval
  timeout  = var.dpd_max_timeout

  timeouts {
    delete = "1h"
  }

}

##############################################################################
# VPC Routing Table and VPN Routes
##############################################################################

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
  vpn_routes = [
    for route in var.routes : {
      name        = route.name
      zone        = route.zone
      destination = route.destination
      action      = route.action
      advertise   = route.advertise
      priority    = route.priority
      next_hop    = route.next_hop
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
