# Démonstration qssh - Guide pas à pas

## 0. Prérequis — Installer Rust et qssh

Installer Rust (si pas déjà installé) :

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

Installer qssh depuis crates.io :

```bash
cargo install qssh
# Si une ancienne version est déjà installée :
cargo install qssh --force
```

Vérifier l'installation (v0.2.1 ou plus récent) :

```bash
qssh --version    # doit afficher : qssh 0.2.1
qsshd --version   # doit afficher : qsshd 0.2.1
```

## 1. Démarrer le serveur

### Option A : Démonstration locale

```bash
cd ~/qssh-demo
qsshd \
    --listen 127.0.0.1:4242 \
    --host-key ./server/host_key \
    --authorized-keys ./server/authorized_keys \
    --verbose
```

Ceci démarre `qsshd` sur le port 4242 avec une clé hôte SPHINCS+.

### Option B : Validateur distant (qh-alice)

`qsshd` tourne déjà sur le nœud validateur distant. Pas besoin de serveur local — connectez-vous directement depuis votre laptop (voir étape 5).

## 2. Algorithmes d'échange de clés

qssh supporte maintenant plusieurs algorithmes d'échange de clés post-quantiques :

| Algorithme | Niveau NIST | Cas d'usage |
|------------|-------------|-------------|
| `falcon-signed` | - | Legacy, rétrocompatible |
| `mlkem768` | Niveau 3 | Conforme FIPS 203, recommandé |
| `mlkem1024` | Niveau 5 | Marge de sécurité maximale |
| `hybrid` | Niveau 3 | X25519 + ML-KEM-768 défense en profondeur |

Configurer via `~/.qssh/config` :

```
Host serveur-fips.exemple.com
    KexAlgorithm mlkem768

Host haute-securite.exemple.com
    KexAlgorithm mlkem1024

Host securite-maximale.exemple.com
    KexAlgorithm hybrid
```

## 3. Générer des clés de signature post-quantiques

Générer une paire de clés SPHINCS+ (basée sur les fonctions de hachage, résistante au quantique) :

```bash
qssh-keygen -t sphincs+ -f /tmp/demo_sphincs -y
```

Examiner ce qui a été créé :

```bash
ls -la /tmp/demo_sphincs*
cat /tmp/demo_sphincs.pub
```

La clé publique fait 32 octets, mais les signatures font environ 17 Ko. C'est le compromis pour des hypothèses de sécurité minimales.

Générer une clé Falcon pour comparaison (basée sur les réseaux) :

```bash
qssh-keygen -t falcon -f /tmp/demo_falcon -y
ls -la /tmp/demo_falcon*
```

Falcon a des signatures plus petites (~1 Ko) mais repose sur des hypothèses mathématiques différentes.

## 4. Examiner les clés du serveur

Le serveur utilise SPHINCS+ pour l'authentification hôte - c'est ce qu'OpenSSH ne fait pas (leurs clés hôtes sont toujours Ed25519 ou RSA) :

```bash
cat ~/qssh-demo/server/host_key.pub
ls -la ~/qssh-demo/server/host_key*
```

Les clés utilisateur sont Falcon (~2 Ko vs 64 octets pour Ed25519) :

```bash
ls -la ~/.qssh/id_qssh*
```

## 5. Se connecter et observer la négociation des algorithmes

### Option A : Local

Afficher le handshake (sortie verbose uniquement, sans shell interactif) :

```bash
qssh -p 4242 --verbose $USER@localhost 2>&1 | head -30
```

Puis se connecter avec une session interactive propre :

```bash
qssh -p 4242 $USER@localhost
```

### Option B : Validateur distant (qh-alice)

```bash
qssh -p 4242 --verbose ubuntu@51.79.26.123 2>&1 | head -30
```

Puis se connecter :

```bash
qssh -p 4242 ubuntu@51.79.26.123
```

Ceci est une vraie connexion PQ chiffrée vers un nœud validateur blockchain sur l'internet public.

La sortie affiche :
- `Using post-quantum algorithm: SphincsPlus` - SPHINCS+ pour l'auth hôte (absent d'OpenSSH)
- `Transport: Quantum-native (768-byte indistinguishable frames)` - Trames de taille fixe contre l'analyse de trafic
- `KEX preference: FalconSignedShares` - Échange de clés Falcon-512
- `Loaded identity key from ~/.qssh/id_qssh (1281 bytes)` - Clé utilisateur Falcon-512 (~1 Ko vs 64 octets pour Ed25519)

**Ce qui tourne :**
- **Auth hôte** : SPHINCS+ (signatures basées sur les fonctions de hachage)
- **Auth utilisateur** : Falcon-512 (signatures basées sur les réseaux)
- **KEX** : Partages de clés signés Falcon

OpenSSH 9.0 fait un échange de clés hybride avec NTRU Prime, mais l'authentification hôte reste Ed25519. Ici nous utilisons SPHINCS+ pour l'hôte et Falcon pour l'utilisateur.

## 6. Session interactive

Une fois connecté, vous obtenez un shell complet :

```
Handshake completed successfully
Connected successfully!
Shell session started (channel 0)
Welcome to QSSH!
➜  qssh-demo git:(main)
```

Toute la session est protégée par des clés de session post-quantiques.

---

## Comparer avec OpenSSH

```bash
ssh -v localhost 2>&1 | grep -E "kex_input|host key"
```

OpenSSH 9.0+ avec `sntrup761x25519-sha512` fait un échange de clés PQ hybride - c'est prêt pour la production. Ce qui manque, c'est l'authentification hôte PQ et les clés utilisateur PQ. C'est ce que qssh explore.

---

## Points clés à retenir

| Observation | Signification |
|-------------|---------------|
| `PqAlgorithm falcon512` | Config PQ en une ligne, syntaxe SSH familière |
| `qssh-keygen -t sphincs+` | Génération de clés résistantes au quantique |
| Trames de 768 octets indistinguables | Résistance à l'analyse de trafic |
| Signatures de 17 Ko | Compromis de taille pour des hypothèses minimales |
| Auth hôte SPHINCS+ | Non disponible dans OpenSSH |
| Identité utilisateur Falcon (1281 octets) | Basé sur les réseaux, plus petit que SPHINCS+ |
| Clés de session PQ | Post-quantique de bout en bout |

La valeur de qssh n'est pas d'être prêt pour la production. C'est de révéler où les protocoles peinent sous PQC - les signatures de 17 Ko, les handshakes plus grands, la négociation des algorithmes. Ce sont les points d'intégration à planifier.

---

## Liens

- qssh : [crates.io/crates/qssh](https://crates.io/crates/qssh)
- Documentation : [docs.rs/qssh](https://docs.rs/qssh)
- Paraxiom : [paraxiom.org](https://paraxiom.org)
