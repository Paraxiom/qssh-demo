# Démonstration qssh - Guide pas à pas

## 1. Démarrer le serveur

```bash
cd ~/qssh-demo
./start-server.sh
```

Ceci démarre `qsshd` sur le port 4242 avec une clé hôte SPHINCS+.

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

## 5. Se connecter et observer la négociation des algorithmes

```bash
qssh -p 4242 --verbose $USER@localhost
```

La sortie affiche :
- `Selected KEX algorithm: MlKem768` - ML-KEM pour l'échange de clés (FIPS 203)
- `ML-KEM-768 key exchange completed` - Encapsulation de clés post-quantique
- `Falcon signature verified successfully` - Falcon pour l'identité utilisateur
- `Session keys derived with PQC-only security` - Post-quantique de bout en bout

**Échange de clés vs Signatures :**
- **Échange de clés** : ML-KEM-768 (KEM basé sur les réseaux, FIPS 203)
- **Auth hôte** : SPHINCS+ (signatures basées sur les fonctions de hachage)
- **Auth utilisateur** : Falcon-512 (signatures basées sur les réseaux)

OpenSSH 9.0 fait un échange de clés hybride avec NTRU Prime, mais l'authentification hôte reste Ed25519. Ici nous utilisons ML-KEM pour l'échange de clés, SPHINCS+ pour l'hôte et Falcon pour l'utilisateur.

## 6. L'authentification peut échouer

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
| `KexAlgorithm mlkem768` | Échange de clés conforme FIPS 203 |
| ML-KEM-768 / ML-KEM-1024 | KEM basé sur les réseaux, remplace Kyber vulnérable |
| `qssh-keygen -t sphincs+` | Génération de clés résistantes au quantique |
| Signatures de 17 Ko | Compromis de taille pour des hypothèses minimales |
| Auth hôte SPHINCS+ | Non disponible dans OpenSSH |
| Identité utilisateur Falcon | Basé sur les réseaux, plus petit que SPHINCS+ |
| Hybride X25519+ML-KEM | Option défense en profondeur |
| Clés de session PQ | Post-quantique de bout en bout |

La valeur de qssh n'est pas d'être prêt pour la production. C'est de révéler où les protocoles peinent sous PQC - les signatures de 17 Ko, les handshakes plus grands, la négociation des algorithmes. Ce sont les points d'intégration à planifier.

---

## Liens

- qssh : [crates.io/crates/qssh](https://crates.io/crates/qssh)
- Documentation : [docs.rs/qssh](https://docs.rs/qssh)
- Paraxiom : [paraxiom.org](https://paraxiom.org)
