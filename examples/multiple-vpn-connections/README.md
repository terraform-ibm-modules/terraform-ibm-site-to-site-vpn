
# Multiple Connections VPN Example

This example demonstrates the recommended pattern for creating a single VPN site
that connects to an existing remote VPN gateway. This example will:

- Create a new resource group if one is not passed in.
- Create a new VPC in the resource group.
- Create single zone subnet.
- Create a VPN gateway in Policy mode.
- Create IKE and IPSec policies.
- Creates 2 VPN connections.
- No Routes creation - Policy-based VPNs don’t use VPN routes or routing tables in IBM Cloud.

A policy-based VPN creates one tunnel per target network (CIDR), and routing is determined by the tunnel’s configured CIDRs. There’s no concept of “next hop” or route advertisement like in route-based VPNs
