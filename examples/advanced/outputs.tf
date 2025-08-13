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
  value       = module.site_a_to_site_b.vpn_connection
}

output "vpn_connections_status_site_b" {
  description = "VPN connections status for Site B"
  value       = module.site_b_to_site_a.vpn_connection
}

output "floating_ip_address_site_a" {
  description = "Public Floating IP address of the VSI for site A."
  value       = ibm_is_floating_ip.floating_ip_vsi_site_a.address
}

output "floating_ip_address_site_b" {
  description = "Public Floating IP address of the VSI for site B."
  value       = ibm_is_floating_ip.floating_ip_vsi_site_b.address
}