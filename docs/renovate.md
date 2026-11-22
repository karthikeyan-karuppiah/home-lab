## Dependency Management & Supply-Chain Security (Renovate)

This repository uses **[Renovate](https://renovatebot.com)** (`renovate.json`) to automate container image, GitHub Action, and documentation updates while enforcing zero-trust supply-chain controls and risk-based automation.

### 1. End-to-End Automation Lifecycle

Every upstream release passes through a 4-stage validation and GitOps pipeline before reaching the TerraMaster NAS:

```text
Upstream Image Published
       │
       ▼ (Waits 3 days: minimumReleaseAge)
Renovate Evaluates Tier & Rule Precedence
       ├── Tier 3 (Major) ──────────► Held in Dependency Dashboard Issue (Waits for checkbox)
       ├── Tier 2 (Minor) ──────────► Opens PR ──► CI Runs ──► Waits for Human Merge
       └── Tier 1 (Patch/Digest) ───► Opens PR + Enables GitHub Squash Auto-Merge
                                           │
                                           ▼
                              CI Gate (Trivy + compose-lint + pr-lint)
                                           │
                                   ┌───────┴───────┐
                                   ▼               ▼
                                [FAIL]          [PASS]
                            Merge Blocked   Squashed to `main`
                                                   │
                                                   ▼
                                     Release Please (Changelog/Tag)
                                                   │
                                                   ▼
                                     Doco-CD Reconciles on NAS
```

---

### 2. Supply-Chain & CI/CD Safeguards

* **Immutable SHA256 Digest Pinning ([`pinDigests`](https://renovatebot.comconfiguration-options/#pindigests) & [`helpers:pinGitHubActionDigests`](https://renovatebot.compresets-helpers/#helperspingithubactiondigests)):**
  * Container tags (e.g., `:v0.35`) are mutable and can be overwritten upstream. Renovate pins every Docker image in `apps/tnas/` and every GitHub Action in `.github/workflows/` to an immutable `@sha256:` cryptographic fingerprint (e.g., `ghcr.io/0xerr0r/blocky:v0.35@sha256:9f86d0...`), guaranteeing reproducible deployments and preventing tag-hijacking attacks.
* **3-Day Release Quarantine ([`minimumReleaseAge`](https://renovatebot.comconfiguration-options/#minimumreleaseage)):**
  * Renovate waits `3 days` (`72 hours`) after a new release is published before opening a Pull Request. If an upstream maintainer publishes a broken image or a compromised build that gets retracted within 72 hours, the lab is never exposed to it.
* **CI-Gated Platform Automerge ([`platformAutomerge`](https://renovatebot.comconfiguration-options/#platformautomerge) + `automergeStrategy: "squash"`):**
  * Renovate never bypasses branch protections. For eligible PRs, Renovate enables GitHub's native **Squash Auto-Merge**, which blocks merging until all required status checks pass:
    * **Security & CVE Scanning:** `Trivy` (container image CVEs & secret scanning) and `Gitleaks`
    * **Static Analysis & Linting:** `compose-lint` (CIS Docker Benchmarks / OWASP), `yamllint`, and `pr-lint` (Conventional Commits)
* **GitOps & Release Lifecycle Integration ([`semanticCommits`](https://renovatebot.comconfiguration-options/#semanticcommits)):**
  * **Container & Action Updates (`fix(deps): ...`):** Merged PRs trigger **Google Release Please** to automatically bump semantic versions and generate release changelogs before **Doco-CD** reconciles the updated Compose files onto the TerraMaster NAS.
  * **Documentation Version Sync (`docs(deps): ...`):** Inline version references in `README.md` (tagged via `<!-- renovate: datasource=... depName=... -->`) are parsed by a **[Custom Regex Manager](https://renovatebot.commodules/manager/regex/)**, grouped into a single **`Documentation Image Updates`** PR without `@sha256:` hashes (`pinDigests: false`), and automerged under `docs(deps):` so documentation updates do not trigger unnecessary releases.

---

### 3. Tiered Risk & Automerge Policy

Using [`separateMajorMinor`](https://renovatebot.comconfiguration-options/#separatemajorminor) and [`separateMinorPatch`](https://renovatebot.comconfiguration-options/#separateminorpatch), Renovate splits updates into separate PRs by Semantic Versioning (`MAJOR.MINOR.PATCH`) blast radius so low-risk bug fixes are never blocked by larger feature releases:

| Tier | Update Types & Concrete Examples ([`matchUpdateTypes`](https://renovatebot.comconfiguration-options/#packagerulesmatchupdatetypes)) | Automation & GitOps Behavior | Engineering Rationale |
| :--- | :--- | :--- | :--- |
| **Tier 1: Routine Maintenance** | • **Patch:** `v1.4.1` $\rightarrow$ `v1.4.2` *(bug fixes)*<br>• **Digest:** `@sha256:a1b2...` $\rightarrow$ `@sha256:c3d4...` *(OS/base-image security rebuilds)*<br>• **Pin / PinDigest:** `v1.4.1` $\rightarrow$ `v1.4.1@sha256:a1b2...` *(initial SHA lock)* | **Automerge** once CI passes $\rightarrow$ Auto-deployed by **Doco-CD** | Backward-compatible bug fixes and base-image OS CVE patches carry minimal regression risk and are validated automatically by `Trivy` and `compose-lint`. |
| **Tier 2: Feature Releases** | • **Minor:** `v1.4.2` $\rightarrow$ `v1.5.0` *(new backward-compatible features)* | **PR Opened** $\rightarrow$ CI runs $\rightarrow$ Waits for **Manual Review** | Minor releases frequently introduce new optional environment variables, deprecated flags, or UI changes that warrant reviewing embedded release notes before syncing. |
| **Tier 3: Breaking Changes** | • **Major:** `v1.5.0` $\rightarrow$ `v2.0.0` *(breaking schema/API changes)* | **Held in [Dependency Dashboard](https://renovatebot.comkey-concepts/dashboard/)** (`dependencyDashboardApproval: true`) | Major upgrades often require database migrations, volume backups, or rewritten configs. PR creation is suppressed until explicitly approved via the dashboard issue checkbox. |

---

### 4. Critical Infrastructure Overrides (Rule Precedence)

Renovate evaluates `packageRules` sequentially from top to bottom, allowing later rules to override earlier ones. Core networking, security, and GitOps control-plane services are placed after the Tier 1 rule with `automerge: false` (via [`matchPackageNames`](https://renovatebot.comconfiguration-options/#packagerulesmatchpackagenames)) so **even patch or digest updates require manual approval** and cannot accidentally sever remote access or reconciliation:

* **Perimeter & Ingress:** `wg-easy` (WireGuard VPN), `nginx-proxy-manager` (Reverse Proxy / TLS)
* **Identity & DNS:** `authelia` (SSO / 2FA), `blocky` (DNS & Ad-Blocking)
* **GitOps Controller:** `doco-cd` (Continuous Deployment Agent)
