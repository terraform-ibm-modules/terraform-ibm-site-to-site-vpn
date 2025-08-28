# Site to Site VPN Module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-site-to-site-vpn?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-site-to-site-vpn/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

This module automates the provisioning of a site-to-site VPN. For more information, see [About site-to-site VPN](https://cloud.ibm.com/docs/vpc?topic=vpc-using-vpn) in the IBM Cloud docs.

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-site-to-site-vpn](#terraform-ibm-site-to-site-vpn)
* [Submodules](./modules)
    * [vpn_policies](./modules/vpn_policies)
    * [vpn_routing](./modules/vpn_routing)
* [Examples](./examples)
    * [VPC to VPC Example](./examples/vpc-to-vpc)
    * [](./examples/single-site)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and link to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-site-to-site-vpn

This Terraform module provisions a complete Site‑to‑Site VPN solution on IBM Cloud VPC, including VPN gateways, connections, policies, routing, and (optional) route advertisement.

For more information refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-using-vpn&interface=terraform)

## Key Components

### VPN Gateway

* Creates the VPN gateway instance in specified subnet.
* Supports both policy-based and route-based VPN configurations.
* High availability with multiple gateway members across zones.
* Public IP address automatically assigned for external connectivity.

### VPN Policies

*IKE Policy :*

* Internet Key Exchange policy for Phase 1 negotiation.
* Configurable authentication algorithms (SHA-1, SHA-256, SHA-384, SHA-512).
* Configurable encryption algorithms (AES-128, AES-192, AES-256, 3DES).
* Configurable Diffie-Hellman groups (2, 5, 14, 15, 16, 17, 18, 19, 20, 21).
* IKE version support (IKEv1, IKEv2).

*IPSec Policy :*

* Internet Protocol Security policy for Phase 2 negotiation.
* Configurable authentication and encryption algorithms.
* Perfect Forward Secrecy (PFS) support.
* Use custom policy if default does not meet peer requirements.

### VPN Connections

* Establishes IPSec tunnels between local and peer gateways.
* Supports multiple connections per gateway for redundancy.
* Dead Peer Detection (DPD) configuration.
* Local and peer subnet definitions.

### Route Management

* Custom routes in VPC routing tables for directing traffic through VPN tunnels.
* Route advertisement capabilities for dynamic routing.
* Integration with VPC routing tables.
* Support for both static and dynamic routing.

## Important Considerations

### Network specific

* VPC must be created and configured before deploying the VPN gateway.
* Subnets must exist in the target zones where VPN gateways will be deployed.
* Local and peer network CIDR blocks must not overlap.
* Ensure proper network segmentation and IP address planning.
* Verify that the peer VPN gateway supports IPSec protocols.

### Security specific

* Pre-shared key (PSK) must be configured and shared between both endpoints.
* IKE and IPSec policies must be compatible between local and peer gateways.
* Proper authentication methods must be established.
* Security groups and NACLs must allow VPN traffic.

Please refer [Planning considerations for VPN gateways](https://cloud.ibm.com/docs/vpc?topic=vpc-planning-considerations-vpn&interface=terraform) for more information.

## Known Limitations

* IBM permits **only one route‑based VPN gateway per zone per VPC.** For zone fault tolerance, deploy one VPN gateway per zone.
* VPN gateway names must be unique within the VPC.
* Gateway requires `/28` subnet and cannot share with other VPC.
* If peer VPN gateway lacks a public IP, use **FQDN identity** in VPC.
* Peer subnets of a VPN gateway connection cannot overlap.
* Peer address type is immutable — once set as FQDN or IP, it cannot be changed.
* Route-based mode allows distribute_traffic = true to enable active‑active tunnels; policy‑based does not.
* If peer is behind NAT, use `establish_mode = "peer_only"` and supply FQDN and identity overrides because identities must match expected values on negotiation.
* Creating a route in an ingress routing table with a VPN gateway connection as the next hop is not supported.

Please refer [Known issues for VPN gateways](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-limitations) for more information.</br>
Tunnel status may remain DOWN for a while after deployment, with delays observed before it shows as UP.

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "X.Y.Z"  # Lock into a provider version that satisfies the module constraints
    }
  }
}

locals {
    region = "us-south"
}

provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"  # replace with apikey value
  region           = local.region
}

module "site_to_site_vpn" {
  source                         = "terraform-ibm-modules/site-to-site-vpn/ibm"
  version                        = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id              = "65xxxxxxxxxxxxxxxa3fd"
  create_vpn_gateway             = true
  tags                           = var.tags
  vpn_gateway_name               = "xxxxx" # Name of the VPN Gateway
  vpn_gateway_subnet_id          = "s..12" # Subnet id where VPN Gateway will be created
  vpn_gateway_mode               = "route" # Can be route or policy
  create_vpn_policies            = true
  ike_policy_name                = "xxx-ike-policy" # Name of the IKE Policy
  ike_authentication_algorithm   = "sha256" # Choose the relevant authentication algorithm
  ike_encryption_algorithm       = "aes256" # Choose the relevant encryption algorithm
  ike_dh_group                   = 14 # Provide valid Diffie-Hellman group.
  ipsec_policy_name              = "xxx-ipsec-policy" # Name of the IPSec Policy
  ipsec_authentication_algorithm = "sha256" # Choose the relevant authentication algorithm
  ipsec_encryption_algorithm     = "aes256" # Choose the relevant encryption algorithm
  ipsec_pfs                      = "group_14" # Perfect Forward Secrecy (PFS) protocol value

  # Create Connection to Remote Peer
  vpn_gateway_connection_name   = "xxx-vpn-conn" # VPN Connection name
  preshared_key     = "XXXXXX"

  # Peer Configuration (remote VPN gateway)
  peer_config = [
    {
      address = "X.X.X.X" # Remote Gateway IP address
      ike_identity = [
        {
          type  = "ipv4_address"
          value = "X.X.X.X" # Remote Gateway IP address
        }
      ]
    }
  ]
  # Local Configuration
  local_config = [
    {
      # Minimum of 2 IKE Identities are required
      ike_identities = [
        {
          type  = "ipv4_address"
          value = module.vpn_gateway.vpn_gateway_public_ip # Use the VPN gateway id
        },
        {
          type  = "ipv4_address"
          value = module.vpn_gateway.vpn_gateway_public_ip # Use the VPN gateway id
        }
      ]
    }
  ]

  # Routing table and Routes creation
  create_route_table               = true
  routing_table_name               = "xxx-rt" # Name of Routing Table
  accept_routes_from_resource_type = ["vpn_gateway"]
  route_attach_subnet                    = true
  route_subnet_id                        = "s...123" # Subnet id where VPN Gateway is created
  # Add routes
  create_routes = true
  vpc_id        = "vpc-xxxx" # Provide VPC Id.
  routes = [
    {
      name             = "example-vpn-route-1"
      vpn_gateway_name = "xxxxx" # Name of the VPN Gateway
      zone             = "zone-1"
      next_hop         = module.site_to_site_vpn.vpn_gateway_id
      destination      = "X.X.X.X" # Provide Remote CIDR
    }
  ]
}

```

### Required IAM access policies

You need the following permissions to run this module.

- IAM services
    - **VPC Infrastructure** services
        - `Editor` platform access
    - **No service access**
        - **Resource Group** \<your resource group>
        - `Viewer` resource group access

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.80.3, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpn_policies"></a> [vpn\_policies](#module\_vpn\_policies) | ./modules/vpn_policies | n/a |
| <a name="module_vpn_routes"></a> [vpn\_routes](#module\_vpn\_routes) | ./modules/vpn_routing | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_is_vpn_gateway.vpn_gateway](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpn_gateway) | resource |
| [ibm_is_vpn_gateway_connection.vpn_site_to_site_connection](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpn_gateway_connection) | resource |
| [time_sleep.wait_for_gateway_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accept_routes_from_resource_type"></a> [accept\_routes\_from\_resource\_type](#input\_accept\_routes\_from\_resource\_type) | List of resource types allowed to create routes in this table. | `list(string)` | `[]` | no |
| <a name="input_advertise_routes_to"></a> [advertise\_routes\_to](#input\_advertise\_routes\_to) | Ingress sources to which routes should be advertised. | `list(string)` | `[]` | no |
| <a name="input_create_route_table"></a> [create\_route\_table](#input\_create\_route\_table) | Whether to create a new route table. | `bool` | `false` | no |
| <a name="input_create_routes"></a> [create\_routes](#input\_create\_routes) | Whether to create VPN routes. | `bool` | `false` | no |
| <a name="input_create_vpn_gateway"></a> [create\_vpn\_gateway](#input\_create\_vpn\_gateway) | Whether to create a new VPN Gateway. Set to false to use an existing gateway. | `bool` | `true` | no |
| <a name="input_create_vpn_policies"></a> [create\_vpn\_policies](#input\_create\_vpn\_policies) | Whether to create a new IKE and IPSec policy. | `bool` | `false` | no |
| <a name="input_dpd_action"></a> [dpd\_action](#input\_dpd\_action) | Optional action to perform when the peer is unresponsive. Possible values are - 'restart', 'clear', 'hold', or 'none'. | `string` | `"restart"` | no |
| <a name="input_dpd_check_interval"></a> [dpd\_check\_interval](#input\_dpd\_check\_interval) | Optional interval in seconds between dead peer detection checks for peer responsiveness. | `number` | `2` | no |
| <a name="input_dpd_max_timeout"></a> [dpd\_max\_timeout](#input\_dpd\_max\_timeout) | Optional time in seconds to wait before considering the peer unreachable. | `number` | `10` | no |
| <a name="input_enable_distribute_traffic"></a> [enable\_distribute\_traffic](#input\_enable\_distribute\_traffic) | Optional flag for route-based VPN gateway connections to control traffic distribution across active tunnels. When true, traffic is load-balanced otherwise, it flows through the tunnel with the lower public IP. | `bool` | `false` | no |
| <a name="input_establish_mode"></a> [establish\_mode](#input\_establish\_mode) | Optional field to determine the IKE negotiation behavior for the VPN gateway connection. Use 'bidirectional' to allow both sides to initiate IKE negotiations and rekeying. Use 'peer\_only' to restrict initiation and rekeying to the peer side. | `string` | `"bidirectional"` | no |
| <a name="input_existing_ike_policy_id"></a> [existing\_ike\_policy\_id](#input\_existing\_ike\_policy\_id) | ID of existing IKE policy to use instead of creating new one. | `string` | `null` | no |
| <a name="input_existing_ipsec_policy_id"></a> [existing\_ipsec\_policy\_id](#input\_existing\_ipsec\_policy\_id) | ID of existing IPSec policy to use instead of creating new one. | `string` | `null` | no |
| <a name="input_existing_route_table_id"></a> [existing\_route\_table\_id](#input\_existing\_route\_table\_id) | ID of existing route table to use. | `string` | `null` | no |
| <a name="input_existing_vpn_gateway_id"></a> [existing\_vpn\_gateway\_id](#input\_existing\_vpn\_gateway\_id) | ID of existing VPN Gateway to use. Required if create\_vpn\_gateway is false and vpn\_gateway\_name is not provided. | `string` | `null` | no |
| <a name="input_ike_authentication_algorithm"></a> [ike\_authentication\_algorithm](#input\_ike\_authentication\_algorithm) | The authentication algorithm used in the IKE policy. Valid values: sha256, sha384, sha512. | `string` | `null` | no |
| <a name="input_ike_dh_group"></a> [ike\_dh\_group](#input\_ike\_dh\_group) | The Diffie-Hellman group to use. Valid values: 14 to 24, or 31. | `number` | `null` | no |
| <a name="input_ike_encryption_algorithm"></a> [ike\_encryption\_algorithm](#input\_ike\_encryption\_algorithm) | The encryption algorithm used in the IKE policy. Valid values: aes128, aes192, aes256. | `string` | `null` | no |
| <a name="input_ike_key_lifetime"></a> [ike\_key\_lifetime](#input\_ike\_key\_lifetime) | The key lifetime in seconds. Must be between 1800 and 86400. | `number` | `28800` | no |
| <a name="input_ike_policy_name"></a> [ike\_policy\_name](#input\_ike\_policy\_name) | Name of the IKE policy to create. Applicable when create\_vpn\_policies is true | `string` | `null` | no |
| <a name="input_ike_version"></a> [ike\_version](#input\_ike\_version) | The IKE protocol version to use. Valid values: 1 or 2. | `number` | `2` | no |
| <a name="input_ipsec_authentication_algorithm"></a> [ipsec\_authentication\_algorithm](#input\_ipsec\_authentication\_algorithm) | The authentication algorithm for the IPSec policy. Valid values: sha256, sha384, sha512, disabled. | `string` | `null` | no |
| <a name="input_ipsec_encryption_algorithm"></a> [ipsec\_encryption\_algorithm](#input\_ipsec\_encryption\_algorithm) | The encryption algorithm for the IPSec policy. Valid values: aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16. | `string` | `null` | no |
| <a name="input_ipsec_key_lifetime"></a> [ipsec\_key\_lifetime](#input\_ipsec\_key\_lifetime) | The key lifetime for the IPSec policy in seconds. Must be between 300 and 86400. | `number` | `3600` | no |
| <a name="input_ipsec_pfs"></a> [ipsec\_pfs](#input\_ipsec\_pfs) | The Perfect Forward Secrecy (PFS) protocol for the IPSec policy. Valid values: disabled, group\_2, group\_5, group\_14. | `string` | `null` | no |
| <a name="input_ipsec_policy_name"></a> [ipsec\_policy\_name](#input\_ipsec\_policy\_name) | Name of the IPSec policy to create. | `string` | `null` | no |
| <a name="input_is_admin_state_up"></a> [is\_admin\_state\_up](#input\_is\_admin\_state\_up) | Optional flag to control the administrative state of the VPN gateway connection. If set to false (default), the connection is shut down. Set to true to enable the connection. | `bool` | `false` | no |
| <a name="input_local_config"></a> [local\_config](#input\_local\_config) | Optional configuration for local IKE identities. Each entry in the list represents a VPN gateway member in active-active mode, containing one or more IKE identities. | <pre>list(object({<br/>    ike_identities = list(object({<br/>      type  = string<br/>      value = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_peer_config"></a> [peer\_config](#input\_peer\_config) | Optional configuration for the remote peer VPN gateway. Includes peer address/FQDN, CIDRs, IKE identity type, and optional identity value. | <pre>list(object({<br/>    address = optional(string)<br/>    fqdn    = optional(string)<br/>    cidrs   = optional(list(string), [])<br/>    ike_identity = list(object({<br/>      type  = string<br/>      value = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_preshared_key"></a> [preshared\_key](#input\_preshared\_key) | Required to specify the authentication key of the VPN gateway for the network outside your VPC. [Learn More](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-create-gateway&interface=ui#planning-considerations-vpn) | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to use where you want to create the VPN gateway. | `string` | n/a | yes |
| <a name="input_route_attach_subnet"></a> [route\_attach\_subnet](#input\_route\_attach\_subnet) | Whether to attach subnet to the VPN route table. | `bool` | `false` | no |
| <a name="input_route_direct_link_ingress"></a> [route\_direct\_link\_ingress](#input\_route\_direct\_link\_ingress) | Allow routing from Direct Link. | `bool` | `false` | no |
| <a name="input_route_internet_ingress"></a> [route\_internet\_ingress](#input\_route\_internet\_ingress) | Allow routing from Internet. | `bool` | `false` | no |
| <a name="input_route_subnet_id"></a> [route\_subnet\_id](#input\_route\_subnet\_id) | Subnet ID to attach to the routing table. | `string` | `null` | no |
| <a name="input_route_transit_gateway_ingress"></a> [route\_transit\_gateway\_ingress](#input\_route\_transit\_gateway\_ingress) | Allow routing from Transit Gateway. | `bool` | `false` | no |
| <a name="input_route_vpc_zone_ingress"></a> [route\_vpc\_zone\_ingress](#input\_route\_vpc\_zone\_ingress) | Allow routing from other zones within the VPC. | `bool` | `false` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | List of routes to create. | <pre>list(object({<br/>    name        = string<br/>    zone        = string<br/>    destination = string<br/>    next_hop    = string<br/>    action      = optional(string, "deliver")<br/>    advertise   = optional(bool, false)<br/>    priority    = optional(number, 2)<br/>  }))</pre> | `[]` | no |
| <a name="input_routing_table_name"></a> [routing\_table\_name](#input\_routing\_table\_name) | Name of the routing table to create. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tags for the resource created | `list(string)` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where routes will be created. | `string` | `null` | no |
| <a name="input_vpn_gateway_connection_name"></a> [vpn\_gateway\_connection\_name](#input\_vpn\_gateway\_connection\_name) | Name of the VPN connection. | `string` | n/a | yes |
| <a name="input_vpn_gateway_mode"></a> [vpn\_gateway\_mode](#input\_vpn\_gateway\_mode) | Specifies the VPN configuration mode for IBM Cloud VPN for VPC. Use 'route' for a static, route-based IPsec tunnel or 'policy' for a policy-based tunnel to connect your VPC to another private network. | `string` | `"route"` | no |
| <a name="input_vpn_gateway_name"></a> [vpn\_gateway\_name](#input\_vpn\_gateway\_name) | Name of the VPN gateway. Only required if creating a new VPN Gateway. | `string` | `null` | no |
| <a name="input_vpn_gateway_subnet_id"></a> [vpn\_gateway\_subnet\_id](#input\_vpn\_gateway\_subnet\_id) | The ID of the subnet where the VPN gateway will reside in. | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ike_policy"></a> [ike\_policy](#output\_ike\_policy) | Map of newly created IKE policy. |
| <a name="output_ipsec_policy"></a> [ipsec\_policy](#output\_ipsec\_policy) | Map of newly created IPSec policy. |
| <a name="output_vpn_gateway_connection_id"></a> [vpn\_gateway\_connection\_id](#output\_vpn\_gateway\_connection\_id) | Unique identifier of the VPN gateway connection. |
| <a name="output_vpn_gateway_connection_mode"></a> [vpn\_gateway\_connection\_mode](#output\_vpn\_gateway\_connection\_mode) | Mode of the VPN gateway connection: either 'policy' or 'route'. |
| <a name="output_vpn_gateway_connection_name"></a> [vpn\_gateway\_connection\_name](#output\_vpn\_gateway\_connection\_name) | Name of the VPN gateway connection. |
| <a name="output_vpn_gateway_connection_status"></a> [vpn\_gateway\_connection\_status](#output\_vpn\_gateway\_connection\_status) | Current status of the VPN gateway connection, either 'up' or 'down'. |
| <a name="output_vpn_gateway_crn"></a> [vpn\_gateway\_crn](#output\_vpn\_gateway\_crn) | CRN of the VPN gateway. |
| <a name="output_vpn_gateway_id"></a> [vpn\_gateway\_id](#output\_vpn\_gateway\_id) | ID of the VPN gateway. |
| <a name="output_vpn_gateway_members"></a> [vpn\_gateway\_members](#output\_vpn\_gateway\_members) | List of VPN gateway members. |
| <a name="output_vpn_gateway_public_ip"></a> [vpn\_gateway\_public\_ip](#output\_vpn\_gateway\_public\_ip) | Resolved public IP address from either `public_ip_address` or `public_ip_address2`. [Learn more](https://registry.terraform.io/providers/IBM-cloud/ibm/1.80.4/docs/resources/is_vpn_gateway#public_ip_address2-4) |
| <a name="output_vpn_gateway_status"></a> [vpn\_gateway\_status](#output\_vpn\_gateway\_status) | Overall health state of the VPN gateway. Refer [here](https://registry.terraform.io/providers/IBM-cloud/ibm/1.80.4/docs/resources/is_vpn_gateway#health_state-4) for more information. |
| <a name="output_vpn_gateway_vpc_info"></a> [vpn\_gateway\_vpc\_info](#output\_vpn\_gateway\_vpc\_info) | Information about the VPC associated with the VPN gateway. |
| <a name="output_vpn_routes"></a> [vpn\_routes](#output\_vpn\_routes) | VPN routing information. |
| <a name="output_vpn_status_reasons"></a> [vpn\_status\_reasons](#output\_vpn\_status\_reasons) | List of status reasons explaining the current connection state. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
