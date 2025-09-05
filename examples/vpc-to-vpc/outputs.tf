# ########################################################################################################################
# # Outputs
# ########################################################################################################################



output "vpc_id_site_a" {
  description = "VPC ID of Site A."
  value       = local.vpc_id_site_a
}

output "vpc_id_site_b" {
  description = "VPC ID of Site B."
  value       = local.vpc_id_site_b
}

output "vsi_private_ip_site_a" {
  description = "Site A VSI private IP"
  value       = ibm_is_instance.vsi_site_a[0].primary_network_attachment[0].primary_ip[0].address
}

output "vsi_private_ip_site_b" {
  description = "Site B VSI private IP"
  value       = ibm_is_instance.vsi_site_b[0].primary_network_attachment[0].primary_ip[0].address
}

output "vpn_gateway_ips" {
  description = "VPN Gateway public IPs."
  value = {
    site_a = module.vpn_gateway_site_a.vpn_gateway_public_ip
    site_b = module.vpn_gateway_site_b.vpn_gateway_public_ip
  }
}

output "vpn_connections_status_site_a" {
  description = "VPN connections status for Site A"
  value       = module.vpn_gateway_site_a.vpn_gateway_connection_status
}

output "vpn_connections_status_site_b" {
  description = "VPN connections status for Site B"
  value       = module.vpn_gateway_site_b.vpn_gateway_connection_status
}

output "floating_ip_address_site_a" {
  description = "Public Floating IP address of the VSI for site A."
  value       = ibm_is_floating_ip.floating_ip_vsi_site_a.address
}

output "floating_ip_address_site_b" {
  description = "Public Floating IP address of the VSI for site B."
  value       = ibm_is_floating_ip.floating_ip_vsi_site_b.address
}

output "vpn_routes_site_a" {
  description = "VPN routing information for site A."
  value       = module.vpn_gateway_site_a.vpn_routes
}

output "vpn_routes_site_b" {
  description = "VPN routing information for site B."
  value       = module.vpn_gateway_site_b.vpn_routes
}

output "private_key" {
  description = "Commonly used SSH private key for both the sites."
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "vpn_gateway_id_side_a" {
  description = "ID of the VPN gateway."
  value       = module.vpn_gateway_site_a.vpn_gateway_id
}

output "vpn_gateway_id_side_b" {
  description = "CRN of the VPN gateway."
  value       = module.vpn_gateway_site_b.vpn_gateway_id
}

output "vpn_gateway_crn_side_a" {
  description = "ID of the VPN gateway."
  value       = module.vpn_gateway_site_a.vpn_gateway_crn
}

output "vpn_gateway_crn_side_b" {
  description = "CRN of the VPN gateway."
  value       = module.vpn_gateway_site_b.vpn_gateway_crn
}
