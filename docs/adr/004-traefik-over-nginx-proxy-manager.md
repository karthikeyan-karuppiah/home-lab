# ADR-004: Migrate Ingress from Nginx Proxy Manager to Traefik v3

* **Status:** Accepted
* **Deciders:** Karthikeyan Karuppiah

## Context and Problem Statement
Nginx Proxy Manager (NPM) stores proxy hosts, middleware snippets, and TLS configurations inside a stateful SQLite database managed via a web UI ("ClickOps"). While functional, UI-driven configuration creates configuration drift, complicates Git code reviews, requires database backups to preserve routing rules, and runs with elevated container privileges.

## Decision Drivers
* **100% Declarative Infrastructure-as-Code (IaC):** Routing rules, TLS resolvers, and security headers must live in version-controlled YAML alongside application definitions.
* **Least-Privilege Container Security:** Eliminate root daemon privileges and raw `/var/run/docker.sock` mounts by pairing a non-root proxy with a read-only Docker Socket Proxy.
* **Native Identity & Observability Integration:** First-class `ForwardAuth` support for `Authelia` and native Prometheus HTTP RED metrics (Rate, Errors, Duration) for SLO alerting.

## Considered Options
1. **Traefik v3 + Read-Only Docker Socket Proxy**
2. **Nginx Proxy Manager (UI-Driven SQLite State)**
3. **Caddy (Caddyfile / Docker Proxy)**

## Decision Outcome
**Chosen option: "Traefik v3 + Read-Only Docker Socket Proxy"**, because it makes the entire ingress layer stateless, attaches routes directly to workloads via Docker Compose labels, and enforces strict CIS/OWASP container hardening.

### Positive Consequences
* **Zero ClickOps Drift:** Every HTTP router, TLS domain, and `Authelia` middleware attachment is declared in Git, linted in CI (`compose-lint`), and reconciled by `Doco-CD`.
* **Hardened Privilege Boundary:** Traefik runs as non-root (`UID 65532`) with a read-only root filesystem and communicates exclusively through `docker-socket-proxy` with mutating API endpoints disabled.
* **Native HTTP SLO Telemetry:** Exposes Prometheus latency histograms and status-code counters out of the box without sidecar log exporters.

### Negative Consequences
* **Steeper Initial Configuration:** Requires explicit static (`traefik.yml`) and dynamic (`middlewares.yml`) YAML definitions rather than point-and-click UI forms.
* **Label Verbosity:** Each exposed container requires 4–5 routing labels in its `docker-compose.yml`.
