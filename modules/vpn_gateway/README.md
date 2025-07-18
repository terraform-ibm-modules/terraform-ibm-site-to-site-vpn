# Description

This submodule can provision **VPN Gateway** in IBM Cloud VPC, attached to a specific subnet. Supports both **route-based** (active‑active) and **policy-based** (active‑standby) modes.

## Features

- Attach a VPN gateway to a VPC and a specific subnet  
- Supports route-based and policy-based modes  
- Optional service-to-service IAM authorization policy for cross-account or securely scoped access  
- Uses IBM platform naming rules and enforces VPC-specific limits (such as one route‑based gateway per zone per VPC)

## Example Usage

```hcl
module "vpn_gateway" {
  source                        = "../modules/gateway"
  name                          = "s2s-vpn-gateway"
  subnet_id                     = "sn2..." # replace with subnet id value.
  resource_group_id             = "rg123..." # replace with resource group id.
  tags                          = { env = "prod" }
}
```

## Important Notes

- Route-based VPN supports **Active‑Active** tunnels and requires connection modules to configure distribute_traffic.

- Only one route-based VPN gateway per zone per VPC is supported by IBM.

- Gateway name must be unique per VPC to avoid provisioning errors.

## IBM Cloud References

- [Overview of site‑to‑site VPN gateways](https://cloud.ibm.com/docs/vpc?topic=vpc-using-vpn&interface=ui)
- [Creating a VPN gateway in IBM Cloud](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-create-gateway&interface=terraform)
