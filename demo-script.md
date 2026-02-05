# qssh Demo Walkthrough

## 0. Prerequisites — Install Rust and qssh

Install Rust (if not already installed):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

Install qssh from crates.io:

```bash
cargo install qssh
# If an older version is already installed:
cargo install qssh --force
```

Verify the installation:

```bash
qssh --version
qssh-keygen --help
```

## 1. Start the server

```bash
cd ~/qssh-demo
qsshd \
    --listen 127.0.0.1:4242 \
    --host-key ./server/host_key \
    --authorized-keys ./server/authorized_keys \
    --verbose
```

This starts `qsshd` on port 4242 with a SPHINCS+ host key.

## 2. Key Exchange Algorithms

qssh now supports multiple post-quantum key exchange algorithms:

| Algorithm | NIST Level | Use Case |
|-----------|------------|----------|
| `falcon-signed` | - | Legacy, backward-compatible |
| `mlkem768` | Level 3 | FIPS 203 compliant, recommended |
| `mlkem1024` | Level 5 | Maximum security margin |
| `hybrid` | Level 3 | X25519 + ML-KEM-768 defense in depth |

Configure via `~/.qssh/config`:

```
Host fips-server.example.com
    KexAlgorithm mlkem768

Host high-security.example.com
    KexAlgorithm mlkem1024

Host max-security.example.com
    KexAlgorithm hybrid
```

## 3. Generate post-quantum signing keys

Generate a SPHINCS+ keypair (hash-based, quantum-safe):

```bash
qssh-keygen -t sphincs+ -f /tmp/demo_sphincs -y
```

Examine what was created:

```bash
ls -la /tmp/demo_sphincs*
cat /tmp/demo_sphincs.pub
```

The public key is 32 bytes, but signatures are about 17KB. That's the tradeoff for minimal security assumptions.

Generate a Falcon key for comparison (lattice-based):

```bash
qssh-keygen -t falcon -f /tmp/demo_falcon -y
ls -la /tmp/demo_falcon*
```

Falcon has smaller signatures (~1KB) but relies on different mathematical assumptions.

## 4. Examine the server keys

The server uses SPHINCS+ for host authentication - this is what OpenSSH doesn't do (their host keys are still Ed25519 or RSA):

```bash
cat ~/qssh-demo/server/host_key.pub
ls -la ~/qssh-demo/server/host_key*
```

User keys are Falcon (~2KB vs 64 bytes for Ed25519):

```bash
ls -la ~/.qssh/id_qssh*
```

## 5. Connect and observe algorithm negotiation

```bash
qssh -p 4242 --verbose $USER@localhost
```

The output shows:
- `Using post-quantum algorithm: SphincsPlus` - SPHINCS+ for host auth (not in OpenSSH)
- `Transport: Quantum-native (768-byte indistinguishable frames)` - Fixed-size frames resist traffic analysis
- `KEX preference: FalconSignedShares` - Falcon-512 key exchange
- `Loaded identity key from ~/.qssh/id_qssh (1281 bytes)` - Falcon-512 user key (~1KB vs 64 bytes for Ed25519)

**What's running:**
- **Host Auth**: SPHINCS+ (hash-based signatures)
- **User Auth**: Falcon-512 (lattice-based signatures)
- **KEX**: Falcon-signed key shares

OpenSSH 9.0 does hybrid key exchange with NTRU Prime, but host authentication is still Ed25519. Here we're using SPHINCS+ for the host and Falcon for the user.

## 6. Interactive session

Once connected, you get a full shell:

```
Handshake completed successfully
Connected successfully!
Shell session started (channel 0)
Welcome to QSSH!
➜  qssh-demo git:(main)
```

The entire session is protected by post-quantum session keys.

---

## Compare with OpenSSH

```bash
ssh -v localhost 2>&1 | grep -E "kex_input|host key"
```

OpenSSH 9.0+ with `sntrup761x25519-sha512` does hybrid PQ key exchange - that's production-ready. What's missing is PQ host authentication and PQ user keys. That's what qssh explores.

---

## Key Takeaways

| Observation | Significance |
|-------------|--------------|
| `PqAlgorithm falcon512` | One-line PQ config, familiar SSH syntax |
| `qssh-keygen -t sphincs+` | Hash-based quantum-safe key generation |
| 768-byte indistinguishable frames | Traffic analysis resistance |
| 17KB signatures | Size tradeoff for minimal assumptions |
| SPHINCS+ host auth | Not available in OpenSSH |
| Falcon user identity (1281 bytes) | Lattice-based, smaller than SPHINCS+ |
| PQ session keys | End-to-end post-quantum |

The value of qssh isn't production readiness. It's surfacing where protocols strain under PQC - the 17KB signatures, the larger handshakes, the algorithm negotiation. These are the integration points to plan for.

---

## Links

- qssh: [crates.io/crates/qssh](https://crates.io/crates/qssh)
- Documentation: [docs.rs/qssh](https://docs.rs/qssh)
- Paraxiom: [paraxiom.org](https://paraxiom.org)
