# Description

This submodule is responsible to create and customize the **custom IKE and IPSec policies** in IBM Cloud VPC, to be used with VPN connections. IBM supports default policy negotiation, but this sub-module enables fine‑tuned control when interoperability or compliance is required.

## Features

- Flexibility to create only IKE or IPSec policy for multiple connections.
- Define IKE (IKEv1 or IKEv2) parameters: version, encryption, authentication, DH group, key lifetime.
- Define IPsec parameters: encryption (including GCM), authentication or disabled for GCM, optional PFS group and key lifetime.

## Example Usage

```hcl
module "vpn_policies" {
  count          = length([for conn in var.vpn_connections : conn if conn.create_ike_policy || conn.create_ipsec_policy]) > 0 ? 1 : 0
  source         = "../modules/vpn_policies"
  resource_group = "rg123..." # Replace with your resource group ID

  vpn_connections = [
    {
      name = "vpn-conn-1" # Name of first VPN Connection

      # IKE Policy
      create_ike_policy      = true
      ike_policy_config = {
        name                     = "ike-policy-1" # Name of IKE policy
        authentication_algorithm = "sha256"
        encryption_algorithm     = "aes256"
        dh_group                 = 14
        version                  = 2
        key_lifetime             = 1800
      }

      # IPSec Policy
      create_ipsec_policy      = true
      ipsec_policy_config = {
        name                     = "ipsec-policy-1" # Name of IPSec policy
        encryption_algorithm     = "aes128gcm16"
        authentication_algorithm = "sha256"
        pfs                      = "disabled"
        key_lifetime             = 300
      }
    },
    {
      name = "vpn-conn-2" # Name of second VPN Connection
      # Reuse existing policies
      existing_ike_policy_id = "existing-ike-id" # Existing IKE Policy id
      existing_ipsec_policy_id = "existing-ipsec-id" # Existing IPSec Policy id
    }
  ]
}
```

> When `create_ike_policy = true`, `ike_policy_config` must be provided with all required fields. Otherwise, supply `existing_ike_policy_id`. Same applies for `IPSec`.
