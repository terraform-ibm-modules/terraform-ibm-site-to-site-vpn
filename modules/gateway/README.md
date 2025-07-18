# Description

Provisions a **site-to-site VPN gateway** in IBM Cloud VPC, attached to a specific VPC and subnet. Supports both **route-based** (active‑active) and **policy-based** (active‑standby) modes.

## Features

- Attach a VPN gateway to a VPC and a specific subnet  
- Supports route-based and policy-based modes  
- Optional service-to-service IAM authorization policy for cross-account or securely scoped access  
- Uses IBM platform naming rules and enforces VPC-specific limits (such as one route‑based gateway per zone per VPC)

## Inputs

| Name                                | Description                                               | Required | Default   |
|-------------------------------------|-----------------------------------------------------------|----------|-----------|
| `name`                              | VPN gateway name (must be unique within the same VPC)     | yes      | –         |
| `vpc_id`                            | ID of the VPC to associate the gateway with                | yes      | –         |
| `subnet_id`                         | Subnet ID where the gateway will be provisioned            | yes      | –         |
| `resource_group_id`                 | Resource group ID                                         | yes      | –         |
| `mode`                              | VPN mode: `"route"` or `"policy"`                          | no       | `route`   |
| `tags`                              | Map of tags attached as `"key:value"`                     | no       | `{}`      |
| `enable_service_to_service_authz`   | Create IAM policy between VPC service and VPN infrastructure | no       | `false`   |
| `target_service_name`               | Target service name for IAM authorization (`is` default)   | no       | `is`      |

## Outputs

- `gateway_id`: ID of the VPN gateway  
- `public_ip`: Public IP address assigned to the gateway  
- `crn`: CRN of the gateway resource

## Example Usage

```hcl
module "vpn_gateway" {
  source                        = "../modules/gateway"
  name                          = "my-vpn-gateway"
  vpc_id                        = var.vpc_id
  subnet_id                     = var.subnet_id
  resource_group_id             = var.resource_group_id
  mode                          = "route"
  tags                          = { env = "prod" }
  enable_service_to_service_authz = true
}
```

## Important Notes

- Route-based VPN supports Active‑Active tunnels and requires connection modules to configure distribute_traffic.

- Only one route-based VPN gateway per zone per VPC is supported by IBM.

- Gateway name must be unique per VPC to avoid provisioning errors.

- Use service-to-service authorization when connecting with other IBM Cloud services securely across accounts or services.

## IBM Cloud References

- Overview of site‑to‑site VPN gateways.
- Creating a VPN gateway in IBM Cloud
