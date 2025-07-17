locals {
  valid_ike_types = ["fqdn", "hostname", "ipv4_address", "key_id"]
}

resource "ibm_is_vpn_gateway_connection" "vpn_gw_conn" {
  name               = var.vpn_gateway_connection_name
  admin_state_up     = var.is_admin_state_up
  vpn_gateway        = var.vpn_gateway_id
  preshared_key      = var.preshared_key
  establish_mode     = var.establish_mode
  ike_policy         = var.ike_policy_id
  ipsec_policy       = var.ipsec_policy_id
  distribute_traffic = var.enable_distribute_traffic
  peer               = var.peer_config
  local              = var.local_config

  # dead peer detection values
  action   = var.dpd_action
  interval = var.dpd_check_interval
  timeout  = var.dpd_max_timeout
}
