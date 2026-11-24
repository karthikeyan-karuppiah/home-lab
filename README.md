# Home Infrastructure Lab

[![Continuous Integration](https://github.com/karthikeyan-karuppiah/home-lab/actions/workflows/ci.yaml/badge.svg)](https://github.com/karthikeyan-karuppiah/home-lab/actions/workflows/ci.yaml)
[![Release Management](https://github.com/karthikeyan-karuppiah/home-lab/actions/workflows/release.yaml/badge.svg)](https://github.com/karthikeyan-karuppiah/home-lab/actions/workflows/release.yaml)
[![PR Title Linter](https://github.com/karthikeyan-karuppiah/home-lab/actions/workflows/pr-lint.yml/badge.svg)](https://github.com/karthikeyan-karuppiah/home-lab/actions/workflows/pr-lint.yml)
[![Renovate](https://img.shields.io/badge/renovate-enabled-brightgreen?logo=renovatebot)](https://renovatebot.com)

A declarative, GitOps-driven infrastructure monorepo for managing private network utilities, secure edge ingress, and media orchestration services deployed on an **Intel-powered TerraMaster F4-424 Pro** NAS cluster.

---

## 🏗️ System Architecture & GitOps Workflow

This repository implements an infrastructure-as-code (IaC) methodology to enforce an isolated **Split-Tunnel "Security Sandwich"** network topology.

* **Continuous Delivery**: Handled natively by **Doco-CD**, acting as an on-premise GitOps controller that continuously reconciles state updates from the `main` branch.
* **Network Hardening**: Exposes a single cryptographic edge ingress point via WireGuard. All underlying infrastructure portals, databases, and application UIs are completely insulated from the public web.

🔎 For a comprehensive packet journey mapping and security breakdown, see the [System Architecture Document](ARCHITECTURE.md).

---

### 🌐 Zero-Trust Network & Traffic Flow

```mermaid
flowchart TB
    classDef external fill:#1e293b,stroke:#94a3b8,color:#f8fafc,stroke-width:2px
    classDef perimeter fill:#0f172a,stroke:#38bdf8,color:#f8fafc,stroke-width:2px
    classDef security fill:#1e1b4b,stroke:#818cf8,color:#f8fafc,stroke-width:2px
    classDef core fill:#064e3b,stroke:#34d399,color:#f8fafc,stroke-width:2px
    classDef obs fill:#451a03,stroke:#fbbf24,color:#f8fafc,stroke-width:2px
    classDef storage fill:#27272a,stroke:#a1a1aa,color:#f8fafc,stroke-width:2px

    Client["📱 Remote / LAN Client<br/>(AllowedIPs: 192.168.1.0/24, 10.8.0.0/24)"]:::external
    WAN(("🌐 Public Internet<br/>(Only 51820/udp Exposed)")):::external

    subgraph TNAS ["🖥️ TerraMaster F4-424 Pro (TOS) — 192.168.1.100"]
        direction TB

        subgraph HostLayer ["Layer 1: Host Network Perimeter & DNS"]
            direction LR
            WG["1️⃣ WireGuard (wg-easy)<br/>UDP :51820 | Injects DNS 10.8.0.1"]:::perimeter
            DNS["2️⃣ Blocky DNS<br/>UDP/TCP :53 | Resolves *.home → .100"]:::security
        end

        subgraph ProxyLayer ["Layer 2: Shared 'proxy' Bridge Network"]
            direction TB
            NPM["3️⃣ Nginx Proxy Manager<br/>L7 Host Routing (:8080 / :8443)"]:::perimeter
            Auth["4️⃣ Authelia IdP<br/>ForwardAuth / SSO / 2FA (:9091)"]:::security
            Navi["🎵 Navidrome Media Core<br/>Internal :4533 (:ro Media)"]:::core
        end

        subgraph IsolatedLayer ["Layer 3: Micro-Segmented 'authelia-internal'"]
            Redis["🗄️ Authelia Redis<br/>Internal :6379 (Zero Proxy Access)"]:::security
        end

        subgraph Observability ["Observability & SRE Plane"]
            Prom["📈 Prometheus<br/>(Multi-Window SLO Rules)"]:::obs
            Graf["📊 Grafana<br/>(Dashboards & Mobile Alerts)"]:::obs
        end

        subgraph ControlPlane ["GitOps & Backup Plane"]
            Doco["🔄 Doco-CD<br/>(Pull-Based GitOps Agent)"]:::core
            Restic["💾 Restic Backup<br/>(Daily Encrypted Snapshots)"]:::storage
            Vol[("🗄️ /Volume1/DockerAppsData<br/>(WG, NPM, Authelia State)")]:::storage
        end
    end

    B2[("☁️ Off-Site Object Storage<br/>(Encrypted 3-2-1 Backup)")]:::storage

    %% Packet & Control Flows
    Client -->|"Encrypted Tunnel (51820/udp)"| WAN
    WAN -->|"Authenticated Handshake"| WG
    WG <-->|"1. DNS Lookup (*.home → .100)"| DNS
    WG -->|"2. HTTP/S Request (:8080 / :8443)"| NPM
    NPM <-->|"3. ForwardAuth Check (:9091)"| Auth
    Auth <-->|"Session Lookup (:6379)"| Redis
    NPM -->|"4. Authorized Traffic"| Navi
    NPM -->|"4. Authorized Traffic"| Graf

    %% Observability & Storage Flows
    DNS -.->|"Scrape :4000/metrics"| Prom
    Prom -->|"Evaluate SLO Burn Rate"| Graf
    Vol --- WG
    Vol --- NPM
    Vol --- Auth
    Vol -->|":ro Mount"| Restic
    Restic -->|"Client-Side AES-256"| B2
```
---
### 📐 Architecture Decision Records (ADRs)

Key engineering trade-offs, empirical benchmarks, and evolutionary roadmaps are documented in [`docs/adr/`](docs/adr/README.md):

| ID | Decision | Architectural Rationale |
| :--- | :--- | :--- |
| **[ADR-001](docs/adr/001-docker-compose-and-doco-cd-over-kubernetes.md)** | Preserve TOS + Docker Compose + Doco-CD | Protects native TerraMaster RAID/storage stability while maintaining GitOps parity ahead of a planned **Talos Linux Kubernetes** migration. |
| **[ADR-002](docs/adr/002-sops-and-age-over-hashicorp-vault.md)** | Mozilla SOPS + `age` Secret Encryption | Enables zero-dependency encrypted secrets in Git with trivial bare-metal recovery and no circular bootstrap dependencies. |
| **[ADR-003](docs/adr/003-wireguard-only-zero-trust-perimeter.md)** | WireGuard-Only Zero-Trust Perimeter | Eliminates public HTTP surface and resolves iOS battery drain empirically observed with Tailscale's userspace daemon. |
| **[ADR-004](docs/adr/004-traefik-over-nginx-proxy-manager.md)** | Planned Migration: NPM $\rightarrow$ Traefik v3 | Roadmap to replace stateful UI "ClickOps" with declarative label routing, read-only `docker-socket-proxy`, and native HTTP metrics. |
| **[ADR-005](docs/adr/005-authelia-over-pocket-id.md)** | Authelia over Pocket ID | Provides reverse-proxy `ForwardAuth` for non-OIDC apps and declarative YAML policy-as-code alongside Passkey/TOTP 2FA. |

---

## 🚀 CI/CD Infrastructure & Automation Engineering

This monorepo utilizes an advanced, decoupled multi-stage execution pipeline built under strict zero-trust parameters to guarantee supply chain integrity before host cluster synchronization.

```text
  [ Pull Request Opened ]
             │
             ├──► (Pipeline 3) PR Title Linter  ──► Checks Semantic Compliance
             └──► (Pipeline 1) CI Engine        ──► Lint · Secrets · Compose Security · Image CVE/SBOM
                                       │
                              [ Merge to main ]
                                       │
                                       ▼
                         (Pipeline 1) CI Success Gate
                                       │
                        (Artifact Transit Upload)
                                       │
                                       ▼
                     (Pipeline 2) Release Management (CD)
                                       │
                                       ▼
                       Google Release Please Automation
```

### 📋 Automated Pipeline Directory

#### 1. Continuous Integration (`.github/workflows/ci.yml`)
Runs asynchronously on all target pushes and active pull requests to fail-fast on bad configuration patterns.
* **Secret Detection**: Gitleaks (full git history) and Trivy filesystem secret scanning to catch credential spills before merge.
* **Docker Compose Security**: compose-lint (OWASP / CIS Docker Benchmark) checks for privileged mode, Docker socket mounts, dangerous capabilities, unbound ports, missing resource limits, and unsafe credential handling.
* **Container Image Scanning**: Trivy scans images referenced in Compose files for CRITICAL/HIGH CVEs and generates CycloneDX SBOMs as workflow artifacts for supply-chain inventory.
* **Static Code Analysis**: Hadolint for Dockerfile best practices and Yamllint for infrastructure YAML specifications.
* **Compose Structure Validation**: `docker compose config` validates every Compose file for structural integrity before merge.
* **Cross-Boundary Data Transit**: Packages verified metadata into a secure short-retention GitHub build artifact on successful runs.

#### 2. Release Management (`.github/workflows/release.yml`)
An event-driven CD pipeline configured to trigger cleanly via `workflow_run` only when the primary CI pipeline ends successfully on the `main` branch.
* **State Verification**: Pulls and verifies the data integrity of the compiled metadata package generated upstream.
* **Semantic Engine**: Executes **Google Release Please** to parse semantic version patterns, compile automated changelogs, and cut production GitHub releases.

#### 3. PR Title Linter (`.github/workflows/pr-lint.yml`)
An isolated workflow evaluating branch metadata to enforce **Conventional Commits** (`feat:`, `fix:`, `chore:`). This prevents unparseable merge commits from polluting historical lines or crashing the downstream release generator.

---

## 🛠️ Service Catalog & Specifications

### 🔐 Edge Ingress & Routing

#### 1. WireGuard VPN (`/wg-easy`)
Provides high-performance, cryptographic remote entry paths into the lab network using a fast Split-Tunnel layout.
* **Dynamic Endpoint Routing**: Enforced via **DuckDNS** (`<your-subdomain>.duckdns.org`) to maintain connection states across dynamic ISP public IP rotations.
* **Image Registry**: `ghcr.io/wg-easy/wg-easy:v15`

#### 2. Nginx Proxy Manager (`/nginx-proxy-manager`)
Acts as the central reverse proxy and application layer router to handle hostname evaluation and decouple port configurations.
* **Capability**: Exposes clean internal proxy channels and manages upstream data flows.
* **Image Registry**: `jc21/nginx-proxy-manager:2.11`

### 🗺️ Network & Media Core

#### 3. Blocky (`/blocky`)
An ultra-lightweight local DNS proxy and network-wide sinkhole designed for local domain mapping and privacy hardening.
* **Upstream Delivery**: DNS-over-HTTPS (DoH) utilizing secure endpoints via Quad9 (`dns.quad9.net`) and Cloudflare.
* **Telemetry Protection**: Intercepts tracking and advertisement scripts at the name-resolution stage.
* **Image Registry**: `ghcr.io/0xerr0r/blocky:v0.35`

#### 4. Navidrome (`/navidrome`)
A streaming server subsystem compliant with Subsonic/Madsonic API specifications to host private media assets.
* **Capability**: Multithreaded library indexing, metadata extraction, and streaming abstraction.
* **Image Registry**: `deluan/navidrome:0.53`

---

## 📊 Network Topology & Port Matrix

The host operating system kernel rules enforce strict port boundaries. Only the WireGuard ingress port is mapped to your perimeter gateway.

| Subsystem Component       | Container Port | Host Port | Network Layer  | Boundary / Purpose                              |
| :------------------------ | :------------- | :-------- | :------------- | :---------------------------------------------- |
| **WireGuard Ingress**     | `51820/udp`    | `51820`   | Layer 4 (UDP)  | Mapped Gateway Cryptographic Entry              |
| **WireGuard UI**          | `51821/tcp`    | `51821`   | Layer 7 (HTTP) | Internal Peer Management Portal                 |
| **Blocky DNS Proxy**      | `53/udp`       | `53`      | Layer 4 (UDP)  | Internal Network Resolution Ingress             |
| **Blocky DNS Proxy**      | `53/tcp`       | `53`      | Layer 4 (TCP)  | Internal Fallback TCP Resolution                |
| **Blocky API & Metrics**  | `4000/tcp`     | `4000`    | Layer 7 (HTTP) | Health Check / Telemetry Endpoint               |
| **Nginx Proxy Manager**   | `80/tcp`       | `8080`    | Layer 7 (HTTP) | Local Hostname Routing Engine                   |
| **Nginx UI Dashboard**    | `81/tcp`       | `81`      | Layer 7 (HTTP) | Internal Proxy Rules Configuration              |
| **Nginx Secure Ingress**  | `443/tcp`      | `8443`    | Layer 7 (HTTPS)| Mapped for Local SSL Security Layers            |
| **Authelia**              | `9091/tcp`     | —         | Layer 7 (HTTP) | Internal only (reached via NPM)                 |
| **Navidrome Engine**      | `4533/tcp`     | `4533`    | Layer 7 (HTTP) | Dedicated Media Core Backend Ingress            |

---

## 📂 Storage Architecture & Volume Strategy

To maximize system security and preserve container statelessness, host mount spaces are cleanly partitioned between persistent application databases and absolute Read-Only data volumes:

```text
/Volume1/
├── DockerAppsData/
│   ├── Wireguard/           # Cryptographic tunnel peer profile states
│   ├── blocky/              # Core YAML local domain network maps
│   ├── nginx-proxy/         # Host routing tables and SQLite files
│   └── navidrome/data/      # User database metadata index configurations
└── homes/<username>/
    └── songs/               # Media Storage Vault (:ro Read-Only Mount)
```
