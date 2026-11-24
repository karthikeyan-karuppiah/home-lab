# ADR-002: Use Mozilla SOPS + `age` over HashiCorp Vault

* **Status:** Accepted
* **Deciders:** Karthikeyan Karuppiah

## Context and Problem Statement
In a GitOps repository, all configuration—including API keys, database passwords, and WireGuard/Authelia secrets—must be version-controlled and reproducible from a bare-metal restore. Storing plaintext secrets in Git is unacceptable, while running a stateful secret manager introduces a "chicken-and-egg" bootstrap problem during disaster recovery.

## Decision Drivers
* **Zero Bootstrap Dependency:** Secrets must be decryptable during a bare-metal disaster recovery before any containers or cluster services are running.
* **Git-Native Workflows:** Secret changes should support standard Pull Requests, Git diffs (on encrypted keys), and atomic rollbacks alongside application config changes.
* **Defense-in-Depth CI Guardrails:** Automated CI checks (`Gitleaks`, `Trivy`) must verify that no unencrypted secrets are ever committed.
* **Modern Cryptography:** Simple key management without PGP keyring complexity.

## Considered Options
1. **Mozilla SOPS + `age` encryption (`.sops.yaml`)**
2. **Self-Hosted HashiCorp Vault / Infisical**
3. **GitHub Actions Secrets injected at deploy time**

## Decision Outcome
**Chosen option: "Mozilla SOPS + `age`"**, because it encrypts secret values directly inside Git-tracked files using modern X25519 keys while leaving YAML/ENV key names readable for code review and linting.

### Positive Consequences
* **Trivial Bare-Metal Recovery:** Restoring the entire environment requires only cloning the Git repository and providing a single offline `age` private key (`keys.txt`).
* **Atomic Versioning:** Application configurations and their corresponding credentials are versioned together in the exact same Git commit.
* **Zero Runtime Overhead:** No persistent secret-server database to back up, unseal, or monitor for availability.

### Negative Consequences
* **Manual Secret Rotation:** Unlike dynamic Vault leases, rotated credentials require re-encrypting the target file with `sops` and committing the update.
* **Key Custody Responsibility:** Loss of the offline `age` private key renders encrypted repository secrets unrecoverable (mitigated via offline backup of the `age` key).
