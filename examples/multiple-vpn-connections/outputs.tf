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

output "ike_policies" {
  description = "VPN Connection policies information"
  value       = module.vpn_gateway_with_multiple_connections.vpn_connection_policies
}

##############################################################################
# VPN Gateway
##############################################################################

output "vpn_gateway_id" {
  description = "ID of the VPN gateway."
  value       = module.vpn_gateway_with_multiple_connections.vpn_gateway_id
}

output "vpn_gateway_crn" {
  description = "CRN of the VPN gateway."
  value       = module.vpn_gateway_with_multiple_connections.vpn_gateway_crn
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP."
  value       = local.valid_ip_address
}

##############################################################################
# VPN Gateway Connections
##############################################################################

output "vpn_gateway_connection_statuses" {
  description = "VPN Gateway Connection status."
  value       = module.vpn_gateway_with_multiple_connections.vpn_gateway_connection_statuses
}

output "vpn_gateway_connection_ids" {
  description = "Unique identifier of the VPN gateway connections."
  value       = module.vpn_gateway_with_multiple_connections.vpn_gateway_connection_ids
}
##############################################################################
