
# Multiple Connections VPN Example

This example demonstrates the recommended pattern for creating a single VPN site
that connects to an existing remote VPN gateway. This example will:

- Create a new resource group if one is not passed in.
- Create a new VPC in the resource group.
- Create single zone subnet.
- Create a VPN gateway in Policy mode.
- Creates 2 VPN connections.
- Creates IKE and IPSec policies for both connections.
- No Routes creation - `policy-based` VPNs usually don’t use VPN routes or routing tables in IBM Cloud.

A `policy-based` VPN creates one tunnel per target network (CIDR), and routing is determined by the tunnel’s configured CIDRs. There’s no concept of “next hop” or route advertisement like in `route-based` VPNs

- Edge cases - While the policy VPN tunnel itself doesn’t require routing, the surrounding VPC(s) (routing tables) may still require configuration to allow ingress/egress from sources like Transit Gateway, Direct Link, or additional VPCs.
