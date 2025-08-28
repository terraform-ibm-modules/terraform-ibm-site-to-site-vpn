# VPC to VPC Example

This example demonstrates the configuration of a VPN site-to-site connection between two VPCs in different IBM Cloud regions (default: eu-es and eu-de). After deployment, you can confirm inter-region connectivity.

The setup creates two independent VPC environments (simulating "Site A" and "Site B"), in separate IBM Cloud regions, connected via VPN gateways for bidirectional communication. Each site includes:

- VPCs, each with specified address prefixes
- Subnets
- VSI instances, configured with an SSH key
- Security groups, with cross-site communication rules
- Floating IPs
- VPN Gateway configurations, including IKE/IPsec Policies
- VPN Connection (Site A <---> Site B)
- Custom routes added to each VPC's routing table

To verify connectivity post-deployment, follow these steps:

1. Export the generated private SSH key from the Terraform state, for example, with `terraform output -raw private_key > /tmp/key && chmod 600 /tmp/key`.
2. Connect to the VSI in Site A using the exported key: `ssh -i /tmp/key root@<floating_ip_address_site_a>` (found in the `floating_ip_address_site_a` Terraform output).
3. From the VSI in Site A, test connectivity to the private IP of a VSI in Site B using the `ping` command. The private IP of the Site B VSI is located in the `vsi_private_ip_site_b` output.
4. This test confirms packet routing from Site A to Site B through the established VPN link.
