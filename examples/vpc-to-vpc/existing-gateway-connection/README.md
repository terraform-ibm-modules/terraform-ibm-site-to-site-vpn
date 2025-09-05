# Simple Test: Adding Connection to Existing VPN Gateway

This is a **simplified test example** to verify that the module works correctly when `create_vpn_gateway = false`.

## Purpose

Test that the module can:
- Add a new VPN connection to an existing gateway
- Return `null` for VPN gateway outputs (proving the fix works)
- Successfully create the connection and related resources
