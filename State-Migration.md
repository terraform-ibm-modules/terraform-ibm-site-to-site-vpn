# State Migration Guide

<details>

<summary> Migration path: v1 to v2 </summary>
<br/>

* In previous releases, this module supported only a single VPN connection. With the latest release, the module now supports a **list of VPN connections**.
* As a result, the resource addresses in Terraform state have changed, and a one-time migration step is required.

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

</details>

----

<details>

  <summary>Migration path: v2 to v3</summary>
<br/>
The v3 version incorporates the creation of IKE and IPSec policies per connection. This requires change in the `vpn_connections` variable to carry along the IKE and IPSec policies configuration per connection.

* In previous release, this module supported **list of VPN connections** but the creation of IKE and IPSec policies were done only once and was same for all connections.
* Now in this release, IKE and IPSec policies can be created per connection or provide existing ID per connection.
* As a result, the resource addresses in Terraform state have changed, and a one-time migration step is required.

## 1. Prepare Migration

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

## 2. Identify Resources that are affected

Run the following command to inspect the current state:

```bash
terraform state list
```

Compare the output between:
Current (old) release → resources without list indices.

Example:

```bash
module.vpn_gateway_single_site.module.vpn_policies[0].ibm_is_ike_policy.ike
```

New release → resources indexed by connection name.

Example:

```bash
module.vpn_gateway_single_site.module.vpn_policies[0].ibm_is_ike_policy.ike["ss-vpn-conn"]
```

## 3. State migration

For each resource that has changed, use the terraform state mv command.

Example migration:

```bash
terraform state mv \
  'module.vpn_gateway_single_site.module.vpn_policies[0].ibm_is_ike_policy.ike' \
  'module.vpn_gateway_single_site.module.vpn_policies[0].ibm_is_ike_policy.ike["ss-vpn-conn"]'
```

```bash
terraform state mv \
  'module.vpn_gateway_single_site.module.vpn_policies[0].ibm_is_ipsec_policy.ipsec' \
  'module.vpn_gateway_single_site.module.vpn_policies[0].ibm_is_ipsec_policy.ipsec["ss-vpn-conn"]'
```

Successful output looks like this:

```bash
Move "module.vpn_gateway_single_site.module.vpn_policies[0].ibm_is_ike_policy.ike" to "module.vpn_gateway_single_site.module.vpn_policies[0].ibm_is_ike_policy.ike[\"ss-vpn-conn\"]"
Successfully moved 1 object(s).
```

```bash
Move "module.vpn_gateway_single_site.module.vpn_policies[0].ibm_is_ipsec_policy.ipsec" to "module.vpn_gateway_single_site.module.vpn_policies[0].ibm_is_ipsec_policy.ipsec[\"ss-vpn-conn\"]"
Successfully moved 1 object(s).
```

## 4. Migration verification

Run:

```bash
terraform plan
```

Ensure that no IKE or IPSec policy resources are recreated or destroyed.

If everything looks good, proceed with:

``` bash
terraform apply
```

Please note:

* Perform this migration step once per environment.
* Always back up the state file before running terraform state mv.


### Update (Breaking Change)

* In earlier releases, each IKE and IPSec configuration were defined using individual variables but now these variables are included as part of separate IKE and IPSec configuration object.

* One flag to create VPN policies was used for creation of both IKE and IPSec policies.

**New Input Model:**

* Two new flags i.e. `create_ike_policy` and `create_ipsec_policy` are now added and the previous flag i.e. `create_vpn_policies` is removed to allow creation of individual IKE/IPSec policies.

The module now includes IKE and IPSec policy configuration in the `vpn_connections` variable :

```hcl
variable "vpn_connections" {
  description = "List of VPN connections to attach to the VPN gateway."
  type        = list(object({ ... }))
  ...

  ike_policy_config = optional(object({
    name                     = string
    authentication_algorithm = string # sha256, sha384, sha512
    encryption_algorithm     = string # aes128, aes192, aes256
    dh_group                 = number # 14-24, 31
    ike_version              = optional(number, 2)
    key_lifetime             = optional(number, 28800)
  }), null) # Provide config only if create_ike_policy is true

  # IPSec policy
  create_ipsec_policy      = optional(bool, false)  # Flag to create new IPSec policy
  existing_ipsec_policy_id = optional(string, null) # ID of existing IPSec policy to use (mutually exclusive with create_ipsec_policy)

  ipsec_policy_config = optional(object({
    name                     = string
    encryption_algorithm     = string # aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16
    authentication_algorithm = string # sha256, sha384, sha512, disabled
    pfs                      = string # disabled, group_2, group_5, group_14
    key_lifetime             = optional(number, 3600)
  }), null) # Provide config only if create_ipsec_policy is true
}
```

This allows you to define multiple VPN connections in a single module instance.
Each object inside the list represents one connection, with all required and optional fields grouped together.

### Example Guidance

Map old variables to the new structure. Below is the conversion Example for easy reference.

**Before (old variables):**

```hcl

module "vpn_gateway_single_site" {
  source = "../.."

  # VPN Gateway
  create_vpn_gateway    = true
  vpn_gateway_name      = local.vpn_gw_name
  vpn_gateway_subnet_id = local.subnet_id
  vpn_gateway_mode      = "policy" # Policy Based VPN

  # Policies creation
  create_vpn_policies = true
  # IKE
  ike_policy_name              = "ss-ike-policy"
  ike_authentication_algorithm = "sha256"
  ike_encryption_algorithm     = "aes256"
  ike_dh_group                 = 14
  # IPSec
  ipsec_policy_name              = "ss-ipsec-policy"
  ipsec_encryption_algorithm     = "aes256"
  ipsec_authentication_algorithm = "sha256"
  ipsec_pfs                      = "group_14"

  # Create VPN Connection
  vpn_connections = [{
    name          = "ss-vpn-conn"
    preshared_key = var.preshared_key
    peer_config = [
      {
        address = "162.133.137.63"
        cidrs   = ["10.100.10.0/24"]
        ike_identity = [
          {
            type  = "ipv4_address"
            value = "162.133.137.63"
          }
        ]
      }
    ]
    local_config = [
      {
        cidrs = ["172.16.10.0/24"]
        ike_identities = [
          {
            type  = "ipv4_address"
            value = local.valid_ip_address  # This refers to valid IP address of VPN Gateway
          }
        ]
      }
    ]
  }]
}
```

**After (new list-based variable):**

```hcl
module "vpn_gateway_single_site" {
  source = "../..

  vpn_connections = [{
    name          = "ss-vpn-conn"
    preshared_key = var.preshared_key

    # Policies (Newly added change)
    create_ike_policy   = true
    create_ipsec_policy = true
    ike_policy_config = {
      name                     = "ss-ike-policy"
      authentication_algorithm = "sha256"
      encryption_algorithm     = "aes256"
      dh_group                 = 14
    }

    # IPSec Policy configuration
    ipsec_policy_config = {
      name                     = "ss-ipsec-policy"
      encryption_algorithm     = "aes256"
      authentication_algorithm = "sha256"
      pfs                      = "group_14"
    }

    peer_config = [
      {
        address = "162.133.137.63"
        cidrs   = ["10.100.10.0/24"]
        ike_identity = [
          {
            type  = "ipv4_address"
            value = "162.133.137.63"
          }
        ]
      }
    ]
    local_config = [
      {
        cidrs = ["172.16.10.0/24"]
        ike_identities = [
          {
            type  = "ipv4_address"
            value = local.valid_ip_address # This refers to valid IP address of VPN Gateway
          }
        ]
      }
    ]
  }]
}
```

</details>
