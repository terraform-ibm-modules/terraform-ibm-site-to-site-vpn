output "vpc_id" {
  description = "VPC ID"
  value       = ibm_is_vpc.vpc.id
}

output "subnet_id" {
  description = "Subnet ID where VPN gateway is attached."
  value       = ibm_is_subnet.subnet_zone_1.id
}

output "ike_policies" {
  description = "IKE policies information"
  value       = module.vpn_gateway_single_site.ike_policy
}

output "ipsec_policies" {
  description = "IPSec policies information"
  value       = module.vpn_gateway_single_site.ipsec_policy
}

output "vpn_gateway_id" {
  description = "ID of the VPN gateway."
  value       = module.vpn_gateway_single_site.vpn_gateway_id
}

output "vpn_gateway_crn_site_a" {
  description = "CRN of the VPN gateway."
  value       = module.vpn_gateway_single_site.vpn_gateway_crn
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP."
  value       = module.vpn_gateway_single_site.vpn_gateway_public_ip
}

output "vpn_gateway_connection_status" {
  description = "VPN Gateway Connection status."
  value       = module.vpn_gateway_single_site.vpn_gateway_connection_status
}

output "vpn_gateway_connection_id" {
  description = "Unique identifier of the VPN gateway connection."
  value       = module.vpn_gateway_single_site.vpn_gateway_connection_id
}

output "vpn_routes" {
  description = "VPN routing information for site."
  value       = module.vpn_gateway_single_site.vpn_routes
}
