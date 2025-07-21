# Description

This nested submodule is responsible to create and customize **custom IPsec policies** in IBM Cloud VPC, to be used with VPN connections. IBM supports default policy negotiation, but this sub-module enables fine‑tuned control when interoperability or compliance is required.

## Features

- Define IPsec parameters: encryption (including GCM), authentication or disabled for GCM, optional PFS group and key lifetime.

## When to Use

Use this module if your on-prem or third-party peer requires specific cryptographic settings unsupported by IBM’s auto‑negotiation—for example, compatibility with Cisco, Juniper, Microsoft VPN devices.

## Example Usage

```hcl
module "policies" {
  source             = "../modules/vpn_policies/ipsec_policy"
  resource_group     = "rg123...." # Enter the resource group id

  # IPSec Policy Configuration
  ipsec_policy_name         = "ipsec-policy-001"
  ipsec_encryption_algorithm = "aes128gcm16"
  ipsec_authentication_algorithm = "disabled"
  ipsec_pfs                = "disabled"
}
```
