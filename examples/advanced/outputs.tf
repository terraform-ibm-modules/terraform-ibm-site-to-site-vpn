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
  #   value       = ibm_is_instance.vsi_site_a[0].primary_network_attachment[0].virtual_network_interface[0].primary_ip[0].address
  value = ibm_is_instance.vsi_site_a[0].primary_network_attachment[0].primary_ip[0].address
}

output "vsi_private_ip_site_b" {
  description = "Site B VSI private IP"
  #   value       = ibm_is_instance.vsi_site_b[0].primary_network_attachment[0].virtual_network_interface[0].primary_ip[0].address
  value = ibm_is_instance.vsi_site_b[0].primary_network_attachment[0].primary_ip[0].address
}

output "vpn_gateway_ips" {
  description = "VPN Gateway public IPs."
  value = {
    site_a = local.vpn_gateway_site_a_ip
    site_b = local.vpn_gateway_site_b_ip
  }
}

output "vpn_connections_status" {
  description = "VPN connections status"
  value       = module.site_to_site_vpn.vpn_connections
}

output "ssh_private_key" {
  description = "SSH private key for VSI access"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}
