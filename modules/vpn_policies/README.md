# Description

This submodule is responsible to create and customize the **custom IKE and IPSec policies** in IBM Cloud VPC, to be used with VPN connections. IBM supports default policy negotiation, but this sub-module enables fine‑tuned control when interoperability or compliance is required.

## Features

- Define IKE (IKEv1 or IKEv2) parameters: version, encryption, authentication, DH group, key lifetime.
- Define IPsec parameters: encryption (including GCM), authentication or disabled for GCM, optional PFS group and key lifetime.

## Example Usage

```hcl
module "policies" {
  source                          = "../modules/vpn_policies"
  resource_group                  = "rg123...." # Enter your resource group id

  ike_policy_name                 = "eg-ike" # Name of your IKE Policy
  ike_authentication_algorithm    = "sha256"
  ike_encryption_algorithm.       = "aes256"
  ike_dh_group                    = 14
  ike_version                     = 2
  ike_key_lifetime                = 1800

  ipsec_policy_name               = "eg-ipsec" # Name of your IPSec Policy
  ipsec_authentication_algorithm  = "sha256"
  ipsec_encryption_algorithm      = "aes128gcm16"
  ipsec_pfs                       = "disabled"
  ipsec_key_lifetime              = 300
}
```
