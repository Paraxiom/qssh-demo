#!/bin/bash
# qssh Demo Client - KPMG Presentation
# Connects using Falcon-512 user key to SPHINCS+ server

DEMO_DIR="$(dirname "$0")"

echo "============================================"
echo "  qssh Demo Connection"
echo "  Post-Quantum SSH Client"
echo "============================================"
echo ""
echo "User key: Falcon-512 (NTRU lattice)"
echo "Server host key: SPHINCS+ (hash-based)"
echo "Key exchange: ML-KEM + X25519 (hybrid)"
echo ""
echo "Connecting to localhost:4242..."
echo ""

# Set identity file location
export QSSH_IDENTITY="$DEMO_DIR/client/id_qssh"

qssh -p 4242 --verbose $USER@localhost
