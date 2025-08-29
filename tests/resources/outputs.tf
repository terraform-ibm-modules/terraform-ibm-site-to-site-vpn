##############################################################################
# Outputs
##############################################################################

output "existing_subnet_id" {
  value       = ibm_is_subnet.subnet_zone_1.id
  description = "The subnet ID."
}

output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "Resource group name."
}

output "vpc_crn" {
  value       = ibm_is_vpc.test_vpc.crn
  description = "VPC CRN."
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP."
  value       = ibm_is_vpn_gateway.remote_vpn_gateway.public_ip_address == "0.0.0.0" ? ibm_is_vpn_gateway.remote_vpn_gateway.public_ip_address2 : ibm_is_vpn_gateway.remote_vpn_gateway.public_ip_address
}
