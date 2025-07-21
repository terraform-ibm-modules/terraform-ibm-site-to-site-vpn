# Description

This nested submodule is responsible to create and customize the **custom IKE and policies** in IBM Cloud VPC, to be used with VPN connections. IBM supports default policy negotiation, but this sub-module enables fine‑tuned control when interoperability or compliance is required.

## Features

- Define IKE (IKEv1 or IKEv2) parameters: version, encryption, authentication, DH group, key lifetime.

## When to Use

Use this module if your on-prem or third-party peer requires specific cryptographic settings unsupported by IBM’s auto‑negotiation—for example, compatibility with Cisco, Juniper, Microsoft VPN devices.

## Example Usage

```hcl
module "policies" {
  source             = "./modules/vpn_policies/ike_policy"
  resource_group     = "rg123...." # Enter the resource group id

  # IKE Policy Configuration
  ike_policy_name         = "ike-policy-001"
  ike_encryption_algorithm = "aes256"
  ike_authentication_algorithm = "sha512"
  ike_dh_group            = 14
  ike_version             = 2
}
```
