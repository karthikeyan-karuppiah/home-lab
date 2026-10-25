

## 🛠️ Step-by-Step Technical Breakdown

### Step 1: Client-Side Edge Partitioning (Split-Tunneling)
When your iPhone is out on a cellular data connection, it evaluates every single network request before sending it out. Because we switched our infrastructure configuration from a **Full Tunnel** (`0.0.0.0/0`) to a **Split Tunnel**, the phone behaves as a dual-router:

- **Regular Public Request:** If you navigate to `google.com`, your iPhone checks its local WireGuard interface configuration rules. `google.com` does not match your home lab parameters, so the data is sent directly over standard mobile carrier networks. Your home internet upload speed is completely unaffected.
- **Targeted Homelab Request:** The exact millisecond you attempt to pull a stream or request an address matching your custom local network subnet space, your iPhone encrypts the payload packet using high-performance cryptographic keys and routes it over the internet to your **DuckDNS** endpoint domain name.




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

1. **The Injected Command:** When the WireGuard session first shook hands, your container injected your internal target address configuration parameter directly into your phone’s memory. Your phone automatically routes the DNS query straight to your local NAS network interface on Port 53.
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
   Blocky responds down the tunnel to your phone: *"Go directly to your local NAS network address."*



### Step 4: Vault Execution (`navidrome`)
Now that your iPhone has successfully resolved the address layout via Blocky, it makes a standard web call over the encrypted tunnel straight to the destination point: **`http://<YOUR_NAS_LOCAL_IP>:4533`**.

1. Your NAS operating system checks its routing map, sees that port **`4533`** belongs to your **Navidrome** container, and lands the traffic right inside your music application core.
2. Navidrome authenticates your login profile, reads your local audio file media properties mounted securely via your read-only volume directory mapping, and pumps the encrypted music data stream cleanly back down the WireGuard tunnel directly to your iPhone app interface!