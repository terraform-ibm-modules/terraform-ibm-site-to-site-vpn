# Description

This submodule can be used to create a **VPN Gateway Connection** between a VPN gateway and a peer network. Supports advanced configuration options for interoperability, networking scenarios, and policy enforcement.

## Features

- Attach your connection to an existing VPN gateway
- Optional custom **IKE and IPsec policies**
- Configurable **Dead Peer Detection (DPD)** parameters
- Support for **local and peer IKE identities** (FQDN, IP, base64 key ID)
- Control **establish_mode** (`bidirectional` or `peer_only`) and optional `distribute_traffic` for route-based VPNs

## Example Usage

```hcl
module "vpn_gw_connection" {
  source                        = "../modules/gateway_connection"
  vpn_gateway_connection_name   = "vpn-conn-1"
  vpn_gateway                   = module.vpn_gateway.gateway_id
  preshared_key                 = var.preshared_key
  ike_policy_id                 = var.ike_policy_id
  ipsec_policy_id               = var.ipsec_policy_id
  is_admin_state_up             = true

  local {
    ike_identities {
      type  = "fqdn"
      value = "vpn.local.example"
    }
    ike_identities {
      type  = "fqdn"
      value = "vpn.local.secondary.example"
    }
  }

  peer {
    address = "192.0.2.1"
    ike_identity {
      type  = "fqdn"
      value = "peer.example.com"
    }
  }
}

```
