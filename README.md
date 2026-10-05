# CODESYS 4 Docker

Docker-based deployment of **CODESYS 4** with an NGINX HTTPS reverse proxy.

This package provides a ready-to-run CODESYS 4 environment for Linux systems, including **Raspberry Pi ARM64** and **AMD64** systems.

The deployment uses Docker images published on Docker Hub. Customers do **not** need to build Docker images or install the CODESYS 4 Debian package manually.

---

## 1. What You Get

This deployment provides:

- CODESYS 4 running inside Docker
- Linux-based CODESYS 4 runtime environment
- NGINX reverse proxy
- HTTPS access
- Automatically generated TLS certificate
- Automatic host-port detection
- Persistent CODESYS configuration
- Persistent TLS certificates
- ARM64 support
- AMD64 support
- Docker Compose deployment
- Automatic Docker image selection based on CPU architecture

### Architecture

```text
                         Web Browser
                              │
                              │ HTTP / HTTPS
                              ▼
                    ┌───────────────────┐
                    │   NGINX Container │
                    │                   │
                    │ HTTP :80          │
                    │ HTTPS :443        │
                    └─────────┬─────────┘
                              │
                              │ Docker Network
                              │ HTTP :8080
                              ▼
                    ┌───────────────────┐
                    │     CODESYS 4     │
                    │     Container     │
                    │                   │
                    │ c4-server :8080   │
                    └───────────────────┘
```

CODESYS 4 is **not directly exposed to the host network**.

Only NGINX is published to the host.

---

# 2. System Requirements

## Hardware

### ARM64

Examples:

- Raspberry Pi 4
- Raspberry Pi 5
- ARM64 industrial computers
- Other ARM64 Linux systems

### AMD64

Examples:

- Intel-based PCs
- AMD-based PCs
- Industrial PCs
- Linux servers
- Virtual machines

---

## Operating System

A Linux operating system with Docker support is required.

Examples:

- Debian
- Ubuntu
- Raspberry Pi OS
- Other compatible Linux distributions

---

# 3. Software Requirements

The following are required:

- Docker
- Docker Compose

Docker Compose may be available as either Docker Compose V2 or legacy Docker Compose.

Check Docker Compose V2:

```bash
sudo docker compose version
```

Or legacy Docker Compose:

```bash
sudo docker-compose version
```

The included startup script automatically detects which version is available.

---

# 4. Download the Deployment Package

Clone the deployment repository:

```bash
git clone https://github.com/Jugaadtech/codesys-4-docker.git
```

Enter the directory:

```bash
cd codesys-4-docker
```

Verify the deployment files:

```bash
ls
```

The deployment package contains the Docker Compose configuration and startup script required to run CODESYS 4.

---

# 5. Start CODESYS 4

The recommended way to start the deployment is:

```bash
sudo ./scripts/start.sh
```

The startup script automatically:

1. Checks Docker Compose availability.
2. Checks whether host port `80` is available.
3. Checks whether host port `443` is available.
4. Uses ports `80` and `443` when available.
5. Automatically selects alternative ports when required.
6. Pulls the required Docker images.
7. Starts the CODESYS 4 container.
8. Starts the NGINX HTTPS reverse proxy.
9. Displays the URL for accessing CODESYS 4.

---

# 6. Automatic Port Selection

The deployment is designed to coexist with existing applications on the Linux host.

For example, the host may already have:

- NGINX
- Apache
- Another web application
- Another Docker container
- Industrial/IoT services

The CODESYS deployment does **not** require existing services to be stopped.

## HTTP

The preferred HTTP port is:

```text
80
```

If port `80` is already occupied, the startup script searches for an available port starting from:

```text
8081
```

For example:

```text
8081
8082
8083
...
```

The first available port is selected.

## HTTPS

The preferred HTTPS port is:

```text
443
```

If port `443` is already occupied, the startup script searches for an available port starting from:

```text
8443
```

For example:

```text
8443
8444
8445
...
```

The first available port is selected.

---

# 7. Port Selection Examples

## Scenario 1 — Ports 80 and 443 Available

The deployment uses:

```text
HTTP  → 80
HTTPS → 443
```

Access:

```text
https://<device-ip>/
```

---

## Scenario 2 — Port 80 Occupied

For example, the host already has NGINX running on port 80.

The deployment may select:

```text
HTTP  → 8081
HTTPS → 443
```

Access CODESYS 4 through:

```text
https://<device-ip>/
```

HTTP access is available at:

```text
http://<device-ip>:8081/
```

---

## Scenario 3 — Port 443 Occupied

The deployment may select:

```text
HTTP  → 80
HTTPS → 8443
```

Access:

```text
https://<device-ip>:8443/
```

---

## Scenario 4 — Both Ports Occupied

The deployment may select:

```text
HTTP  → 8081
HTTPS → 8443
```

Access:

```text
https://<device-ip>:8443/
```

The actual ports selected are displayed by `start.sh`.

---

# 8. Example Startup Output

A typical startup may look like:

```text
============================================================
 CODESYS 4 Docker
 Automatic Host Port Detection
============================================================

Port 80 is already in use.
Selected HTTP port: 8081

Port 443 is already in use.
Selected HTTPS port: 8443

Selected ports:
  HTTP  : 8081
  HTTPS : 8443

Pulling Docker images...

Starting CODESYS 4...

============================================================
 CODESYS 4 Docker Started
============================================================

HTTP  : 8081
HTTPS : 8443

CODESYS 4 URL:

  https://192.168.1.100:8443/
```

Use the displayed HTTPS URL to access CODESYS 4.

---

# 9. Access CODESYS 4

After the deployment starts, use the URL displayed by:

```bash
sudo ./scripts/start.sh
```

For example:

```text
https://192.168.1.100/
```

or:

```text
https://192.168.1.100:8443/
```

depending on the automatically selected HTTPS port.

---

# 10. Set the `admin` User Password

CODESYS 4 runs using the Linux user:

```text
admin
```

For security, set a password for the `admin` user after the first deployment.

## Set Password

After the containers are running, execute:

```bash
sudo docker exec -it codesys-4 passwd admin
```

You will be prompted:

```text
New password:
Retype new password:
```

Enter the password you want to use.

If successful, the password will be updated for the `admin` Linux user inside the CODESYS 4 container.

---

## Alternative Method

You can also open a shell inside the CODESYS 4 container:

```bash
sudo docker exec -it codesys-4 bash
```

Then run:

```bash
passwd admin
```

Enter the new password.

When finished:

```bash
exit
```

---

## Verify the User

To verify that the `admin` user exists:

```bash
sudo docker exec -it codesys-4 id admin
```

You should see output similar to:

```text
uid=1000(admin) gid=1000(admin) groups=1000(admin),1004(codesys-4)
```

---

## Recommended First-Time Setup

After a fresh installation:

### Step 1 — Start CODESYS 4

```bash
sudo ./scripts/start.sh
```

### Step 2 — Set the admin password

```bash
sudo docker exec -it codesys-4 passwd admin
```

### Step 3 — Open the URL displayed by `start.sh`

For example:

```text
https://192.168.1.100:8443/
```

---

## Important

The command above sets the **Linux `admin` user password inside the CODESYS 4 container**.

This should not automatically be interpreted as a separate application-level CODESYS authentication password.

The Linux `admin` account is the account under which the CODESYS server runs.

If the CODESYS container is completely removed and recreated, the Linux user configuration may need to be configured again depending on the deployment state.

---

# 11. HTTPS Certificate

The NGINX container automatically generates a self-signed TLS certificate if one does not already exist.

The certificate is persisted in Docker volumes.

Therefore, restarting the containers does not normally generate a new certificate.

The certificate is intended for:

- Local development
- Engineering environments
- Test systems
- Internal networks
- Proof-of-concept deployments

Because the certificate is self-signed, a web browser may display a security warning.

This is expected.

---

# 12. Production TLS Certificates

For production deployments, a CA-issued TLS certificate can be used instead of the automatically generated self-signed certificate.

TLS termination remains at the NGINX reverse proxy.

CODESYS 4 continues to communicate internally through the Docker network.

For production environments, use certificates appropriate to the organization's security and certificate-management policy.

---

# 13. Docker Architecture

The deployment consists of two containers.

## CODESYS 4

Container:

```text
codesys-4
```

Internal port:

```text
8080
```

The CODESYS port is exposed only to the Docker network.

It is **not directly published to the host**.

---

## NGINX

Container:

```text
codesys-4-nginx
```

Internal ports:

```text
80
443
```

NGINX provides:

- HTTP
- HTTPS
- TLS termination
- Reverse proxy
- WebSocket forwarding
- Forwarded headers

NGINX forwards traffic internally to:

```text
http://codesys-4:8080
```

---

# 14. Docker Network

The containers communicate through:

```text
codesys-4-network
```

The network is created automatically by Docker Compose.

You normally do not need to configure the Docker network manually.

---

# 15. Persistent Data

The deployment uses persistent Docker storage.

## CODESYS Configuration

The host directory:

```text
/home
```

is mounted into the CODESYS container:

```text
/home:/home
```

This allows CODESYS user/project configuration stored under `/home` to persist.

---

## TLS Certificate

The following Docker volume stores the generated certificate:

```text
codesys-4-certs
```

---

## TLS Private Key

The following Docker volume stores the private key:

```text
codesys-4-private
```

These volumes prevent the TLS certificate and private key from being regenerated every time the container restarts.

---

# 16. Start / Stop / Restart

## Start

Recommended:

```bash
sudo ./scripts/start.sh
```

---

## Stop

Docker Compose V2:

```bash
sudo docker compose down
```

Legacy Docker Compose:

```bash
sudo docker-compose down
```

---

## Restart

Docker Compose V2:

```bash
sudo docker compose restart
```

Legacy Docker Compose:

```bash
sudo docker-compose restart
```

---

## Start Existing Containers

Docker Compose V2:

```bash
sudo docker compose up -d
```

Legacy Docker Compose:

```bash
sudo docker-compose up -d
```

For normal operation, it is recommended to use:

```bash
sudo ./scripts/start.sh
```

---

# 17. Check Container Status

Run:

```bash
sudo docker ps
```

You should see:

```text
codesys-4
codesys-4-nginx
```

You can also use:

```bash
sudo docker compose ps
```

or:

```bash
sudo docker-compose ps
```

---

# 18. View Logs

## CODESYS 4

```bash
sudo docker logs codesys-4
```

Follow the logs:

```bash
sudo docker logs -f codesys-4
```

## NGINX

```bash
sudo docker logs codesys-4-nginx
```

Follow the logs:

```bash
sudo docker logs -f codesys-4-nginx
```

---

# 19. Check Port Usage

To check ports on the Linux host:

```bash
sudo ss -lntp
```

Check port 80:

```bash
sudo ss -lntp | grep ':80 '
```

Check port 443:

```bash
sudo ss -lntp | grep ':443 '
```

The startup script performs this detection automatically.

---

# 20. Check Selected Runtime Ports

The startup script creates:

```text
.codesys-runtime.env
```

This file contains the ports selected for the current deployment.

For example:

```text
CODESYS_HTTP_PORT=8081
CODESYS_HTTPS_PORT=8443
```

View the selected ports with:

```bash
cat .codesys-runtime.env
```

---

# 21. Docker Images

The deployment uses published Docker images.

## CODESYS 4

```text
jugaadtech/codesys-4:1.0.0.0
```

## NGINX

```text
jugaadtech/codesys-4-nginx:1.0.0
```

The CODESYS image is published as a multi-architecture image.

Docker automatically selects the appropriate architecture.

For example:

```text
ARM64 → Raspberry Pi / ARM64 Linux
AMD64 → Intel / AMD Linux
```

No manual architecture-specific build is required for normal deployment.

---

# 22. Pull Latest Images

To manually pull the published images:

```bash
sudo docker compose pull
```

Then recreate the containers:

```bash
sudo docker compose up -d
```

For legacy Docker Compose:

```bash
sudo docker-compose pull
```

```bash
sudo docker-compose up -d
```

---

# 23. Updating the Deployment Package

If the deployment package was installed using Git, update it with:

```bash
git pull
```

Then run:

```bash
sudo ./scripts/start.sh
```

The startup script will use the published Docker images.

---

# 24. CODESYS User Configuration

The default CODESYS Linux user is:

```text
admin
```

The default configuration uses:

```text
CODESYS_USER=admin
CODESYS_UID=1000
CODESYS_GID=1000
CODESYS_GROUP_GID=1004
```

CODESYS is deliberately configured to run as a **non-root user**.

This is an important security requirement.

---

# 25. Security

The deployment follows these principles:

- CODESYS 4 does not run as root.
- CODESYS 4 is not directly exposed to the host network.
- NGINX provides the external HTTP/HTTPS interface.
- TLS private keys are stored in persistent Docker volumes.
- Existing host services are not automatically stopped.
- Host ports are automatically selected when standard ports are occupied.

For production systems, consider:

- CA-issued TLS certificates
- Network segmentation
- Firewall rules
- VPN or secure remote access
- Restricted management access
- Strong passwords
- Regular Docker image updates
- Operating-system security updates

---

# 26. Troubleshooting

## CODESYS Container Is Not Running

Check:

```bash
sudo docker ps -a
```

Then:

```bash
sudo docker logs codesys-4
```

---

## NGINX Container Is Not Running

Check:

```bash
sudo docker logs codesys-4-nginx
```

Check ports:

```bash
sudo ss -lntp
```

---

## Port 80 Is Already in Use

This is normally not an error.

Run:

```bash
sudo ./scripts/start.sh
```

The deployment automatically searches for another available HTTP port.

---

## Port 443 Is Already in Use

This is also supported.

Run:

```bash
sudo ./scripts/start.sh
```

The deployment automatically searches for another available HTTPS port beginning at `8443`.

---

## Browser Displays a Certificate Warning

The default deployment uses a self-signed certificate.

This is expected for development and internal deployments.

For production, use a CA-issued certificate.

---

## Cannot Access the URL

First check:

```bash
sudo docker ps
```

Then:

```bash
sudo docker logs codesys-4-nginx
```

Check the selected ports:

```bash
cat .codesys-runtime.env
```

Example:

```text
CODESYS_HTTP_PORT=8081
CODESYS_HTTPS_PORT=8443
```

Then access:

```text
https://<device-ip>:8443/
```

---

## Check CODESYS Container Connectivity

Check the CODESYS container:

```bash
sudo docker inspect codesys-4
```

Check the NGINX container:

```bash
sudo docker inspect codesys-4-nginx
```

Both containers should be connected to:

```text
codesys-4-network
```

---

# 27. Completely Remove the CODESYS Deployment

To stop and remove the containers:

```bash
sudo docker compose down
```

To also remove persistent Docker volumes:

```bash
sudo docker compose down --volumes
```

For legacy Docker Compose:

```bash
sudo docker-compose down --volumes
```

This removes the CODESYS Docker deployment resources including:

```text
codesys-4
codesys-4-nginx
codesys-4-network
codesys-4-certs
codesys-4-private
```

The host `/home` directory is **not deleted** by Docker Compose.

---

# 28. Fresh Reinstallation

For a completely fresh Docker deployment:

```bash
sudo docker compose down --volumes --remove-orphans
```

Then:

```bash
sudo ./scripts/start.sh
```

The required Docker images will be pulled again when necessary and the containers will be recreated.

---

# 29. Manual Docker Compose Deployment

The recommended customer method is:

```bash
sudo ./scripts/start.sh
```

Docker Compose can also be used manually.

## Start

```bash
sudo docker compose up -d
```

## Stop

```bash
sudo docker compose down
```

## Status

```bash
sudo docker compose ps
```

## Logs

```bash
sudo docker compose logs -f
```

For systems using legacy Docker Compose:

```bash
sudo docker-compose up -d
```

```bash
sudo docker-compose down
```

```bash
sudo docker-compose ps
```

```bash
sudo docker-compose logs -f
```

Manual Docker Compose operations are primarily intended for engineering and troubleshooting purposes.

---

# 30. Quick Start

For a normal customer installation:

```bash
git clone https://github.com/Jugaadtech/codesys-4-docker.git
```

```bash
cd codesys-4-docker
```

Start the deployment:

```bash
sudo ./scripts/start.sh
```

Set the `admin` password:

```bash
sudo docker exec -it codesys-4 passwd admin
```

The startup script will display the CODESYS 4 URL.

For example:

```text
https://192.168.1.100:8443/
```

Open the displayed URL in a browser.

---

# 31. Quick Reference

| Operation | Command |
|---|---|
| Download | `git clone https://github.com/Jugaadtech/codesys-4-docker.git` |
| Enter directory | `cd codesys-4-docker` |
| Start deployment | `sudo ./scripts/start.sh` |
| Set admin password | `sudo docker exec -it codesys-4 passwd admin` |
| Check status | `sudo docker compose ps` |
| View logs | `sudo docker compose logs -f` |
| Stop | `sudo docker compose down` |
| Restart | `sudo docker compose restart` |
| Pull images | `sudo docker compose pull` |
| Check containers | `sudo docker ps` |
| Check ports | `sudo ss -lntp` |
| Show selected ports | `cat .codesys-runtime.env` |
| Remove volumes | `sudo docker compose down --volumes` |

Legacy Docker Compose:

```bash
sudo docker-compose up -d
sudo docker-compose down
sudo docker-compose ps
sudo docker-compose logs -f
sudo docker-compose pull
```

---

# 32. Deployment Model

```text
                 Customer Linux System
                          │
                          │
                    GitHub Repository
                          │
                          ▼
                 docker-compose.yml
                          │
                          ▼
                     start.sh
                          │
             ┌────────────┴────────────┐
             │                         │
      Automatic Port              Docker Hub
        Detection                      │
             │                         │
             │                  Published Images
             │                         │
             └────────────┬────────────┘
                          ▼
                  ┌───────────────┐
                  │     NGINX     │
                  │ HTTPS Proxy   │
                  └───────┬───────┘
                          │
                          │ Docker Network
                          ▼
                  ┌───────────────┐
                  │  
