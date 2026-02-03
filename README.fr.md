# Démonstration qssh - Guide pas à pas

## 1. Démarrer le serveur

```bash
cd ~/qssh-demo
./start-server.sh
```

Ceci démarre `qsshd` sur le port 4242 avec une clé hôte SPHINCS+.

## 2. Générer des clés post-quantiques

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

## 3. Examiner les clés du serveur

Le serveur utilise SPHINCS+ pour l'authentification hôte - c'est ce qu'OpenSSH ne fait pas (leurs clés hôtes sont toujours Ed25519 ou RSA) :

```bash
cat ~/qssh-demo/server/host_key.pub
ls -la ~/qssh-demo/server/host_key*
```

Les clés utilisateur sont Falcon (~2 Ko vs 64 octets pour Ed25519) :

```bash
ls -la ~/.qssh/id_qssh*
```

## 4. Se connecter et observer la négociation des algorithmes

```bash
qssh -p 4242 --verbose $USER@localhost
```

La sortie affiche :
- `Using post-quantum algorithm: SphincsPlus` - SPHINCS+ pour l'auth hôte (absent d'OpenSSH)
- `Falcon signature verified successfully` - Falcon pour l'identité utilisateur
- `Falcon public key: 897 bytes` / `SPHINCS+ public key: 32 bytes` - tailles de clés plus grandes
- `Session keys derived with PQC-only security` - post-quantique de bout en bout

OpenSSH 9.0 fait un échange de clés hybride avec NTRU Prime, mais l'authentification hôte reste Ed25519. Ici nous utilisons SPHINCS+ pour l'hôte et Falcon pour l'utilisateur.

## 5. L'authentification peut échouer

Le flux d'authentification a des bugs en cours de débogage - c'est du code de recherche. L'important est que les algorithmes PQ négocient avec succès. Trouver ces problèmes d'intégration est la raison d'être de ces bancs d'essai.

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
| `qssh-keygen -t sphincs+` | Génération de clés résistantes au quantique basée sur les fonctions de hachage |
| Signatures de 17 Ko | Compromis de taille pour des hypothèses minimales |
| Auth hôte SPHINCS+ | Non disponible dans OpenSSH |
| Identité utilisateur Falcon | Basé sur les réseaux, plus petit que SPHINCS+ |
| Tailles de clés plus grandes | Considération pour la migration |
| Clés de session PQ uniquement | Post-quantique de bout en bout |
| Échecs de connexion | Code de recherche - trouver les bugs est le but |

La valeur de qssh n'est pas d'être prêt pour la production. C'est de révéler où les protocoles peinent sous PQC - les signatures de 17 Ko, les handshakes plus grands, la négociation des algorithmes. Ce sont les points d'intégration à planifier.

---

## Liens

- qssh : [crates.io/crates/qssh](https://crates.io/crates/qssh)
- Documentation : [docs.rs/qssh](https://docs.rs/qssh)
- Paraxiom : [paraxiom.org](https://paraxiom.org)
