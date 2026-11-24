# ADR-003: Enforce a WireGuard-Only Zero-Trust Network Perimeter

* **Status:** Accepted
* **Deciders:** Karthikeyan Karuppiah

## Context and Problem Statement
Self-hosted services (reverse proxies, identity providers, DNS resolvers, and administrative dashboards) are frequent targets of automated internet-wide vulnerability scanning and credential-stuffing attacks when exposed via public ports (`80/tcp`, `443/tcp`). We needed secure, always-on remote access from mobile (iOS) and desktop clients without exposing web applications to the public internet or degrading mobile battery life.

## Decision Drivers
* **Minimal Attack Surface:** Eliminate unauthenticated HTTP/HTTPS endpoints from the public WAN interface.
* **Client Power Efficiency:** Maintain always-on mobile VPN connectivity without excessive iOS background battery drain.
* **Zero Third-Party Control Plane:** Avoid external coordination servers or third-party identity dependencies for core network reachability.
* **Defense in Depth:** Retain internal TLS termination (`Traefik`), SSO/2FA (`Authelia`), and DNS filtering (`Blocky`) even for authenticated VPN clients.

## Considered Options
1. **Self-Hosted WireGuard (`wg-easy`, `51820/udp`) + Internal Reverse Proxy & Authelia**
2. **Tailscale (Managed Coordination Plane + Userspace WireGuard Go Daemon)**
3. **Public Port Forwarding (`80/443`) + Reverse Proxy + CrowdSec / Fail2Ban**

## Decision Outcome
**Chosen option: "Self-Hosted WireGuard (`51820/udp`)"**, after empirically testing Tailscale in production and observing significant iOS battery drain caused by background coordination heartbeats, DERP relay keepalives, and userspace Go packet processing. Native WireGuard uses stateless, silent cryptography with zero background chatter when idle.

### Positive Consequences
* **Negligible Mobile Battery Impact:** Native WireGuard remains completely silent on the network when no packets are transmitted, eliminating the continuous iOS background wakeups experienced with Tailscale.
* **Near-Zero External Attack Surface:** External port scans reveal zero open TCP ports; WireGuard silently drops any UDP packet lacking a valid cryptographic handshake.
* **Self-Sovereign Control Plane:** Peer keys and routing are managed 100% locally with zero dependency on external SaaS coordination servers.
* **Full DNS & Proxy Integration:** Remote clients seamlessly inherit `Blocky` DNS ad/malware filtering and internal `Traefik` + `Authelia` routing.

### Negative Consequences
* **Manual NAT Port-Forwarding:** Requires forwarding a single UDP port (`51820/udp`) and Dynamic DNS (DDNS) on the edge router, unlike Tailscale's NAT traversal.
* **Client Provisioning:** Adding a new device requires importing a WireGuard peer configuration rather than logging into a SaaS SSO app.
