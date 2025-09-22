##############################################################################
# VPC
##############################################################################
output "vpc_id" {
  description = "VPC ID"
  value       = ibm_is_vpc.vpc.id
}

output "subnet_id" {
  description = "Subnet ID where VPN gateway is attached."
  value       = ibm_is_subnet.subnet_zone_1.id
}

##############################################################################
# Policies
##############################################################################

output "vpn_connection_policies" {
  description = "VPN Connection policies information."
  value       = module.vpn_gateway_single_site.vpn_connection_policies[local.connection_name]
}

##############################################################################
# VPN Gateway
##############################################################################
output "vpn_gateway_id" {
  description = "ID of the VPN gateway."
  value       = module.vpn_gateway_single_site.vpn_gateway_id
}

output "vpn_gateway_crn" {
  description = "CRN of the VPN gateway."
  value       = module.vpn_gateway_single_site.vpn_gateway_crn
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP."
  value       = local.valid_ip_address
}

##############################################################################
# VPN Gateway Connection
##############################################################################
output "vpn_gateway_connection_status" {
  description = "VPN Gateway Connection status."
  value       = module.vpn_gateway_single_site.vpn_gateway_connection_statuses[local.connection_name]
}

output "vpn_gateway_connection_id" {
  description = "Unique identifier of the VPN gateway connection."
  value       = module.vpn_gateway_single_site.vpn_gateway_connection_ids[local.connection_name]
}

output "vpn_gateway_connection_mode" {
  description = "VPN gateway connection mode."
  value       = module.vpn_gateway_single_site.vpn_gateway_connection_modes[local.connection_name]
}
##############################################################################
