# ADR-005: Use Authelia over Pocket ID for Universal ForwardAuth, OIDC, and Declarative Policy

* **Status:** Accepted
* **Deciders:** Karthikeyan Karuppiah

## Context and Problem Statement
Even behind a WireGuard VPN perimeter (ADR-003), administrative dashboards and internal services require centralized authentication and Single Sign-On (SSO) to enforce zero-trust defense-in-depth. While modern applications increasingly support OpenID Connect (OIDC), many self-hosted home-lab tools lack native OIDC integration and must be protected at the reverse-proxy layer (`ForwardAuth`). Additionally, all access policies must be declaratively managed via GitOps (`Doco-CD` + `SOPS`).

## Decision Drivers
* **Universal App Protection (`ForwardAuth` + `OIDC`):** Must protect both OIDC-capable apps and legacy/stateless web UIs that have no built-in authentication.
* **100% Declarative GitOps Configuration:** Access control rules, client registrations, and session policies must live in version-controlled YAML (`configuration.yml`) rather than a SQLite web UI database.
* **Flexible Multi-Factor Authentication:** Support hardware passkeys/WebAuthn alongside TOTP fallback so recovery is never locked to a single device ecosystem.
* **Low Resource Footprint:** Must run comfortably on a single-node TerraMaster NAS (~40 MB RAM) without heavy external databases.

## Considered Options
1. **Authelia (Go + Declarative YAML + ForwardAuth & OIDC)**
2. **Pocket ID (Lightweight Passkey-Only OIDC Provider)**

## Decision Outcome
**Chosen option: "Authelia"**, because it combines a lightweight Go runtime (~40 MB RAM) with native reverse-proxy `ForwardAuth`, full OIDC provider support, and 100% declarative YAML configuration—whereas Pocket ID is strictly an OIDC provider without native proxy `ForwardAuth` or Git-driven policy-as-code.

### Positive Consequences
* **Protects Every Service Behind Traefik:** Legacy dashboards without OIDC support are gated cleanly via a single `authelia@file` ForwardAuth middleware label, while modern apps use native OIDC.
* **Pure Policy-as-Code:** Domain-level access rules (e.g., enforcing 2FA on admin routes vs. 1FA on monitoring dashboards) are audited via Git Pull Requests and encrypted with SOPS.
* **Resilient MFA Options:** Supports WebAuthn/Passkeys (matching Pocket ID's strength) while retaining TOTP as a cross-platform fallback.

### Negative Consequences
* **More Verbose Initial Setup:** Requires configuring `configuration.yml` and SOPS-encrypted secrets manually rather than managing OIDC clients through Pocket ID's streamlined web UI.
