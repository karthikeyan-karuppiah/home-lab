# Homelab Single Sign-On (SSO) & Session Architecture Guide

**Infrastructure Stack:** TrueNAS (`192.168.1.110`) • WireGuard (`wg-easy`) • Blocky DNS • Nginx Proxy Manager (NPM) • Authelia `v4.39.28` • Redis • Navidrome

---

## 1. End-to-End Request & Authentication Flow

When you access a protected homelab service such as Navidrome (`https://music.home.lab:8443`) from your phone over cellular data, your traffic passes through six distinct layers:

```text
[iPhone / Android Client]
        │  (1) Encrypted VPN Tunnel over 5G
        ▼
[WireGuard (wg-easy)] ──► Routes DNS queries to Blocky DNS (Port 53)
        │  (2) Resolves *.home.lab -> 192.168.1.110
        ▼
[Nginx Proxy Manager (Port 8443)]
        │  (3) Terminates TLS (*.home.lab) & runs internal auth subrequest
        ▼
[Authelia (Port 9091)] ◄──► [Redis (Port 6379)] (Session Store)
        │  (4) Verifies 'authelia_session' cookie
        ├─► Invalid / Missing (HTTP 401): Redirects to https://auth.home.lab:8443
        └─► Valid (HTTP 200): Injects Remote-User headers & forwards to backend
                │
                ▼
        [Navidrome (Port 4533)]
```

### Step-by-Step Lifecycle
1. **VPN & DNS Resolution:** WireGuard connects your phone to your TrueNAS host (`192.168.1.110`) and sets **Blocky DNS** as your resolver. Blocky maps both `auth.home.lab` and `music.home.lab` to `192.168.1.110`.
2. **Reverse Proxy & Subrequest:** Nginx Proxy Manager (NPM) receives the HTTPS request on port `8443`. Before forwarding traffic to Navidrome, NPM sends an internal subrequest (`/internal/authelia/authz`) to Authelia's `/api/authz/auth-request` endpoint.
3. **Authentication Check:**
   * If you are not logged in, Authelia returns `HTTP 401 Unauthorized`. NPM intercepts this `401` and redirects your browser (`HTTP 302`) to `https://auth.home.lab:8443/?rd=https%3A%2F%2Fmusic.home.lab%3A8443%2F`.
   * Once you complete 1FA (username + password) and 2FA (6-digit TOTP), Authelia creates a session record in **Redis** and issues a session cookie to your browser.
4. **Authorized Access:** Your browser redirects back to `https://music.home.lab:8443`, automatically attaching the session cookie. Authelia validates the cookie against Redis, returns `HTTP 200 OK`, and NPM proxies you directly into Navidrome.

---

## 2. How the Session Cookie Works (`configuration.yml`)

The cross-subdomain session cookie is configured directly in your Authelia `configuration.yml` under the `session:` block:

```yaml
session:
  name: 'authelia_session'   # Cookie identifier stored in the browser
  expiration: '12h'          # Total maximum lifetime of a session
  inactivity: '2h'           # Session expires if idle for 2 hours

  cookies:
    - domain: 'home.lab'     # Root domain scope (shared across all *.home.lab hosts)
      authelia_url: 'https://auth.home.lab:8443'
      default_redirection_url: 'https://music.home.lab:8443'

  redis:
    host: 'authelia-redis'
    port: 6379
```

### Cookie Attributes & Security Flags
When you log in on `auth.home.lab:8443`, Authelia sends a `Set-Cookie` HTTP header containing both your configured values and automatic security flags:

| Attribute | Source | Purpose |
| :--- | :--- | :--- |
| **`authelia_session=<id>`** | `session.name` | A random, cryptographically signed session token pointing to your session data in Redis. |
| **`Domain=home.lab`** | `cookies[].domain` | Instructs the browser to send this cookie to **every** subdomain under `home.lab` (e.g., `auth.home.lab` and `music.home.lab`). |
| **`Secure`** | Automatic (`https://` URL) | Strictly forbids the browser from transmitting or saving the cookie over unencrypted or untrusted TLS connections. |
| **`HttpOnly`** | Automatic | Prevents client-side JavaScript from reading the cookie, protecting against Cross-Site Scripting (XSS) theft. |
| **`SameSite=Lax`** | Automatic (Default) | Allows the cookie to be sent during top-level cross-subdomain redirects (`auth.home.lab` → `music.home.lab`) while blocking cross-site forgery. |

### Step-by-Step: Who Checks the Wristband?
1. **Your Phone → Nginx Proxy Manager (NPM):**  
   When you open `https://music.home.lab:8443`, your browser automatically attaches the `authelia_session` cookie (the wristband) to the web request and sends it to NPM.
2. **NPM → Authelia (`/api/authz/auth-request`):**  
   Before letting your request reach Navidrome, NPM pauses it and quietly asks Authelia in the background: *"Hey, this person is trying to enter `music.home.lab` and is wearing this `authelia_session` wristband—is it valid?"*
3. **Authelia → Redis (`authelia-redis:6379`):**  
   Authelia takes the wristband ID, looks it up in Redis (your session database), and verifies two things:
   * Is the wristband real and not expired?
   * Did this user pass 2FA (`two_factor`), which `music.home.lab` requires?
4. **Authelia → NPM → Navidrome:**
   * **If valid (`200 OK`):** Authelia tells NPM *"Let them in!"* NPM then forwards your request to Navidrome (port `4533`), and your music library loads.
   * **If missing or invalid (`401 Unauthorized`):** Authelia tells NPM *"No valid wristband—send them back to the login desk at `auth.home.lab:8443`."*

---

## 3. Why Android Worked While iPhone Looped

Both devices hit the exact same TrueNAS backend, but their browser networking engines handle untrusted self-signed certificates differently:

* **Android (Chromium Engine):** When you bypass the *"Your connection is not private"* warning, Chromium records a temporary security exception for that session. It saves the `Secure` cookie from `auth.home.lab:8443`, shares it across `Domain=home.lab` to `music.home.lab:8443`, and loads Navidrome.
* **iPhone (Apple WebKit Engine):** Apple requires every browser on iOS (Safari, Chrome, Firefox, Brave) to use **iOS WebKit**. Under WebKit's security policy, any certificate not anchored to a trusted Root Certificate Authority (CA) is treated as untrusted. Even after tapping through a browser warning, **iOS WebKit silently drops `Secure` cookies across subdomains**. Consequently, every time your iPhone redirects from `auth.home.lab:8443` to `music.home.lab:8443`, it arrives without the `authelia_session` cookie, triggering an infinite `401` login loop.

---

## 4. Resolving iOS TLS Trust (Local Root CA + Wildcard Cert)

To satisfy iOS WebKit's security requirements, you must generate a **Local Root CA** and sign a **SAN Wildcard Certificate** valid for **825 days or fewer** (Apple's strict maximum validity period for leaf certificates).

### Step 1: Generate the Root CA and Wildcard Certificate on TrueNAS
Run these commands in your TrueNAS shell:

```bash
mkdir -p /tmp/certs && cd /tmp/certs

# 1. Create Private Root CA (10-year validity)
openssl genrsa -out home-lab-ca.key 4096
openssl req -x509 -new -nodes -key home-lab-ca.key -sha256 -days 3650 \
  -out home-lab-ca.crt -subj "/CN=HomeLab Root CA"

# 2. Create Wildcard Key and Certificate Signing Request (CSR)
openssl genrsa -out home-lab.key 2048
openssl req -new -key home-lab.key -out home-lab.csr -subj "/CN=*.home.lab"

# 3. Define Subject Alternative Names (SANs - Mandatory for iOS)
cat <<EOF > san.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.home.lab
DNS.2 = home.lab
EOF

# 4. Sign the Wildcard Certificate (Max 825 days for iOS compliance)
openssl x509 -req -in home-lab.csr -CA home-lab-ca.crt -CAkey home-lab-ca.key \
  -CAcreateserial -out home-lab.crt -days 825 -sha256 -extfile san.ext
```

### Step 2: Import into Nginx Proxy Manager (NPM)
1. Open NPM (`http://192.168.1.110:81`) and go to **SSL Certificates → Add SSL Certificate → Custom**.
2. Upload `/tmp/certs/home-lab.key` as the **Certificate Key** and `/tmp/certs/home-lab.crt` as the **Certificate**.
3. Assign this certificate to both **`auth.home.lab`** and **`music.home.lab`** Proxy Hosts.

### Step 3: Install & Enable Full Trust on iOS
1. Send `/tmp/certs/home-lab-ca.crt` to your iPhone (AirDrop, email, or iCloud Drive) and tap it to download the profile.
2. Open **Settings → General → VPN & Device Management** and install **`HomeLab Root CA`**.
3. Navigate to **Settings → General → About → Certificate Trust Settings**.
4. Under *Enable Full Trust for Root Certificates*, toggle **ON** **`HomeLab Root CA`**.
5. Force-close Chrome/Safari, reconnect to WireGuard, and open `https://music.home.lab:8443`.
