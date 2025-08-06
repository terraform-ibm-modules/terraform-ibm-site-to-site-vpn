# Description

This nested submodule is responsible to create and customize the **custom IKE and IPSec policies** in IBM Cloud VPC, to be used with VPN connections. IBM supports default policy negotiation, but this sub-module enables fine‑tuned control when interoperability or compliance is required.

## Features

- Define IKE (IKEv1 or IKEv2) parameters: version, encryption, authentication, DH group, key lifetime.
- Define IPsec parameters: encryption (including GCM), authentication or disabled for GCM, optional PFS group and key lifetime.

## Example Usage

```hcl
module "policies" {
  source             = "../modules/vpn_policies"
  resource_group     = "rg123...." # Enter the resource group id
  ike_policies = [
    {
      name                     = "eg-ike"
      encryption_algorithm     = "aes256"
      authentication_algorithm = "sha256"
      dh_group                 = 14
    }
  ]

  ipsec_policies = [
    {
      name                     = "eg-ipsec"
      encryption_algorithm     = "aes256"
      authentication_algorithm = "sha256"
      pfs                      = "disabled"
    }
  ]
}
```
