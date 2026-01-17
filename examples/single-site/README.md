# Single Site VPN Example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=site-to-site-vpn-single-site-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-site-to-site-vpn/tree/main/examples/single-site"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


This example demonstrates the recommended pattern for creating a single VPN site
that connects to an existing remote VPN gateway. This example will:

- Create a new resource group if one is not passed in.
- Create a new VPC in the resource group.
- Create single zone subnet.
- Create a VPN gateway in Policy mode.
- Create IKE and IPSec policies.
- Create a VPN connection.
- No Routes creation - Policy-based VPNs usually don’t use VPN routes or routing tables in IBM Cloud.

A policy-based VPN creates one tunnel per target network (CIDR), and routing is determined by the tunnel’s configured CIDRs. There’s no concept of “next hop” or route advertisement like in route-based VPNs

> Please note:
For policy-based VPN:

- IBM Cloud may not show any route table attachments, as policy-based VPN usually not use routing tables.
- The VPN connection must be established for traffic to flow.
  If IKE/IPSec negotiation fails (PSK mismatch, missing local or peer CIDRs, or peer not reachable), the tunnel will not come up.
- Each tunnel is created for the specified CIDRs. Ensure that both local and peer CIDRs are correctly configured.
- Edge cases - While the policy VPN tunnel itself doesn’t require routing, the surrounding VPC(s) (routing tables) may still require configuration to allow ingress/egress from sources like Transit Gateway, Direct Link, or additional VPCs.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
