# Home Infrastructure Lab

[![Continuous Integration](https://shields.io)](https://github.com/workflows/ci.yml)
[![Release Management](https://shields.io)](https://github.com)
[![PR Title Linter](https://shields.io)](https://github.com)
[![Renovate](https://shields.io)](https://renovatebot.com)

A declarative, GitOps-driven infrastructure monorepo for managing private network utilities, secure edge ingress, and media orchestration services deployed on an **Intel-powered TerraMaster F4-424 Pro** NAS cluster.

---

## 🏗️ System Architecture & GitOps Workflow

This repository implements an infrastructure-as-code (IaC) methodology to enforce an isolated **Split-Tunnel "Security Sandwich"** network topology.

* **Continuous Delivery**: Handled natively by **Doco-CD**, acting as an on-premise GitOps controller that continuously reconciles state updates from the `main` branch.
* **Network Hardening**: Exposes a single cryptographic edge ingress point via WireGuard. All underlying infrastructure portals, databases, and application UIs are completely insulated from the public web.

🔎 For a comprehensive packet journey mapping and security breakdown, see the [System Architecture Document](ARCHITECTURE.md).

---

## 🚀 CI/CD Infrastructure & Automation Engineering

This monorepo utilizes an advanced, decoupled multi-stage execution pipeline built under strict zero-trust parameters to guarantee supply chain integrity before host cluster synchronization.

```text
  [ Pull Request Opened ]
             │
             ├──► (Pipeline 3) PR Title Linter  ──► Checks Semantic Compliance
             └──► (Pipeline 1) CI Engine        ──► Static Scans, Linters & Trivy
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
* **Security & Vulnerability Auditing**: Implements **Gitleaks** to catch credential spills and **Aqua Security Trivy** to parse IaC structural errors.
* **Static Code Analysis**: Employs **Hadolint** for Dockerfile syntactic validation and **Yamllint** for infrastructure specification maps.
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
* **Dynamic Endpoint Routing**: Enforced via **DuckDNS** (`carthytnas.duckdns.org`) to maintain connection states across dynamic ISP public IP rotations.
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

| Subsystem Component | Container Port | Host Port | Network Layer | Boundary / Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **WireGuard Ingress** | `51820/udp` | `51820` | Layer 4 (UDP) | Mapped Gateway Cryptographic Entry |
| **WireGuard UI** | `51821/tcp` | `51821` | Layer 7 (HTTP) | Internal Peer Management Portal |
| **Blocky DNS Proxy** | `53/udp` | `53` | Layer 4 (UDP) | Internal Network Resolution Ingress |
| **Blocky DNS Proxy** | `53/tcp` | `53` | Layer 4 (TCP) | Internal Fallback TCP Resolution |
| **Blocky API & Metrics** | `4000/tcp` | `4000` | Layer 7 (HTTP) | Health Check / Telemetry Endpoint |
| **Nginx Proxy Manager** | `80/tcp` | `8080` | Layer 7 (HTTP) | Local Hostname Routing Engine (`music.home`) |
| **Nginx UI Dashboard** | `81/tcp` | `81` | Layer 7 (HTTP) | Internal Proxy Rules Configuration |
| **Nginx Secure Ingress** | `443/tcp` | `8443` | Layer 7 (HTTPS)| Mapped for Local SSL Security Layers |
| **Navidrome Engine** | `4533/tcp` | `4533` | Layer 7 (HTTP) | Dedicated Media Core Backend Ingress |

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
└── homes/carthy_k/
    └── songs/               # Media Storage Vault (:ro Read-Only Mount)
```
