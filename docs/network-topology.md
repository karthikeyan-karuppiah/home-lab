# How Each Connection Works Across Your Compose Files

Your containers connect across **three distinct network layers**:
1. **Layer 1 — External Host / LAN Layer (`192.168.1.100`):** Uses host ports for VPN entry, DNS resolution, and reverse proxy ingress.
2. **Layer 2 — Shared Internal Docker Bridge (`proxy`):** Where containers talk directly by container name with zero host ports exposed.
3. **Layer 3 — Micro-Segmented Backend Network (`authelia-internal`):** An `internal: true` network isolating Authelia's Redis session store from every other container.

---

## End-to-End Wiring Diagram

```text
[ iPhone (10.8.0.2 over 5G) ]
       │
       │ 1. Encrypted UDP tunnel to Router:51820 ──► NAS (192.168.1.100:51820)
       ▼
┌───────────────────────────────────────────────────────────────────────────────────┐
│  Layer 1: TerraMaster NAS Host Network (192.168.1.100)                            │
│                                                                                   │
│  ┌─────────────────────┐    2. DNS Query (music.home)     ┌────────────────────┐  │
│  │      wg-easy        │ ───────────────────────────────► │       blocky       │  │
│  │ (UDP 51820 on Host) │ ◄─────────────────────────────── │  (Port 53 on Host) │  │
│  └─────────────────────┘    Returns: 192.168.1.100        └────────────────────┘  │
│             │                                                                     │
│             │ 3. HTTP Request (Host: music.home -> 192.168.1.100:8080)            │
│             ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │  Layer 2: Shared Docker Bridge Network ("proxy")                            │  │
│  │                                                                             │  │
│  │  ┌───────────────────────┐   4. Sub-Request    ┌─────────────────────────┐  │  │
│  │  │  nginx-proxy-manager  │ ──────────────────► │        authelia         │  │  │
│  │  │  (Host 8080 -> :80)   │ ◄────────────────── │    (Internal :9091)     │  │  │
│  │  └───────────────────────┘    200 OK / 401     └────────────┬────────────┘  │  │
│  │             │                                               │               │  │
│  │             │ 5. Proxy Pass (http://navidrome:4533)         │               │  │
│  │             ▼                                               │               │  │
│  │  ┌────────────────────────────────────────────────┐         │               │  │
│  │  │  Target App (navidrome / wg-easy:51821)        │         │               │  │
│  │  └────────────────────────────────────────────────┘         │               │  │
│  └─────────────────────────────────────────────────────────────┼───────────────┘  │
│                                                                │                  │
│                                      4b. Session Lookup (:6379)│                  │
│                                                                ▼                  │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │  Layer 3: Micro-Segmented Internal Network ("authelia-internal")            │  │
│  │                                                                             │  │
│  │  ┌───────────────────────────────────────────────────────────────────────┐  │  │
│  │  │  authelia-redis (Zero external/LAN access, isolated from proxy net)   │  │  │
│  │  └───────────────────────────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Packet Flow in Your Exact Compose Files

When you open `http://music.home:8080` on your iPhone over 5G, traffic travels through these five steps:

### 1. iPhone $\rightarrow$ `wg-easy` (Host Port `51820/udp`)
* **In your Compose file:** `ports: - "51820:51820/udp"` and `sysctls: - net.ipv4.ip_forward=1`.
* **What happens:** Your router forwards external port `51820/udp` to `192.168.1.100:51820`. Once `wg-easy` decrypts your phone's packet, `ip_forward=1` allows the Linux kernel on your TerraMaster NAS to route traffic from your virtual VPN subnet (`10.8.0.0/24`) onto your NAS's LAN IP (`192.168.1.100`).

### 2. `wg-easy` $\rightarrow$ `blocky` (Host Port `53/udp` & `53/tcp`)
* **In your Compose files:**
  * Inside `wg-easy`'s `docker-compose.enc.env`, `WG_DEFAULT_DNS` is set to your NAS IP (`192.168.1.100`) or VPN gateway (`10.8.0.1`).
  * Inside `blocky`'s `docker-compose.yml`, `ports: - "53:53/udp"` binds Blocky directly to port `53` on your NAS.
* **What happens:** Because `wg-easy` is NOT connected to Blocky via Docker Compose `depends_on`, they meet on the **host network interface**. Your iPhone sends a standard DNS packet to `192.168.1.100:53`, Docker's port mapping hands it to `blocky`, and Blocky replies: *"`music.home` is at `192.168.1.100`."*

### 3. iPhone $\rightarrow$ `nginx-proxy-manager` (Host Port `8080:80` / `8443:443`)
* **In your Compose file:** `ports: - "8080:80"` and `"8443:443"`.
* **What happens:** Now that your phone knows `music.home` = `192.168.1.100`, your browser connects to `192.168.1.100:8080` (avoiding TerraMaster TOS's native `80`/`443` admin ports). Docker's port mapping forwards that traffic straight into `nginx-proxy-manager` on internal port `80`.

### 4. `nginx-proxy-manager` $\leftrightarrow$ `authelia` $\rightarrow$ Apps (Internal `proxy` Network)
* **In your Compose files:** `networks: - proxy` (created by NPM with `name: proxy` and joined by `authelia`, `navidrome`, and `wg-easy` via `external: true`).
* **What happens:** From this point onward, traffic **never touches host ports again**. Inside the isolated `proxy` bridge network, Docker's built-in DNS lets containers reach each other by container name:
  * NPM asks **`http://authelia:9091`** to verify your login + 2FA session.
  * Once Authelia approves, NPM forwards the request to **`http://navidrome:4533`** (or **`http://wg-easy:51821`** for your WireGuard admin UI).

### 5. `authelia` $\leftrightarrow$ `authelia-redis` (Internal `authelia-internal` Network)
* **In your Compose file:** `networks: - authelia-internal` defined with `internal: true`, attached **only** to `authelia` and `redis` (`container_name: authelia-redis`).
* **What happens:** When Authelia validates or creates your SSO session in Step 4, it reads and writes session tokens to **`redis:6379`** over this isolated backend network. Because `authelia-redis` is not on the `proxy` network and exposes no host ports, no other container on your NAS can query or tamper with active login sessions.

---

## Why This Three-Layer Design Is Smart

1. **External / VPN entry (`51820`, `53`, `8080`, `8443`)** uses **host ports** so your iPhone's OS networking stack can reach WireGuard, Blocky DNS, and NPM directly over the VPN tunnel.
2. **Backend services (`authelia`, `navidrome`, `wg-easy` UI)** stay on the **internal `proxy` Docker network** with zero host ports exposed—meaning nobody on your home LAN or VPN can bypass NPM + Authelia by hitting `192.168.1.100:4533` or `192.168.1.100:51821` directly.
3. **Session storage (`authelia-redis`)** sits on a dedicated **`internal: true` network** (`authelia-internal`), enforcing strict micro-segmentation so even a compromised application container on `proxy` cannot reach your session store.
