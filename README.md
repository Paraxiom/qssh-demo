# qssh Demo Walkthrough

## 1. Start the server

```bash
cd ~/qssh-demo
./start-server.sh
```

This starts `qsshd` on port 4242 with a SPHINCS+ host key.

## 2. Generate post-quantum keys

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

## 3. Examine the server keys

The server uses SPHINCS+ for host authentication - this is what OpenSSH doesn't do (their host keys are still Ed25519 or RSA):

```bash
cat ~/qssh-demo/server/host_key.pub
ls -la ~/qssh-demo/server/host_key*
```

User keys are Falcon (~2KB vs 64 bytes for Ed25519):

```bash
ls -la ~/.qssh/id_qssh*
```

## 4. Connect and observe algorithm negotiation

```bash
qssh -p 4242 --verbose $USER@localhost
```

The output shows:
- `Using post-quantum algorithm: SphincsPlus` - SPHINCS+ for host auth (not in OpenSSH)
- `Falcon signature verified successfully` - Falcon for user identity
- `Falcon public key: 897 bytes` / `SPHINCS+ public key: 32 bytes` - larger key sizes
- `Session keys derived with PQC-only security` - end-to-end post-quantum

OpenSSH 9.0 does hybrid key exchange with NTRU Prime, but host authentication is still Ed25519. Here we're using SPHINCS+ for the host and Falcon for the user.

## 5. Authentication may fail

The auth flow has bugs being debugged - this is research-grade. The important part is the PQ algorithms negotiating successfully. Finding these integration issues is why testbeds like this exist.

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
| `qssh-keygen -t sphincs+` | Hash-based quantum-safe key generation |
| 17KB signatures | Size tradeoff for minimal assumptions |
| SPHINCS+ host auth | Not available in OpenSSH |
| Falcon user identity | Lattice-based, smaller than SPHINCS+ |
| Larger key sizes | Migration consideration |
| PQC-only session keys | End-to-end post-quantum |
| Connection failures | Research-grade - finding bugs is the point |

The value of qssh isn't production readiness. It's surfacing where protocols strain under PQC - the 17KB signatures, the larger handshakes, the algorithm negotiation. These are the integration points to plan for.

---

## Links

- qssh: [crates.io/crates/qssh](https://crates.io/crates/qssh)
- Documentation: [docs.rs/qssh](https://docs.rs/qssh)
- Paraxiom: [paraxiom.org](https://paraxiom.org)
