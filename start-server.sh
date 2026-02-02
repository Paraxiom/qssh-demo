#!/bin/bash
# qssh Demo Server - KPMG Presentation
# Starts qsshd with SPHINCS+ host authentication

DEMO_DIR="$(dirname "$0")"
QSSHD="/Users/sylvaincormier/paraxiom/paraxiom-qssh/target/release/qsshd"

echo "============================================"
echo "  qssh Demo Server"
echo "  Post-Quantum SSH with SPHINCS+ Host Auth"
echo "============================================"
echo ""
echo "Host key algorithm: SPHINCS+ (hash-based, quantum-safe)"
echo "Listening on: localhost:4242"
echo ""

$QSSHD \
    --listen 127.0.0.1:4242 \
    --host-key "$DEMO_DIR/server/host_key" \
    --authorized-keys "$DEMO_DIR/server/authorized_keys" \
    --verbose

