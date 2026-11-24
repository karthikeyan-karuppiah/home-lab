# Architecture Decision Records (ADRs)

This directory documents the key architectural choices, empirical trade-offs, and evolutionary roadmap behind this home-lab platform.

| ID | Decision | Status | Summary |
| :--- | :--- | :--- | :--- |
| [ADR-001](001-docker-compose-and-doco-cd-over-kubernetes.md) | Preserve TOS + Docker Compose + Doco-CD (With Talos K8s Roadmap) | Accepted | Protects native NAS RAID/storage stability on TOS while maintaining GitOps parity ahead of a future Talos Linux K8s migration. |
| [ADR-002](002-sops-and-age-over-hashicorp-vault.md) | Use Mozilla SOPS + `age` over HashiCorp Vault | Accepted | Enables zero-dependency encrypted secrets in Git without circular bootstrap dependencies. |
| [ADR-003](003-wireguard-only-zero-trust-perimeter.md) | Enforce a WireGuard-Only Zero-Trust Network Perimeter | Accepted | Eliminates public HTTP surface and resolves iOS battery drain observed with Tailscale's userspace daemon. |
| [ADR-004](004-traefik-over-nginx-proxy-manager.md) | Migrate Ingress from Nginx Proxy Manager to Traefik v3 | Accepted | Replaces stateful UI "ClickOps" with declarative label routing, non-root execution, and native Prometheus metrics. |
