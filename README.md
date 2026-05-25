# Home Infrastructure Lab

[![GitOps: Doco-CD](https://shields.io)](https://github.com)
[![Platform: TOS](https://shields.io)](https://terra-master.com)

An enterprise-grade, GitOps-driven home infrastructure monorepo managing core network utilities and media orchestration services deployed on a self-hosted TerraMaster NAS (TNAS) cluster.

---

## Architecture & Continuous Delivery Workflow

This repository implements a declarative infrastructure-as-code (IaC) methodology. Continuous Delivery is orchestrated via **Doco-CD**, acting as an on-premise GitOps controller.

---

## Service Catalog & Specifications

### Core Network Services

#### 1. Blocky (`/blocky`)
An enterprise-grade, ultra-lightweight DNS proxy and network-wide sinkhole designed for security hardening and local resolution management.
* **Upstream Delivery**: DNS-over-HTTPS (DoH) utilizing secure endpoints (Quad9, Cloudflare).
* **Compliance & Security**: Automated blocking via centralized hosts/domain telemetry lists.
* **Image Registry**: `ghcr.io/0xerr0r/blocky`

#### 2. Navidrome (`/navidrome`)
A cloud-native, high-performance music streaming server subsystem compliant with Subsonic/Madsonic API specifications.
* **Capability**: Multithreaded library indexing, metadata extraction, and streaming abstraction.
* **Image Registry**: `deluan/navidrome`

### Network Topology & Port Matrix


| Subsystem | Container Port | Host Port | Network Layer | Boundary / Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Blocky DNS** | `53/udp` | `53` (or `5353`) | Layer 4 (UDP) | Ingress Network Resolution |
| **Blocky DNS** | `53/tcp` | `53` (or `5353`) | Layer 4 (TCP) | TCP Fallback Resolution |
| **Blocky API** | `4000/tcp` | `4000` | Layer 7 (HTTP) | Telemetry, Metrics & Health |
| **Navidrome UI** | `4533/tcp` | `4533` | Layer 7 (HTTP) | Media Streaming Ingress |

---