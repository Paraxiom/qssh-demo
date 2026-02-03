# qssh Live Demo Script

## 1. Generate a post-quantum key

```bash
# Generate a fresh SPHINCS+ key
qssh-keygen -t sphincs+ -f /tmp/demo_sphincs -y
```

**Say:** "This generates a SPHINCS+ keypair - hash-based, quantum-safe. The only assumption is that hash functions are secure."

```bash
# Show what we just created
ls -la /tmp/demo_sphincs*
cat /tmp/demo_sphincs.pub
```

**Say:** "Public key is 32 bytes, but signatures are about 17KB. That's the tradeoff for maximum security assumptions."

```bash
# Generate a Falcon key for comparison
qssh-keygen -t falcon -f /tmp/demo_falcon -y
ls -la /tmp/demo_falcon*
```

**Say:** "Falcon is lattice-based - smaller signatures around 1KB, but relies on different mathematical assumptions."

## 2. Show the server keys

```bash
# These are the pre-generated keys the server uses
cat ~/qssh-demo/server/host_key.pub
ls -la ~/qssh-demo/server/host_key*
```

**Say:** "The server uses SPHINCS+ for host authentication. This is what OpenSSH doesn't do - their host keys are still Ed25519 or RSA."

```bash
# Show user key
ls -la ~/.qssh/id_qssh*
```

**Say:** "User keys are Falcon - about 2KB vs 64 bytes for Ed25519."

## 3. Connect and show algorithm negotiation

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

## 4. If it fails at auth (expected)

**Say:** "The auth flow has a bug we're still debugging - this is research-grade. But you saw the important part: PQ algorithms negotiating successfully. Finding these bugs is exactly why testbeds like this exist."

---

## Compare with OpenSSH (optional)

```bash
ssh -v localhost 2>&1 | grep -E "kex_input|host key"
```

**Say:** "OpenSSH 9.0+ with `sntrup761x25519-sha512` does hybrid PQ key exchange - that's production-ready. What's missing is PQ host authentication and PQ user keys. That's what qssh explores."

---

## Quick Reference

| What they see | What you say |
|---------------|--------------|
| `qssh-keygen -t sphincs+` | "Generating a hash-based quantum-safe key" |
| `17KB signature` | "That's the size tradeoff for minimal assumptions" |
| `Using post-quantum algorithm: SphincsPlus` | "SPHINCS+ for host auth - not in OpenSSH" |
| `Falcon signature verified` | "Falcon for user identity - lattice-based" |
| `897 bytes` / `32 bytes` | "Key sizes are larger - that's the tradeoff" |
| `Session keys derived with PQC-only` | "End-to-end post-quantum" |
| Connection failure | "Research-grade - finding bugs is the point" |

---

## Closing

"The value isn't that qssh is production-ready. It's that building it surfaces where protocols strain under PQC - the 17KB signatures, the larger handshakes, the algorithm negotiation. These are the integration points you'll need to plan for."
