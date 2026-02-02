# qssh Live Demo Script - KPMG Presentation

## Pre-Demo Setup (do this 10 min before meeting)

```bash
# Terminal 1: Start server in background
cd ~/qssh-demo
./start-server.sh
```

---

## Live Demo (2-3 minutes max)

### 1. Show the post-quantum keys (30 seconds)

```bash
# Show the SPHINCS+ host key
cat ~/qssh-demo/server/host_key.pub
```

**Say:** "This is a SPHINCS+ host key - hash-based, quantum-safe. 64-byte public key, but signatures are 17KB."

```bash
# Show key sizes
ls -la ~/qssh-demo/server/host_key*
ls -la ~/.qssh/id_qssh*
```

**Say:** "The private keys are small, but Falcon user keys are about 2KB vs 64 bytes for Ed25519."

### 2. Connect and show algorithm negotiation (1 minute)

```bash
qssh -p 4242 --verbose $USER@localhost
```

**Point at the output:**
- `Using post-quantum algorithm: SphincsPlus`
- `Falcon signature verified successfully`
- `Falcon public key: 897 bytes`
- `SPHINCS+ public key: 32 bytes`
- `Session keys derived with PQC-only security`

**Say:** "This shows the handshake negotiating PQ algorithms. OpenSSH 9.0 does hybrid key exchange with NTRU Prime, but host authentication is still Ed25519. Here we're using SPHINCS+ for the host and Falcon for the user."

### 3. If it fails at auth (expected)

**Say:** "The auth flow has a bug we're still debugging - this is research-grade. But you saw the important part: PQ algorithms negotiating successfully."

---

## Compare with OpenSSH (optional, if time)

```bash
ssh -v localhost 2>&1 | grep -E "kex_input|host key"
```

**Say:** "OpenSSH 9.0+ with `sntrup761x25519-sha512` does hybrid PQ key exchange - that's production-ready. What's missing is PQ host authentication and PQ user keys. That's what qssh explores."

---

## Key Demo Lines

| What they see | What you say |
|---------------|--------------|
| `Using post-quantum algorithm: SphincsPlus` | "SPHINCS+ for host auth - not in OpenSSH" |
| `Falcon signature verified` | "Falcon for user identity - NTRU lattice" |
| `897 bytes` / `32 bytes` | "Key sizes are larger - that's the tradeoff" |
| `Session keys derived with PQC-only` | "End-to-end post-quantum" |
| Connection failure | "Research-grade - finding bugs is the point" |

---

## If Everything Breaks

Fall back to showing key generation:

```bash
qssh-keygen --help
qssh-keygen -t sphincs+ -f /tmp/demo_key -y
cat /tmp/demo_key.pub
```

**Say:** "Even if the connection has issues, the crypto primitives work. This is SPHINCS+ - the most conservative choice because it only assumes hash function security."

---

## Closing Line

"The value isn't that qssh is production-ready. It's that building it surfaces where protocols strain under PQC - the 17KB signatures, the larger handshakes, the algorithm negotiation. These are the integration points your clients will need to plan for."
