# VPN Gateway Submodule for IBM Cloud Site-to-Site VPN

##############################################################################
# Provision VPN Gateway
##############################################################################

resource "ibm_is_vpn_gateway" "vpn_gateway" {
  name           = var.vpn_gateway_name
  mode           = var.vpn_gateway_mode
  resource_group = var.resource_group_id
  subnet         = var.subnet_id
  tags           = var.tags
  timeouts {
    delete = "1h"
  }
}