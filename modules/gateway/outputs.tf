##############################################################################
# Outputs
##############################################################################

output "vpn_gateway_name" {
  description = "The name of the VPN gateway."
  value       = ibm_is_vpn_gateway.vpn_gateway.name
}

output "vpn_gateway_id" {
  description = "ID of the VPN gateway."
  value       = ibm_is_vpn_gateway.vpn_gateway.id
}

output "vpn_gateway_crn" {
  description = "CRN of the VPN gateway."
  value       = ibm_is_vpn_gateway.vpn_gateway.crn
}

output "vpn_gateway_primary_ip" {
  description = "Resolved public IP address from either `public_ip_address` or `public_ip_address2`. [Learn more](https://registry.terraform.io/providers/IBM-cloud/ibm/1.80.4/docs/resources/is_vpn_gateway#public_ip_address2-4)"
  value       = ibm_is_vpn_gateway.vpn_gateway.public_ip_address == "0.0.0.0" ? ibm_is_vpn_gateway.vpn_gateway.public_ip_address2 : ibm_is_vpn_gateway.vpn_gateway.public_ip_address
}

output "vpn_gateway_members" {
  description = "List of VPN gateway members."
  value = [
    for member in ibm_is_vpn_gateway.vpn_gateway.members : {
      address         = member.address
      private_address = member.private_address
      role            = member.role
    }
  ]
}

output "vpn_gateway_status" {
  description = "Overall health state of the VPN gateway. Refer [here](https://registry.terraform.io/providers/IBM-cloud/ibm/1.80.4/docs/resources/is_vpn_gateway#health_state-4) for more information."
  value       = ibm_is_vpn_gateway.vpn_gateway.health_state
}

output "vpn_gateway_vpc_info" {
  description = "Information about the VPC associated with the VPN gateway."
  value       = ibm_is_vpn_gateway.vpn_gateway.vpc
}

##############################################################################
