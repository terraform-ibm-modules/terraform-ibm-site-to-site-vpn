
# IBM Cloud Site-to-Site VPN Terraform Module

This Terraform-based example deploys two independent VPC environments ("Site A" and "Site B") in different IBM Cloud regions, with VPN gateways connecting them bidirectionally. Each site includes following resources:

- VPCs
- Subnets
- VSI instances (with SSH key)
- Security groups
- VPN Gateway + IKE/IPsec Policies
- VPN Connection (Site A ↔ Site B)
- Custom routes in each VPC's routing table

Once all resources are provisioned, the connectivity among two VSIs is checked by pinging VSI in Site B from Site A and vice versa.
