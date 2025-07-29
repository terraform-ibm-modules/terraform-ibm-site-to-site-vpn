# VPN Gateway Connection Submodule for IBM Cloud Site-to-Site VPN

resource "ibm_is_vpn_gateway_connection" "vpn_gw_conn" {
  name               = var.vpn_gateway_connection_name
  admin_state_up     = var.is_admin_state_up
  vpn_gateway        = var.vpn_gateway_id
  preshared_key      = var.preshared_key
  establish_mode     = var.establish_mode
  ike_policy         = var.ike_policy_id
  ipsec_policy       = var.ipsec_policy_id
  distribute_traffic = var.enable_distribute_traffic

  dynamic "peer" {
    for_each = var.peer
    content {
      address = lookup(peer.value, "address", null)
      fqdn    = lookup(peer.value, "fqdn", null)
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
    for_each = var.local
    content {
      dynamic "ike_identities" {
        for_each = local.value.ike_identities
        content {
          type  = ike_identities.value.type
          value = ike_identities.value.value
        }
      }
    }
  }

  # dead peer detection values
  action   = var.dpd_action
  interval = var.dpd_check_interval
  timeout  = var.dpd_max_timeout

  timeouts {
    delete = "1h"
  }

}
