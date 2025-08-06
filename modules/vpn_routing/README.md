# VPN Routes

This submodule provisions IBM Cloud VPC Routing Table with optional ingress configurations and one or more custom route entries — ideal for VPN Gateway integration. It supports both single-route and multi-route creation using a flag.

---

## Features

- Creates VPC Routing Table with custom name, tags, ingress flags
- Supports routing from Direct Link, Transit Gateway, VPC zones, or Internet
- Optional advertisement of routes to specific ingress sources
- Supports single route creation or bulk routes using `for_each`
- Outputs full routing table and route metadata

## Example Usage

**Create VPN Routing Table:**

This example shows how to provision a VPC routing table without defining any custom routes. It's useful when you want to manage routes separately or attach subnets later.

```hcl
module "vpn_routing_table" {
  source = "./modules/vpn_routes"
  routing_table_name            = "vpn-base-table"
  vpc_id                        = "vpc-abc123"
  access_tags                   = ["env:shared"]
  tags                          = ["test"]
  advertise_routes_to           = ["direct_link", "transit_gateway"]
  accept_routes_from_resource_type = ["vpn_gateway"]
  route_direct_link_ingress     = true
  route_transit_gateway_ingress = true
  route_vpc_zone_ingress        = false
  route_internet_ingress        = false
}
```

**Single Route Creation with Routing Table:**

This example shows how to attach a single custom route for traffic heading to a peer network via VPN Gateway.

```hcl
module "vpn_routes_single" {
  source = "./modules/vpn_routes"

  vpc_id                        = "vpc-abc123"
  routing_table_name            = "vpn-table-single"
  route_transit_gateway_ingress = true
  route_direct_link_ingress     = false
  route_vpc_zone_ingress        = false
  route_internet_ingress        = false

  access_tags                   = ["env:dev", "network:vpn"]
  advertise_routes_to           = ["transit_gateway"]

  enable_multiple_routes        = false

  route_name        = "to-peer-dc"
  route_zone        = "jp-tok-1"
  route_destination = "172.16.0.0/16"
  route_next_hop    = "vpn-conn-id-abc123"
  route_action      = "deliver"
  route_advertise   = true
  route_priority    = 1
}
```

**Create Multiple Routes:**
This example shows how to attach multiple custom routes in one go for traffic heading to a peer network via VPN Gateway.

```hcl
module "vpn_routes_bulk" {
  source = "./modules/vpn_routes"

  vpc_id                        = "vpc-abc123"
  routing_table_name            = "vpn-bulk-table"
  access_tags                   = ["env:prod", "network:vpn"]
  route_direct_link_ingress     = true
  route_transit_gateway_ingress = true
  advertise_routes_to           = ["direct_link", "transit_gateway"]
  enable_multiple_routes            = true

  routes = [
    {
      name        = "to-data-center-1"
      zone        = "jp-tok-1"
      destination = "192.168.10.0/24"
      next_hop    = "vpn-conn-id-123"
      action      = "deliver"
      advertise   = true
      priority    = 1
    },
    {
      name        = "to-data-center-2"
      zone        = "jp-tok-2"
      destination = "192.168.20.0/24"
      next_hop    = "vpn-conn-id-456"
      action      = "deliver"
      advertise   = false
      priority    = 2
    }
  ]
}
```

## Notes

- When using `advertise_routes_to`, ensure matching ingress flags (e.g. direct_link requires route_direct_link_ingress = true)
- Route names must be unique within a routing table.
- You can use either routes list or individual route inputs, but not both simultaneously.
