#!/bin/bash

# Simple VPN Connectivity Test Script
# This script tests if two VSIs can communicate through a VPN tunnel

set -e

cleanup() {
    if [ -f "$TMP_SSH_KEY" ]; then
        rm -f "$TMP_SSH_KEY"
    fi
}

trap cleanup EXIT

echo "=============================================="
echo "Starting VPN Connectivity Test..."
echo "=============================================="

SITE_A_IP=$1
SITE_B_IP=$2
SSH_KEY=$3
SSH_USER="${SSH_USER:-root}"

echo "Site A private IP: $SITE_A_IP \n Site B private IP: $SITE_B_IP"
echo ""

TMP_SSH_KEY="/tmp/vpn_test_key_$$" # appending the process id
cp "$SSH_KEY" "$TMP_SSH_KEY"
chmod 600 "$TMP_SSH_KEY"
SSH_OPTIONS="-i $TMP_SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 -o BatchMode=yes -q"

# Check whether both sites are accessible or not.
echo "Testing SSH connection to Site A..."
if ssh $SSH_OPTIONS "${SSH_USER}@${SITE_A_IP}" "echo 'Connected'" >/dev/null 2>&1 ; then
    echo "SUCCESS: Connected to Site A."
else
    echo "FAILED: Unable to connect to Site A."
    exit 2
fi

echo "Testing SSH connection to Site B..."
if ssh $SSH_OPTIONS "${SSH_USER}@${SITE_B_IP}" "echo 'Connected'" >/dev/null 2>&1 ; then
    echo "SUCCESS: Connected to Site B."
else
    echo "FAILED: Unable to connect to Site B."
    exit 2
fi

echo "SSH connections successful."
echo "=============================================="

# If both sites are accessible, verify the connectivity among sites.
echo "Testing ping from Site A to Site B..."
if ssh $SSH_OPTIONS "${SSH_USER}@${SITE_A_IP}" "ping -c 3 $SITE_B_IP" >/dev/null 2>&1; then
    echo "SUCCESS: Site A can ping Site B."
else
    echo "FAILED: Site A cannot ping Site B."
    exit 1
fi

echo "Testing ping from Site B to Site A..."
if ssh $SSH_OPTIONS "${SSH_USER}@${SITE_B_IP}" "ping -c 3 $SITE_A_IP" >/dev/null 2>&1; then
    echo "SUCCESS: Site B can ping Site A."
else
    echo "FAILED: Site B cannot ping Site A."
    exit 2
fi

echo "=============================================="
echo "VPN Connectivity Test COMPLETED SUCCESSFULLY"
echo "=============================================="
