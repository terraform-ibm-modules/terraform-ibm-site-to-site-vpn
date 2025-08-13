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
  value       = module.site_to_site_vpn.ike_policy
}

output "ipsec_policies" {
  description = "IPSec policies information"
  value       = module.site_to_site_vpn.ipsec_policy
}
output "vpn_gateways" {
  description = "VPN gateways information."
  value       = module.site_to_site_vpn.vpn_gateway
}

output "vpn_connections" {
  description = "VPN connection information."
  value       = module.site_to_site_vpn.vpn_connections
}
