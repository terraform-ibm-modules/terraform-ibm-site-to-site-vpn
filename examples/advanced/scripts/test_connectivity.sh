#!/bin/bash

# This script tests if two VSIs can communicate through a VPN tunnel

set -e

SITE_A_PUB_IP=$1
SITE_B_PUB_IP=$2
SITE_A_IP=$3
SITE_B_IP=$4
SSH_KEY=$5
SSH_USER="${SSH_USER:-ubuntu}"
TMP_SSH_KEY="/tmp/vpn_test_key_$$" # appending the process id

cleanup() {
    rm -f "$TMP_SSH_KEY"
}

trap cleanup EXIT

ssh_key_init() {
    cp "$SSH_KEY" "$TMP_SSH_KEY"
    chmod 600 "$TMP_SSH_KEY"
}

ssh_exec() {
    local site_ip=$1
    local cmd=$2
    ssh -i "$TMP_SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 -o BatchMode=yes -q "${SSH_USER}@${site_ip}" "$cmd"
}

test_ssh_connection() {
    local site_name=$1
    local site_ip=$2

    echo "Testing SSH connection to $site_name..."

    if ssh_exec "$site_ip" "echo 'Connected'" >/dev/null; then
        echo "SUCCESS: Connected to $site_name."
    else
        echo "FAILED: Unable to connect to $site_name."
        exit 1
    fi
}

test_ping() {
    local source_name=$1
    local source_ip=$2
    local destination_name=$3
    local destination_ip=$4

    echo "Testing ping from $source_name to ${destination_name}..."

    if ssh_exec "$source_ip" "ping -c 3 $destination_ip" >/dev/null 2>&1; then
        echo "SUCCESS: $source_name can ping $destination_name."
    else
        echo "FAILED: $source_name cannot ping $destination_name."
        exit 2
    fi
}

main() {
    echo "=============================================="
    echo "Starting VPN Connectivity Test..."
    echo "=============================================="

    echo "Site A IP address: $SITE_A_IP"
    echo "Site B IP address: $SITE_B_IP"
    echo ""

    ssh_key_init

    test_ssh_connection "Site A" "$SITE_A_PUB_IP"
    test_ssh_connection "Site B" "$SITE_B_PUB_IP"

    echo "SSH connections successful."
    echo "=============================================="

    test_ping "Site A" "$SITE_A_IP" "Site B" "$SITE_B_IP"
    test_ping "Site B" "$SITE_B_IP" "Site A" "$SITE_A_IP"

    echo "=============================================="
    echo "VPN Connectivity Test COMPLETED SUCCESSFULLY"
    echo "=============================================="
}

main
