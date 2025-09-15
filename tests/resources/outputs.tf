##############################################################################
# Outputs
##############################################################################

output "existing_subnet_id" {
  value       = ibm_is_subnet.subnet_zone_1.id
  description = "The subnet ID."
}

output "existing_subnet_id_2" {
  description = "Subnet ID for the second VPN gateway, if created."
  value       = var.create_multiple_vpn_gateways ? ibm_is_subnet.subnet_zone_1[1].id : null
}

output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "Resource group name."
}

output "vpc_crn" {
  value       = ibm_is_vpc.test_vpc[0].crn
  description = "VPC CRN."
}

output "vpc_crn_2" {
  description = "CRN of the second VPC, if created."
  value       = var.create_multiple_vpn_gateways ? ibm_is_vpc.test_vpc[1].crn : null
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP."
  value       = ibm_is_vpn_gateway.remote_vpn_gateway[0].public_ip_address == "0.0.0.0" ? ibm_is_vpn_gateway.remote_vpn_gateway[0].public_ip_address2 : ibm_is_vpn_gateway.remote_vpn_gateway[0].public_ip_address
}

output "vpn_gateway_public_ip_2" {
  description = "VPN Gateway public IP for second VPN."
  value       = var.create_multiple_vpn_gateways ? (ibm_is_vpn_gateway.remote_vpn_gateway[1].public_ip_address == "0.0.0.0" ? ibm_is_vpn_gateway.remote_vpn_gateway[1].public_ip_address2 : ibm_is_vpn_gateway.remote_vpn_gateway[1].public_ip_address) : null
}

output "remote_cidr" {
  description = "Remote CIDR to be used."
  value       = local.address_prefix_cidr_1
}

output "remote_cidr_2" {
  description = "CIDR for second VPN gateway (if created)."
  value       = var.create_multiple_vpn_gateways ? local.address_prefix_cidr_2 : null
}
