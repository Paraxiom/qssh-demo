# qssh Demo

Post-quantum SSH demonstration using SPHINCS+ host authentication and Falcon user keys.

## Prerequisites

- [qssh](https://crates.io/crates/qssh) installed (`cargo install qssh`)
- [qsshd](https://github.com/Paraxiom/paraxiom-qssh) server binary

## Setup

### 1. Start the server

```bash
./start-server.sh
```

This starts `qsshd` on port 4242 with:
- SPHINCS+ host key (`server/host_key`)
- Authorized Falcon keys (`server/authorized_keys`)

### 2. Connect

```bash
./connect.sh
```

Or manually:

```bash
qssh -p 4242 --verbose $USER@localhost
```

### One-click demo

```bash
./run-demo.sh
```

Starts the server, connects, and shows algorithm negotiation output.

## Key Files

| File | Algorithm | Purpose |
|------|-----------|---------|
| `server/host_key` | SPHINCS+ | Host authentication (quantum-safe) |
| `client/id_qssh` | Falcon-512 | User authentication |
| `server/authorized_keys` | - | Authorized user public keys |

## What This Demonstrates

- **SPHINCS+ host authentication** - OpenSSH uses Ed25519/RSA for host keys; qssh uses hash-based PQ signatures
- **Falcon user keys** - Lattice-based signatures for user identity
- **PQ-only session keys** - Key exchange using ML-KEM

## Links

- qssh: [crates.io/crates/qssh](https://crates.io/crates/qssh)
- Documentation: [docs.rs/qssh](https://docs.rs/qssh)
- Paraxiom: [paraxiom.org](https://paraxiom.org)
