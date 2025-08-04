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
    * [gateway](./modules/gateway)
    * [gateway_connection](./modules/gateway_connection)
    * [vpn_policies](./modules/vpn_policies)
    * [vpn_routing](./modules/vpn_routing)
* [Examples](./examples)
    * [](./examples/basic)
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


## Additional Information

* IBM permits only one route‑based VPN gateway per zone per VPC and gateway names must be unique within the VPC
* Peer address type is immutable — once set as FQDN or IP, it cannot be changed.
* Route-based mode allows distribute_traffic = true to enable active‑active tunnels; policy‑based does not (: only one tunnel used).
* If peer is behind NAT, use establish_mode = "peer_only" and supply FQDN and identity overrides because identities must match expected values on negotiation.


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

module "module_template" {
  source            = "terraform-ibm-modules/<replace>/ibm"
  version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  region            = local.region
  name              = "instance-name"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX" # Replace with the actual ID of resource group to use
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

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the 'Sample IBM Cloud' service and roles with applicable values.
The required information can usually be found in the services official
IBM Cloud documentation.
To view all available service permissions, you can go in the
console at Manage > Access (IAM) > Access groups and click into an existing group
(or create a new one) and in the 'Access' tab click 'Assign access'.
-->

<!--
You need the following permissions to run this module:

- Service
    - **Resource group only**
        - `Viewer` access on the specific resource group
    - **Sample IBM Cloud** service
        - `Editor` platform access
        - `Manager` service access
-->

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.80.3, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpn_connections"></a> [vpn\_connections](#module\_vpn\_connections) | ./modules/gateway_connection | n/a |
| <a name="module_vpn_gateway"></a> [vpn\_gateway](#module\_vpn\_gateway) | ./modules/gateway | n/a |
| <a name="module_vpn_policies"></a> [vpn\_policies](#module\_vpn\_policies) | ./modules/vpn_policies | n/a |
| <a name="module_vpn_routes"></a> [vpn\_routes](#module\_vpn\_routes) | ./modules/vpn_routing | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accept_routes_from_resource_type"></a> [accept\_routes\_from\_resource\_type](#input\_accept\_routes\_from\_resource\_type) | List of resource types allowed to create routes in this table. Example: 'vpn\_gateway', 'vpn\_server'. | `list(string)` | `[]` | no |
| <a name="input_advertise_routes_to"></a> [advertise\_routes\_to](#input\_advertise\_routes\_to) | Ingress sources to which routes in this table (with advertise enabled) should be advertised. Allowed values: direct\_link, transit\_gateway. Requires corresponding ingress flag to be true. | `list(string)` | `[]` | no |
| <a name="input_create_route_table"></a> [create\_route\_table](#input\_create\_route\_table) | Whether to create a new route table. Ignored if existing\_route\_table\_id is provided | `bool` | `true` | no |
| <a name="input_existing_route_table_id"></a> [existing\_route\_table\_id](#input\_existing\_route\_table\_id) | ID of existing route table to use. If not provided, a new route table will be created | `string` | `null` | no |
| <a name="input_ike_policies"></a> [ike\_policies](#input\_ike\_policies) | List of IKE policies to be created. | <pre>list(object({<br/>    name                     = string<br/>    resource_group           = optional(string)<br/>    ike_version              = optional(number, 2)<br/>    key_lifetime             = optional(number, 28800)<br/>    encryption_algorithm     = string<br/>    authentication_algorithm = string<br/>    dh_group                 = number<br/>  }))</pre> | `[]` | no |
| <a name="input_ipsec_policies"></a> [ipsec\_policies](#input\_ipsec\_policies) | List of IPSec policies to be created. | <pre>list(object({<br/>    name                     = string<br/>    resource_group           = optional(string)<br/>    encryption_algorithm     = string<br/>    authentication_algorithm = string<br/>    pfs                      = string<br/>    key_lifetime             = optional(number, 3600)<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to which to deploy the resources. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to use where you want to create the VPN gateway. | `string` | n/a | yes |
| <a name="input_route_direct_link_ingress"></a> [route\_direct\_link\_ingress](#input\_route\_direct\_link\_ingress) | If true, allows routing table to route traffic from Direct Link into the VPC. | `bool` | `false` | no |
| <a name="input_route_internet_ingress"></a> [route\_internet\_ingress](#input\_route\_internet\_ingress) | If true, allows routing table to route traffic that originates from the Internet. | `bool` | `false` | no |
| <a name="input_route_transit_gateway_ingress"></a> [route\_transit\_gateway\_ingress](#input\_route\_transit\_gateway\_ingress) | If true, allows routing table to route traffic from Transit Gateway into the VPC. | `bool` | `false` | no |
| <a name="input_route_vpc_zone_ingress"></a> [route\_vpc\_zone\_ingress](#input\_route\_vpc\_zone\_ingress) | If true, allows routing table to route traffic from other zones within the VPC. | `bool` | `false` | no |
| <a name="input_routing_table_name"></a> [routing\_table\_name](#input\_routing\_table\_name) | Name of the routing table to create. Only needed when create\_route\_table is true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tags for the resource created | `list(string)` | `null` | no |
| <a name="input_use_existing_ike_policy"></a> [use\_existing\_ike\_policy](#input\_use\_existing\_ike\_policy) | If true, use pre-created IKE policy IDs instead of creating new ones. | `bool` | `false` | no |
| <a name="input_use_existing_ipsec_policy"></a> [use\_existing\_ipsec\_policy](#input\_use\_existing\_ipsec\_policy) | If true, use pre-created IPSec policy IDs instead of creating new ones. | `bool` | `false` | no |
| <a name="input_use_existing_vpn_gateway"></a> [use\_existing\_vpn\_gateway](#input\_use\_existing\_vpn\_gateway) | If true, use a pre-existing VPN Gateway. | `bool` | `false` | no |
| <a name="input_vpn_connections"></a> [vpn\_connections](#input\_vpn\_connections) | List of VPN gateway connections to be created. | <pre>list(object({<br/>    vpn_gateway_name            = optional(string)<br/>    vpn_gateway_id              = optional(string)<br/>    ike_policy_name             = optional(string)<br/>    ipsec_policy_name           = optional(string)<br/>    ike_policy_id               = optional(string)<br/>    ipsec_policy_id             = optional(string)<br/>    vpn_gateway_connection_name = string<br/>    preshared_key               = string<br/>    establish_mode              = optional(string, "bidirectional")<br/>    enable_distribute_traffic   = optional(bool, false)<br/>    is_admin_state_up           = optional(bool, false)<br/>    peer = optional(list(object({<br/>      address = optional(string)<br/>      fqdn    = optional(string)<br/>      ike_identity = list(object({<br/>        type  = string<br/>        value = optional(string)<br/>      }))<br/>    })), [])<br/>    local = optional(list(object({<br/>      ike_identities = list(object({<br/>        type  = string<br/>        value = optional(string)<br/>      }))<br/>    })), [])<br/>    dpd_action         = optional(string, "restart")<br/>    dpd_check_interval = optional(number, 2)<br/>    dpd_max_timeout    = optional(number, 10)<br/>  }))</pre> | n/a | yes |
| <a name="input_vpn_gateways"></a> [vpn\_gateways](#input\_vpn\_gateways) | List of VPN gateways to create. | <pre>list(<br/>    object({<br/>      name              = string<br/>      subnet_id         = string<br/>      mode              = optional(string)<br/>      resource_group_id = optional(string)<br/>      tags              = optional(list(string), [])<br/>    })<br/>  )</pre> | `[]` | no |
| <a name="input_vpn_routes"></a> [vpn\_routes](#input\_vpn\_routes) | List of routes to create in the table. | <pre>list(object({<br/>    name             = string<br/>    zone             = string<br/>    vpc_id           = string<br/>    destination      = string<br/>    next_hop         = string<br/>    vpn_gateway_name = optional(string)<br/>    action           = optional(string, "delegate")<br/>    advertise        = optional(bool, false)<br/>    priority         = optional(number, 2)<br/>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ike_policies"></a> [ike\_policies](#output\_ike\_policies) | List of IKE Policies. |
| <a name="output_ipsec_policies"></a> [ipsec\_policies](#output\_ipsec\_policies) | List of IPSec Policies. |
| <a name="output_vpn_connections"></a> [vpn\_connections](#output\_vpn\_connections) | List of VPN connections. |
| <a name="output_vpn_gateways"></a> [vpn\_gateways](#output\_vpn\_gateways) | List of VPN gateways. |
| <a name="output_vpn_route_tables"></a> [vpn\_route\_tables](#output\_vpn\_route\_tables) | VPN routing tables created per VPC. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
