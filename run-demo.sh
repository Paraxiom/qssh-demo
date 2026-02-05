#!/bin/bash
# One-click demo: starts server, connects, cleans up
#
# Prerequisites: cargo install qssh

DEMO_DIR="$(dirname "$0")"

# Kill any existing qsshd
pkill -f qsshd 2>/dev/null
sleep 1

echo "[1/3] Starting qsshd server..."
qsshd \
    --listen 127.0.0.1:4242 \
    --host-key "$DEMO_DIR/server/host_key" \
    --authorized-keys "$DEMO_DIR/server/authorized_keys" \
    &>/dev/null &

sleep 2
echo "      Server running on localhost:4242"
echo ""

echo "[2/3] Host key (SPHINCS+):"
echo "      $(cat "$DEMO_DIR/server/host_key.pub" | cut -c1-60)..."
echo ""

echo "[3/3] Connecting with qssh..."
echo ""
qssh -p 4242 --verbose $USER@localhost
echo ""

# Cleanup
pkill -f qsshd 2>/dev/null
echo "Demo complete."
