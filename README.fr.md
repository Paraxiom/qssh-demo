# Démo qssh

Démonstration de SSH post-quantique utilisant l'authentification hôte SPHINCS+ et les clés utilisateur Falcon.

## Prérequis

- [qssh](https://crates.io/crates/qssh) installé (`cargo install qssh`)
- Binaire serveur [qsshd](https://github.com/Paraxiom/paraxiom-qssh)

## Installation

### 1. Démarrer le serveur

```bash
./start-server.sh
```

Ceci démarre `qsshd` sur le port 4242 avec :
- Clé hôte SPHINCS+ (`server/host_key`)
- Clés Falcon autorisées (`server/authorized_keys`)

### 2. Se connecter

```bash
./connect.sh
```

Ou manuellement :

```bash
qssh -p 4242 --verbose $USER@localhost
```

### Démo en un clic

```bash
./run-demo.sh
```

Démarre le serveur, se connecte et affiche la négociation des algorithmes.

## Fichiers de clés

| Fichier | Algorithme | Fonction |
|---------|------------|----------|
| `server/host_key` | SPHINCS+ | Authentification hôte (résistant au quantique) |
| `client/id_qssh` | Falcon-512 | Authentification utilisateur |
| `server/authorized_keys` | - | Clés publiques utilisateur autorisées |

## Ce que cette démo illustre

- **Authentification hôte SPHINCS+** - OpenSSH utilise Ed25519/RSA pour les clés hôtes ; qssh utilise des signatures PQ basées sur les fonctions de hachage
- **Clés utilisateur Falcon** - Signatures basées sur les réseaux pour l'identité utilisateur
- **Clés de session PQ uniquement** - Échange de clés utilisant ML-KEM

## Liens

- qssh : [crates.io/crates/qssh](https://crates.io/crates/qssh)
- Documentation : [docs.rs/qssh](https://docs.rs/qssh)
- Paraxiom : [paraxiom.org](https://paraxiom.org)
