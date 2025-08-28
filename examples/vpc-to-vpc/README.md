# VPC to VPC Example

This Terraform-based example deploys two independent VPC environments ("Site A" and "Site B") in different IBM Cloud regions, with VPN gateways connecting them bidirectionally. Each site includes the following resources:

- VPCs with address prefixes
- Subnets
- VSI instances (with SSH key)
- Security groups with cross-site communication rules
- Floating IPs
- VPN Gateway + IKE/IPsec Policies
- VPN Connection (Site A <---> Site B)
- Custom routes in each VPCs' routing table
