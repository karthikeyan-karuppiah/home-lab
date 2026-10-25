## 🛠️ Step-by-Step Technical Breakdown

## 🗺️ High-Level Architectural Flowchart

```text
[ iPhone Mobile Data Session ]
(Targeting: http://music.home:8080)
              │
              ▼
[ Step 1: iPhone Local Routing Evaluation ]
Checks: Is target IP inside your AllowedIPs rule?
(AllowedIPs = <YOUR_NAS_LOCAL_IP_SUBNET>, 10.8.0.0/24)
              │
              ├─► (No)  ──► Bypasses Home Lab (Goes to Normal Internet)
              │
              └─► (Yes) ──► Diverts directly into secure VPN tunnel
                                   │
                                   ▼
                      🔐 Layer 1: WG-EASY Container
                      (Receives and decrypts tunnel traffic)
                                   │
                                   ▼
                      [ Step 2: Injected DNS Lookup Request ]
                      iPhone asks: "Where is music.home?"
                                   │
                                   ▼
                      🗺️ Layer 2: BLOCKY Container
                      (Intercepts name query on Port 53)
                      Resolves domain name to: <YOUR_NAS_LOCAL_IP>
                                   │
                                   ▼
                      [ Step 3: Local Network Execution ]
                      Traffic knocks on local Port 8080
                                   │
                                   ▼
                      🔀 Layer 3: NGINX PROXY MANAGER
                      (Intercepts traffic on Port 8080)
                      Reads the incoming hostname "music.home"
                      Forwards traffic internally to Port 4533
                                   │
                                   ▼
                      🎵 Layer 4: NAVIDROME Container
                      (Intercepts traffic on Port 4533)
                                   │
                                   ▼
                      [ Read-Only Storage Mounts ]
                      Pulls audio files from <YOUR_MUSIC_FOLDER_PATH>
```

### Step 1: Client-Side Edge Partitioning (Split-Tunneling)
When your iPhone is out on a cellular data connection, it evaluates every single network request before sending it out. Because we switched our infrastructure configuration from a **Full Tunnel** (`0.0.0.0/0`) to a **Split Tunnel**, the phone behaves as a dual-router:

- **Regular Public Request:** If you navigate to `google.com`, your iPhone checks its local WireGuard interface configuration rules. `google.com` does not match your home lab parameters, so the data is sent directly over standard mobile carrier networks. Your home internet upload speed is completely unaffected.
- **Targeted Homelab Request:** The exact millisecond you attempt to pull a stream from `http://music.home:8080`, your iPhone checks its local routing tables. The target matches your home network space, so your iPhone encrypts the payload packet using high-performance cryptographic keys and routes it over the internet to your **DuckDNS** endpoint domain name.



### Step 2: The Gateway Entrance & Packet Handoff (`wg-easy`)
The incoming encrypted phone packet hits your residential home internet gateway router. 

1. **The Edge Guard:** Your router's port forwarding rules are restricted to listen *exclusively* for port **`51820` (UDP)**. It flags the incoming packet and throws it directly to your physical NAS IP interface layout.
2. **Docker Container Capture:** Inside the Docker layer, the `wg-easy` service block uses its mapped ports properties to monitor the NAS physical port:
   ```yaml
   ports:
     - 51820:51820/udp
   ```
3. **The Kernel Bridge:** Once inside, `wg-easy` validates your phone's signature and decrypts the package. Because we added the system configuration parameter flag `net.ipv4.ip_forward=1`, the host operating system kernel gives the container explicit clearance to pass this data outside of its own boundaries and across your other internal Docker container networks.



### Step 3: Domain Resolution Hijacking (`blocky`)
Now that the packet is past the front gate, your iPhone needs to translate the plain text string `music.home` into a numerical address it can communicate with. 

1. **The Injected Command:** When the WireGuard session first shook hands, your container injected your internal target address configuration parameter directly into your phone’s memory (`WG_DEFAULT_DNS`). Your phone automatically routes the DNS query straight to your local NAS network interface on Port 53.
2. **The Port 53 Hijack:** Port 53 is the global standard channel for internet name lookups. Inside your deployment files, the **Blocky** proxy container has locked down and claimed exclusive control over that network port on your NAS system:
   ```yaml
   ports:
     - "53:53/udp"
     - "53:53/tcp"
   ```
   Because Blocky owns Port 53 on the NAS IP, your TerraMaster operating system automatically passes your phone's domain lookup query directly into Blocky.
3. **Mapping Execution:** Blocky reads the question (*"Where is music.home?"*), opens its `config.yml` text map file, skips the public internet upstream lookups, and returns your local internal variable:
   ```yaml
   customDNS:
     mapping:
       music.home: <YOUR_NAS_LOCAL_IP>
   ```
   *Note: DNS records only resolve names to raw IPs and are completely blind to port channels. Blocky returns the raw NAS IP address, and your browser reappends the requested port extension (`:8080`) to the destination envelope.*



### Step 4: The Intelligent Interception (`nginx-proxy-manager`)
Now that your iPhone has resolved the name string down to an IP, it executes a web request targeting **`http://<YOUR_NAS_LOCAL_IP>:8080`**.

1. **Bypassing the Host System:** Because TerraMaster OS (TOS) completely occupies Port 80 on your network card, targeting port **`8080`** allows your data payload to entirely bypass the main NAS management workspace desktop portal.
2. **The Reverse Proxy Receptionist:** Inside Docker, Nginx Proxy Manager is monitoring port `8080` for active traffic streams:
   ```yaml
   ports:
     - "8080:80"
   ```
   Nginx intercepts the request, pulls open the data packet, and reads the incoming host header name: **`music.home`**.



### Step 5: Vault Execution (`navidrome`)
Nginx Proxy Manager checks its internal routing index database table for the `music.home` rule block.

1. **The Internal Handoff:** Nginx matches the domain to your custom entry rule and sees that the traffic needs to be forwarded to your music server container. It shifts the payload internally over to port **`4533`**.
2. **Isolated Streaming:** Your NAS operating system drops the traffic straight inside your **Navidrome** core container stack. Navidrome validates your user authentication profile session, reads your local audio tracks mounted via your read-only volume directory mapping, and pumps the secure music data stream back through your Nginx container, across the WireGuard network bridge, and directly onto your iPhone interface client!
