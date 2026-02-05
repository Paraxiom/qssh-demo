#!/bin/bash
# qssh Demo Server
# Starts qsshd with SPHINCS+ host authentication
#
# Prerequisites: cargo install qssh

DEMO_DIR="$(dirname "$0")"

qsshd \
    --listen 127.0.0.1:4242 \
    --host-key "$DEMO_DIR/server/host_key" \
    --authorized-keys "$DEMO_DIR/server/authorized_keys" \
    --verbose

