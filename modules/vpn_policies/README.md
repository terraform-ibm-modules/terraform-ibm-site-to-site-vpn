# Description

Creates **custom IKE and IPsec policies** in IBM Cloud VPC, to be used with VPN connections. IBM supports default policy negotiation, but this sub-module enables fine‑tuned control when interoperability or compliance is required.

## Features

- Define IKE (IKEv1 or IKEv2) parameters: version, encryption, authentication, DH group, key lifetime.  
- Define IPsec parameters: encryption (including GCM), authentication or disabled for GCM, optional PFS group and key lifetime.  

## When to Use

Use this module if your on-prem or third-party peer requires specific cryptographic settings unsupported by IBM’s auto‑negotiation—for example, compatibility with Cisco, Juniper, Microsoft VPN devices.

## Example Usage

```hcl
module "policies" {
  source             = "../modules/vpn_policies"
  resource_group     = "Default"

  # IKE Policy Configuration
  ike_policy_name         = "ike-policy-001"
  ike_encryption_algorithm = "aes256"
  ike_authentication_algorithm = "sha512"
  ike_dh_group            = 14
  ike_version             = 2

  # IPSec Policy Configuration
  ipsec_policy_name         = "ipsec-policy-001"
  ipsec_encryption_algorithm = "aes128gcm16"
  ipsec_authentication_algorithm = "disabled"
  ipsec_pfs                = "disabled"
}
```
