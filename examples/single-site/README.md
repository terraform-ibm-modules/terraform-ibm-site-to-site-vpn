
# Basic Site-to-Site VPN Example

This example demonstrates the recommended pattern for creating a single VPN site
that connects to an existing remote VPN gateway. This example will:

- Create a new resource group if one is not passed in.
- Create a new VPC in the resource group.
- Create single zone subnet.
- Create a VPN gateway in route mode.
- Create IKE and IPSec policies.
- Create a VPN connection.
- Create Routes for connection.

> Please note:
IBM Cloud may not show route table attachment if the VPN connection is down or if IKE/IPsec negotiation fails (PSK mismatch, CIDRs missing, peer not reachable). You will not see the actual routes until the tunnel is established.
