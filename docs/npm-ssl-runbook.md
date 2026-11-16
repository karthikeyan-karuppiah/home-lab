# Authelia + Nginx Proxy Manager (NPM) SSL & SSO Runbook

## 1. Why a Custom Wildcard SSL Certificate Is Needed
- Let's Encrypt only issues certificates for public internet TLDs (`.com`, `.se`, `.org`). It rejects private local domains like `*.home.lab`.
- Authelia requires HTTPS (`https://`) to save `Secure` session cookies and support WebAuthn / Passkeys.
- A single self-signed wildcard certificate (`*.home.lab` + `home.lab`) covers all current and future subdomains (`auth.home.lab`, `music.home.lab`, etc.).

---

## 2. Generate & Install the Wildcard SSL Certificate on TNAS (CLI)

### Why We Use TNAS CLI + SQLite Instead of the Web UI
- **Browser upload limitation:** Clicking **Choose File** in NPM's web UI opens the local file picker on your client machine (Windows), whereas we want to generate and keep the certificate files directly on the TNAS server without transferring private keys across devices.
- **Why SQLite registration is required:** NPM does not auto-discover certificates from folders on disk. Normally, uploading via the web UI performs two actions behind the scenes: inserting a metadata row into `/data/database.sqlite` (which assigns a `certificate.id` and populates the SSL dropdown in the UI) and saving the files to `/data/custom_ssl/npm-<ID>/`. Because we generate the files via CLI on TNAS, the script below performs both steps explicitly.

### All-in-One TNAS Rebuild Script
If you ever rebuild Nginx Proxy Manager from scratch and wipe its `/data` volume, run this script directly on your TNAS:

```bash
# 1. Auto-detect the Nginx Proxy Manager container name
NPM_CONTAINER=\$(docker ps --format '{{.Names}}\t{{.Image}}' | awk '/nginx-proxy-manager/{print \$1; exit}')
echo "Using NPM container: \$NPM_CONTAINER"

# 2. Generate a 10-year wildcard certificate for *.home.lab in /tmp
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /tmp/homelab.key -out /tmp/homelab.crt \
  -subj "/CN=*.home.lab" \
  -addext "subjectAltName=DNS:*.home.lab,DNS:home.lab"

# 3. Register the certificate in NPM's SQLite database and capture its assigned ID
CERT_ID=\$(docker exec -i "\$NPM_CONTAINER" node -e '
const sqlite3 = require("/app/node_modules/sqlite3").verbose();
const db = new sqlite3.Database("/data/database.sqlite");
const now = new Date().toISOString().replace("T", " ").slice(0, 19);
db.run(
  `INSERT INTO certificate (created_on, modified_on, owner_user_id, is_deleted, provider, nice_name, domain_names, expires_on, meta)
   VALUES (?, ?, 1, 0, "other", "Home Lab Wildcard", ?, "2036-11-15 00:00:00", "{}")`,
  [now, now, JSON.stringify(["*.home.lab", "home.lab"])],
  function(err) {
    if (err) { console.error(err); process.exit(1); }
    process.stdout.write(String(this.lastID));
    db.close();
  }
);
')
echo "Registered certificate with ID: \$CERT_ID"

# 4. Create NPM's expected folder (/data/custom_ssl/npm-<ID>/) and copy the cert & key
docker exec "\(NPM_CONTAINER" mkdir -p "/data/custom_ssl/npm-\){CERT_ID}"
docker cp /tmp/homelab.crt "\({NPM_CONTAINER}:/data/custom_ssl/npm-\){CERT_ID}/fullchain.pem"
docker cp /tmp/homelab.key "\({NPM_CONTAINER}:/data/custom_ssl/npm-\){CERT_ID}/privkey.pem"

# 5. Clean up temporary key files from /tmp and restart NPM
rm -f /tmp/homelab.crt /tmp/homelab.key
docker restart "\$NPM_CONTAINER"
```

### Post-Install Steps in NPM Web UI (`http://192.168.1.110:81`)
> **Important:** NPM's Nginx config generator hardcodes `/data/custom_ssl/npm-<ID>/fullchain.pem` and `privkey.pem`. Until those files exist and you save each Proxy Host in the UI, NPM will not write the `.conf` files to `/data/nginx/proxy_host/`.

1. Open **Proxy Hosts** in NPM (`http://192.168.1.110:81`).
2. Edit each host (`auth.home.lab`, `music.home.lab`), select **`Home Lab Wildcard`** under the **SSL** tab, enable **Force SSL**, and click **Save**.
3. Verify the Nginx `.conf` files were generated inside the container:
   ```bash
   docker exec -it nginx-proxy-manager ls -la /data/nginx/proxy_host/
   ```

---

## 3. Nginx Proxy Manager Host Configurations (Port 8443)

### A. Authelia Portal (`auth.home.lab`)
- **Details:** Scheme `http`, Forward Host `authelia`, Forward Port `9091`
- **SSL:** `Home Lab Wildcard`, **Force SSL** `On`
- **Advanced (`⚙`):**
  ```nginx
  proxy_set_header X-Forwarded-Host \$http_host;
  proxy_set_header X-Forwarded-Port 8443;
  ```
  *(Ensures Authelia sees `:8443` when matching `session.cookies` in `configuration.yml`.)*

### B. Protected Apps (Example: `music.home.lab` → Navidrome)
- **Details:** Scheme `http`, Forward Host `192.168.1.110` (or `navidrome`), Forward Port `4533`
- **SSL:** `Home Lab Wildcard`, **Force SSL** `On`
- **Advanced (`⚙`):**
  ```nginx
  location /internal/authelia/authz {
      internal;
      proxy_pass http://authelia:9091/api/authz/forward-auth;

      proxy_set_header X-Original-Method \$request_method;
      proxy_set_header X-Original-URL \$scheme://\(http_host\)request_uri;
      proxy_set_header X-Forwarded-For \$remote_addr;
      proxy_set_header Content-Length "";
      proxy_set_header Connection "";

      proxy_pass_request_body off;
  }

  auth_request /internal/authelia/authz;
  auth_request_set \(target_url\)scheme://\(http_host\)request_uri;
  auth_request_set user upstream_http_remote_user;
  auth_request_set groups upstream_http_remote_groups;
  auth_request_set name upstream_http_remote_name;
  auth_request_set email upstream_http_remote_email;

  proxy_set_header Remote-User \$user;
  proxy_set_header Remote-Groups \$groups;
  proxy_set_header Remote-Name \$name;
  proxy_set_header Remote-Email \$email;

  error_page 401 =302 https://home.lab\$target_url;
  ```

---

## 4. Next Steps (Resuming 2FA Setup)
1. Open `https://home.lab` and log in as `karthikeyan`.
2. Click **ADD** under **One-Time Password** (or **WebAuthn Credentials** for Face ID / Passkey).
3. If using One-Time Password, grab the registration URL from the filesystem notifier on TNAS:
   ```bash
   cat /Volume1/DockerAppsData/authelia/config/notification.txt
   ```
4. Open that URL on your phone/PC, scan the QR code in your authenticator app, and verify the 6-digit code.
5. Test SSO by visiting `https://home.lab`.
