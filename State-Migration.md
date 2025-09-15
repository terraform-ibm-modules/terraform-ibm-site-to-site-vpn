# State Migration Guide

* In previous releases, this module supported only a single VPN connection. With the latest release, the module now supports a **list of VPN connections**.
* As a result, the resource addresses in Terraform state have changed, and a one-time migration step is required.
* Without this migration, Terraform may attempt to recreate existing VPN connections, which can cause downtime.

Mentioned below are the steps to ensure a smooth migration: 

## 1. Prepare for Migration

Ensure your current deployment is up to date on the `main` branch:

```bash
terraform plan
terraform apply
```

Take a backup of your state file:

```bash
terraform state pull > backup.json
```

Switch to the branch or release that includes the new changes.

## 2. Identify Affected Resources

Run the following command to inspect the current state:

```bash
terraform state list
```

Compare the output between:
Current (old) release → resources without list indices.

Example:

```bash
module.vpn_gateway_site_b.ibm_is_vpn_gateway_connection.vpn_site_to_site_connection
```

New release → resources indexed by connection name.

Example:

```bash
module.vpn_gateway_site_b.ibm_is_vpn_gateway_connection.vpn_site_to_site_connection["ps2-vpn-conn-b-to-a"]
```

## 3. Migrate the State

For each resource that has changed, use the terraform state mv command.

Example migration:

```bash
terraform state mv \
  'module.vpn_gateway_site_b.ibm_is_vpn_gateway_connection.vpn_site_to_site_connection' \
  'module.vpn_gateway_site_b.ibm_is_vpn_gateway_connection.vpn_site_to_site_connection["ps2-vpn-conn-b-to-a"]'
```

Successful output looks like this:

```bash
Move "module.vpn_gateway_site_b.ibm_is_vpn_gateway_connection.vpn_site_to_site_connection" to "module.vpn_gateway_site_b.ibm_is_vpn_gateway_connection.vpn_site_to_site_connection[\"ps2-vpn-conn-b-to-a\"]"
Successfully moved 1 object(s).
```

## 4. Verify Migration

Run:

```bash
terraform plan
```

Ensure that no VPN connection resources are recreated or destroyed.

If everything looks good, proceed with:

``` bash
terraform apply
```

Please note:

* Perform this migration step once per environment.
* Always back up the state file before running terraform state mv.


### Variables Update (Breaking Change)

In earlier releases, each VPN connection was defined using individual variables such as:

`vpn_gateway_connection_name`, `preshared_key`, `peer_config`, `local_config`, `establish_mode` , `enable_distribute_traffic`, `is_admin_state_up` , `dpd_action`, `dpd_check_interval`, `dpd_max_timeout`

Only one VPN connection per module instance was supported.

**New Input Model:**

The module now introduces a single consolidated variable:

```hcl
variable "vpn_connections" {
  description = "List of VPN connections to attach to the VPN gateway."
  type        = list(object({ ... }))
  ...
}
```

This allows you to define multiple VPN connections in a single module instance.
Each object inside the list represents one connection, with all required and optional fields grouped together.

### Migration Guidance

Map old variables to the new structure. Below is the conversion Example for easy reference.

**Before (old variables):**

```hcl

module "vpn_gateway_site_b" {
  source = "..."

  vpn_gateway_connection_name = "ps2-vpn-conn-b-to-a"
  preshared_key               = "MySecret123"
  establish_mode              = "bidirectional"
  enable_distribute_traffic   = false
  is_admin_state_up           = true
  dpd_action                  = "restart"

  peer_config = [{
    address = "203.0.113.10" # some random IP address for explanation
    cidrs   = ["10.10.0.0/16"] # some random CIDR for explanation
    ike_identity = [{
      type  = "fqdn"
      value = "peer.example.com"
    }]
  }]

  local_config = [{
    cidrs = ["10.20.0.0/16"] # some random local cidr config
    ike_identities = [{
      type  = "hostname"
      value = "local.example.com"
    }]
  }]
}
```

**After (new list-based variable):**

```hcl
module "vpn_gateway_site_b" {
  source = "..."

  vpn_connections = [{
    name                      = "ps2-vpn-conn-b-to-a"
    preshared_key             = "MySecret123"
    establish_mode            = "bidirectional"
    enable_distribute_traffic = false
    is_admin_state_up         = true
    dpd_action                = "restart"

    peer_config = [{
      address = "203.0.113.10"
      cidrs   = ["10.10.0.0/16"]
      ike_identity = [{
        type  = "fqdn"
        value = "peer.example.com"
      }]
    }]

    local_config = [{
      cidrs = ["10.20.0.0/16"]
      ike_identities = [{
        type  = "hostname"
        value = "local.example.com"
      }]
    }]
  }]
}
```

### Relation to State Migration

Because resources are now indexed by the name field in `vpn_connections`, you must also run the state migration step as described above. 

This ensures Terraform links your existing resource to the correct object in the new variable structure.

With this update, one can now define multiple VPN connections in single module call.