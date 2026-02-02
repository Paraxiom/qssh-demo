#!/bin/bash
# One-click demo script for KPMG presentation

DEMO_DIR="$(dirname "$0")"
QSSHD="/Users/sylvaincormier/paraxiom/paraxiom-qssh/target/release/qsshd"

clear
echo "============================================"
echo "  qssh Demo - Post-Quantum SSH"
echo "  KPMG Presentation"
echo "============================================"
echo ""

# Kill any existing qsshd
pkill -f qsshd 2>/dev/null
sleep 1

echo "[1/3] Starting qsshd server with SPHINCS+ host key..."
$QSSHD \
    --listen 127.0.0.1:4242 \
    --host-key "$DEMO_DIR/server/host_key" \
    --authorized-keys "$DEMO_DIR/server/authorized_keys" \
    &>/dev/null &

sleep 2
echo "      Server running on localhost:4242"
echo ""

echo "[2/3] Host key (SPHINCS+ - hash-based, quantum-safe):"
echo "      $(cat $DEMO_DIR/server/host_key.pub | cut -c1-60)..."
echo ""

echo "[3/3] Connecting with qssh (Falcon-512 user key)..."
echo ""
echo "------- Algorithm Negotiation -------"
qssh -p 4242 --verbose $USER@localhost 2>&1 | grep -E "algorithm|signature|public key|keys derived|Session"
echo "--------------------------------------"
echo ""

# Cleanup
pkill -f qsshd 2>/dev/null

echo "Demo complete."
echo ""
echo "Key points shown:"
echo "  - SPHINCS+ host authentication (not in OpenSSH)"
echo "  - Falcon-512 user authentication"
echo "  - PQC-only session key derivation"
