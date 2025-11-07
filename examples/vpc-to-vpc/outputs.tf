# ########################################################################################################################
# # Outputs
# ########################################################################################################################

##############################################################################
# VPC
##############################################################################
output "vpc_ids" {
  description = "VPC IDs of Site A and Site B."
  value = {
    site_a = local.vpc_id_site_a
    site_b = local.vpc_id_site_b
  }
}

output "vsi_private_ips" {
  description = "Site A and Site B VSI private IP"
  value = {
    site_a = ibm_is_instance.vsi_site_a[0].primary_network_attachment[0].primary_ip[0].address
    site_b = ibm_is_instance.vsi_site_b[0].primary_network_attachment[0].primary_ip[0].address
  }
}

output "vsi_images" {
  description = "Site A and Site B VSI image details."
  value = {
    site_a = {
      "id" : module.vsi_image_selector_site_a.latest_image_id,
      "name" : module.vsi_image_selector_site_a.latest_image_name
    }
    site_b = {
      "id" : module.vsi_image_selector_site_b.latest_image_id,
      "name" : module.vsi_image_selector_site_b.latest_image_name
    }
  }
}


output "floating_ip_address" {
  description = "Public Floating IP address of the VSIs for site A and site B."
  value = {
    site_a = ibm_is_floating_ip.floating_ip_vsi_site_a.address
    site_b = ibm_is_floating_ip.floating_ip_vsi_site_b.address
  }
}

output "private_key" {
  description = "Commonly used SSH private key for both the sites."
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

##############################################################################
# VPN Gateway
##############################################################################
output "vpn_gateway_ips" {
  description = "VPN Gateway public IPs of Site A and Site B."
  value = {
    site_a = local.peer_ip_for_site_b
    site_b = local.peer_ip_for_site_a
  }
}

output "vpn_gateway_ids" {
  description = "VPN Gateway IDs of the Site A and Site B."
  value = {
    site_a = module.vpn_gateway_site_a.vpn_gateway_id
    site_b = module.vpn_gateway_site_b.vpn_gateway_id
  }
}

output "vpn_gateway_crns" {
  description = "CRN of the Site A and Site B VPN gateway."
  value = {
    site_a = module.vpn_gateway_site_a.vpn_gateway_crn
    site_b = module.vpn_gateway_site_b.vpn_gateway_crn
  }
}

##############################################################################
# VPN Gateway Connections
##############################################################################

output "vpn_connections_status" {
  description = "VPN Gateway Connection status for Site A and Site B."
  value = {
    site_a = module.vpn_gateway_site_a.vpn_gateway_connection_statuses[local.vpn_connection_name_site_a]
    site_b = module.vpn_gateway_site_b.vpn_gateway_connection_statuses[local.vpn_connection_name_site_b]
  }
}

output "vpn_gateway_connection_ids" {
  description = "Unique identifier of the VPN gateway connections for Site A and Site B."
  value = {
    site_a = module.vpn_gateway_site_a.vpn_gateway_connection_ids[local.vpn_connection_name_site_a]
    site_b = module.vpn_gateway_site_b.vpn_gateway_connection_ids[local.vpn_connection_name_site_b]
  }
}

output "vpn_connection_policies_site_a" {
  description = "VPN Connection policies for Site A."
  value       = module.vpn_gateway_site_a.vpn_connection_policies[local.vpn_connection_name_site_a]
}

output "vpn_connection_policies_site_b" {
  description = "VPN Connection policies for Site B."
  value       = module.vpn_gateway_site_b.vpn_connection_policies[local.vpn_connection_name_site_b]
}

##############################################################################
# VPN Routes
##############################################################################
output "vpn_routes" {
  description = "VPN routing information for site A and site B."
  value = {
    site_a = module.vpn_gateway_site_a.vpn_routes
    site_b = module.vpn_gateway_site_b.vpn_routes
  }
}

##############################################################################
