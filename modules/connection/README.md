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
module "connection" {
  source                        = "../modules/connection"
  vpn_gateway_id                = module.vpn_gateway.gateway_id
  vpn_gateway_connection_name   = "vpn-conn-1"
  preshared_key                 = var.psk
  ike_policy_id                 = module.policies.ike_policy_id
  ipsec_policy_id               = module.policies.ipsec_policy_id

  # Since IBM VPN gateways in static route mode are active-active, should provide two IKE identities—one for each member.
  local_config = [
    {
      ike_identities = [
        {
          type  = "fqdn"
          value = "vpn.local.example"
        },
        {
          type  = "fqdn"
          value = "vpn.local.secondary.example"
        }
      ]
    }
  ]

  peer_config = [
    {
      address = "192.0.2.1"
      ike_identity = [
        {
          type  = "fqdn" # can use either address or fqdn
          value = "peer.example.com"
        }
      ]
    }
  ]
}

```
