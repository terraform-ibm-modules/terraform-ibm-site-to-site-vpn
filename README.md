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
    * <div style="display: inline-block;"><a href="./examples/multiple-vpn-connections">Multiple Connections VPN Example</a></div> <div style="display: inline-block; vertical-align: middle;"><a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=stsv-multiple-vpn-connections-example&repository=github.com/terraform-ibm-modules/terraform-ibm-site-to-site-vpn/tree/main/examples/multiple-vpn-connections" target="_blank"><img src="https://cloud.ibm.com/media/docs/images/icons/Deploy_to_cloud.svg" alt="Deploy to IBM Cloud button"></a></div>
    * <div style="display: inline-block;"><a href="./examples/single-site">Single Site VPN Example</a></div> <div style="display: inline-block; vertical-align: middle;"><a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=stsv-single-site-example&repository=github.com/terraform-ibm-modules/terraform-ibm-site-to-site-vpn/tree/main/examples/single-site" target="_blank"><img src="https://cloud.ibm.com/media/docs/images/icons/Deploy_to_cloud.svg" alt="Deploy to IBM Cloud button"></a></div>
    * <div style="display: inline-block;"><a href="./examples/vpc-to-vpc">VPC to VPC Example</a></div> <div style="display: inline-block; vertical-align: middle;"><a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=stsv-vpc-to-vpc-example&repository=github.com/terraform-ibm-modules/terraform-ibm-site-to-site-vpn/tree/main/examples/vpc-to-vpc" target="_blank"><img src="https://cloud.ibm.com/media/docs/images/icons/Deploy_to_cloud.svg" alt="Deploy to IBM Cloud button"></a></div>
    * <div style="display: inline-block;"><a href="./examples/vpc-to-vpc/existing-gateway-connection">Adding Connection to Existing VPN Gateway</a></div> <div style="display: inline-block; vertical-align: middle;"><a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=stsv-existing-gateway-connection-example&repository=github.com/terraform-ibm-modules/terraform-ibm-site-to-site-vpn/tree/main/examples/vpc-to-vpc/existing-gateway-connection" target="_blank"><img src="https://cloud.ibm.com/media/docs/images/icons/Deploy_to_cloud.svg" alt="Deploy to IBM Cloud button"></a></div>
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

> **Note:**
> - When using existing policy IDs (both IKE and IPSec), ensure that the policy resides in the **same region as the VPN Gateway**.
> - Within a given region, policy names must be **unique**. Two policies with the same name cannot coexist in the same region.


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
  ike_policy_config = {
    name                     = "xxx-ike-policy" # Name of the IKE Policy
    authentication_algorithm = "sha256" # Choose the relevant authentication algorithm
    encryption_algorithm     = "aes256" # Choose the relevant encryption algorithm
    dh_group                 = 14 # Provide valid Diffie-Hellman group.
  }
  ipsec_policy_config = {
    name                     = "xxx-ipsec-policy" # Name of the IPSec Policy
    encryption_algorithm     = "aes256" # Choose the relevant encryption algorithm
    authentication_algorithm = "sha256" # Choose the relevant authentication algorithm
    pfs                      = "group_14" # Perfect Forward Secrecy (PFS) protocol value
  }
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

  # Policies
  create_ike_policy   = true
  create_ipsec_policy = true
  ike_policy_config   = local.ike_policy_config
  ipsec_policy_config = local.ipsec_policy_config

  # VPN Connections
  vpn_connections = [
    {
      name         = "xxx-vpn-conn" # VPN Connection name
      peer_address = "X.X.X.X" # Remote VPN gateway IP
      preshared_key = "XXXXXX"

      # Peer Configuration (remote VPN gateway)
      peer_config = [
        {
          address = "X.X.X.X" # Remote Gateway IP address
          cidrs = [X.X.X.X] # Provide CIDRs (Required for Policy based VPN)
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
          cidrs = ["10.10.0.0/16"]  # Local VPC CIDRs
          # Minimum of 2 IKE Identities are required for Route based VPN and atmost 1 for Policy based VPN
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
      next_hop         = null # This will be resolved using Connection name
      vpn_connection_name = "xxxx" # Name of the VPN Connection
      destination      = "X.X.X.X" # Provide Remote CIDR
    }
  ]
}

```

### State Migration Guide:

Please refer the [state migration](./State-Migration.md) document for more information.

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
| <a name="input_existing_route_table_id"></a> [existing\_route\_table\_id](#input\_existing\_route\_table\_id) | ID of existing route table to use. | `string` | `null` | no |
| <a name="input_existing_vpn_gateway_id"></a> [existing\_vpn\_gateway\_id](#input\_existing\_vpn\_gateway\_id) | ID of existing VPN Gateway to use. Required if create\_vpn\_gateway is false and vpn\_gateway\_name is not provided. | `string` | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to use where you want to create the VPN gateway. | `string` | n/a | yes |
| <a name="input_route_attach_subnet"></a> [route\_attach\_subnet](#input\_route\_attach\_subnet) | Whether to attach subnet to the VPN route table. | `bool` | `false` | no |
| <a name="input_route_direct_link_ingress"></a> [route\_direct\_link\_ingress](#input\_route\_direct\_link\_ingress) | Allow routing from Direct Link. | `bool` | `false` | no |
| <a name="input_route_internet_ingress"></a> [route\_internet\_ingress](#input\_route\_internet\_ingress) | Allow routing from Internet. | `bool` | `false` | no |
| <a name="input_route_subnet_id"></a> [route\_subnet\_id](#input\_route\_subnet\_id) | Subnet ID to attach to the routing table. | `string` | `null` | no |
| <a name="input_route_transit_gateway_ingress"></a> [route\_transit\_gateway\_ingress](#input\_route\_transit\_gateway\_ingress) | Allow routing from Transit Gateway. | `bool` | `false` | no |
| <a name="input_route_vpc_zone_ingress"></a> [route\_vpc\_zone\_ingress](#input\_route\_vpc\_zone\_ingress) | Allow routing from other zones within the VPC. | `bool` | `false` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | List of routes to create. | <pre>list(object({<br/>    name                = string<br/>    zone                = string<br/>    destination         = string<br/>    next_hop            = string<br/>    action              = optional(string, "deliver")<br/>    advertise           = optional(bool, false)<br/>    priority            = optional(number, 2)<br/>    vpn_connection_name = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_routing_table_name"></a> [routing\_table\_name](#input\_routing\_table\_name) | Name of the routing table to create. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tags for the resource created | `list(string)` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where routes will be created. | `string` | `null` | no |
| <a name="input_vpn_connections"></a> [vpn\_connections](#input\_vpn\_connections) | List of VPN connections to attach to the VPN gateway. | <pre>list(object({<br/>    name                      = string                            # Name of the VPN connection<br/>    preshared_key             = string                            # Required to specify the authentication key of the VPN gateway for the network outside your VPC. [Learn More](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-create-gateway&interface=ui#planning-considerations-vpn)<br/>    is_admin_state_up         = optional(bool, false)             # Flag to control the administrative state of the VPN gateway connection. If set to false (default), the connection is shut down. Set to true to enable the connection.<br/>    establish_mode            = optional(string, "bidirectional") # Determines IKE negotiation behavior for the VPN gateway connection. Use 'bidirectional' to allow both sides to initiate IKE negotiations and rekeying. Use 'peer_only' to restrict initiation and rekeying to the peer side.<br/>    enable_distribute_traffic = optional(bool, false)             # Flag for route-based VPN gateway connections to control traffic distribution across active tunnels. When true, traffic is load-balanced otherwise, it flows through the tunnel with the lower public IP.<br/>    dpd_action                = optional(string, "restart")       # Action to perform when the peer is unresponsive. Possible values are - 'restart', 'clear', 'hold', or 'none'.<br/>    dpd_check_interval        = optional(number, 2)               # Interval in seconds between dead peer detection checks for peer responsiveness.<br/>    dpd_max_timeout           = optional(number, 10)              # Time in seconds to wait before considering the peer unreachable.<br/><br/>    # Policy configuration per connection<br/><br/>    # IKE Policy<br/>    create_ike_policy      = optional(bool, false)  # Flag to create new IKE policy.<br/>    existing_ike_policy_id = optional(string, null) # ID of existing IKE policy to use (mutually exclusive with create_ike_policy)<br/><br/>    ike_policy_config = optional(object({<br/>      name                     = string<br/>      authentication_algorithm = string # sha256, sha384, sha512<br/>      encryption_algorithm     = string # aes128, aes192, aes256<br/>      dh_group                 = number # 14-24, 31<br/>      ike_version              = optional(number, 2)<br/>      key_lifetime             = optional(number, 28800)<br/>    }), null) # Provide config only if create_ike_policy is true<br/><br/>    # IPSec policy<br/>    create_ipsec_policy      = optional(bool, false)  # Flag to create new IPSec policy<br/>    existing_ipsec_policy_id = optional(string, null) # ID of existing IPSec policy to use (mutually exclusive with create_ipsec_policy)<br/><br/>    ipsec_policy_config = optional(object({<br/>      name                     = string<br/>      encryption_algorithm     = string # aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16<br/>      authentication_algorithm = string # sha256, sha384, sha512, disabled<br/>      pfs                      = string # disabled, group_2, group_5, group_14<br/>      key_lifetime             = optional(number, 3600)<br/>    }), null) # Provide config only if create_ipsec_policy is true<br/><br/>    # Peer and Local Configuration<br/>    peer_config = optional(list(object({<br/>      address = optional(string)<br/>      fqdn    = optional(string)<br/>      cidrs   = optional(list(string), [])<br/>      ike_identity = list(object({<br/>        type  = string<br/>        value = optional(string)<br/>      }))<br/>    })), [])<br/><br/>    local_config = optional(list(object({<br/>      cidrs = optional(list(string), [])<br/>      ike_identities = list(object({<br/>        type  = string<br/>        value = optional(string)<br/>      }))<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_vpn_gateway_mode"></a> [vpn\_gateway\_mode](#input\_vpn\_gateway\_mode) | Specifies the VPN configuration mode for IBM Cloud VPN for VPC. Use 'route' for a static, route-based IPsec tunnel or 'policy' for a policy-based tunnel to connect your VPC to another private network. | `string` | `"route"` | no |
| <a name="input_vpn_gateway_name"></a> [vpn\_gateway\_name](#input\_vpn\_gateway\_name) | Name of the VPN gateway. Only required if creating a new VPN Gateway. | `string` | `null` | no |
| <a name="input_vpn_gateway_subnet_id"></a> [vpn\_gateway\_subnet\_id](#input\_vpn\_gateway\_subnet\_id) | The ID of the subnet where the VPN gateway will reside in. | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_connection_policies"></a> [vpn\_connection\_policies](#output\_vpn\_connection\_policies) | IKE and IPSec policy details. |
| <a name="output_vpn_gateway_connection_ids"></a> [vpn\_gateway\_connection\_ids](#output\_vpn\_gateway\_connection\_ids) | Map of VPN gateway connection IDs, keyed by connection name. |
| <a name="output_vpn_gateway_connection_modes"></a> [vpn\_gateway\_connection\_modes](#output\_vpn\_gateway\_connection\_modes) | Map of VPN gateway connection modes: either 'policy' or 'route'. |
| <a name="output_vpn_gateway_connection_statuses"></a> [vpn\_gateway\_connection\_statuses](#output\_vpn\_gateway\_connection\_statuses) | Map of current statuses for each VPN gateway connection, either 'up' or 'down'. |
| <a name="output_vpn_gateway_crn"></a> [vpn\_gateway\_crn](#output\_vpn\_gateway\_crn) | CRN of the VPN gateway. |
| <a name="output_vpn_gateway_id"></a> [vpn\_gateway\_id](#output\_vpn\_gateway\_id) | ID of the VPN gateway. |
| <a name="output_vpn_gateway_members"></a> [vpn\_gateway\_members](#output\_vpn\_gateway\_members) | List of VPN gateway members. |
| <a name="output_vpn_gateway_public_ip"></a> [vpn\_gateway\_public\_ip](#output\_vpn\_gateway\_public\_ip) | The IP address assigned to the VPN gateway. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpn_gateway#public_ip_address-1) |
| <a name="output_vpn_gateway_public_ip_2"></a> [vpn\_gateway\_public\_ip\_2](#output\_vpn\_gateway\_public\_ip\_2) | The Second Public IP address assigned to the VPN gateway member. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpn_gateway#private_ip_address2-1) |
| <a name="output_vpn_gateway_status"></a> [vpn\_gateway\_status](#output\_vpn\_gateway\_status) | Overall health state of the VPN gateway. Refer [here](https://registry.terraform.io/providers/IBM-cloud/ibm/1.80.4/docs/resources/is_vpn_gateway#health_state-4) for more information. |
| <a name="output_vpn_gateway_vpc_info"></a> [vpn\_gateway\_vpc\_info](#output\_vpn\_gateway\_vpc\_info) | Information about the VPC associated with the VPN gateway. |
| <a name="output_vpn_routes"></a> [vpn\_routes](#output\_vpn\_routes) | VPN Routing information. |
| <a name="output_vpn_status_reasons"></a> [vpn\_status\_reasons](#output\_vpn\_status\_reasons) | Map of status reasons explaining the current connection state per connection. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
