# CODESYS 4 Docker

Docker-based deployment of **CODESYS 4** with an NGINX HTTPS reverse proxy.

This package provides a ready-to-run CODESYS 4 environment for Linux systems, including **Raspberry Pi ARM64** and **AMD64** systems.

The deployment uses Docker images published on Docker Hub. Customers do **not** need to build the Docker images or install the CODESYS 4 Debian package manually.

---

## 1. What You Get

This deployment provides:

- CODESYS 4 running inside Docker
- Linux-based CODESYS 4 runtime environment
- NGINX reverse proxy
- HTTPS access
- Automatically generated TLS certificate for development/local deployments
- Automatic host-port detection
- Persistent CODESYS user/project configuration
- Persistent TLS certificates
- ARM64 support
- AMD64 support
- Docker Compose deployment
- Automatic Docker image selection based on CPU architecture

### Architecture

```text
                         Web Browser
                              │
                              │ HTTPS
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
                    │  CODESYS 4        │
                    │    Container      │
                    │                   │
                    │ c4-server :8080   │
                    └───────────────────┘
```

CODESYS 4 is **not directly exposed to the host network**.

Only NGINX is published to the host.

---

# 2. System Requirements

## Hardware

The deployment supports:

### ARM64

Examples:

- Raspberry Pi 4
- Raspberry Pi 5
- Other ARM64 Linux systems

### AMD64

Examples:

- Intel/AMD Linux PCs
- Industrial PCs
- Virtual machines
- Servers

---

## Operating System

A Linux operating system with Docker support is required.

For example:

- Debian
- Ubuntu
- Raspberry Pi OS
- Other compatible Linux distributions

---

# 3. Software Requirements

The following are required:

- Docker
- Docker Compose

Docker Compose may be available as either:

### Docker Compose V2

```bash
sudo docker compose version
```

or legacy Docker Compose:

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

Verify the files:

```bash
ls
```

The deployment package contains the required Docker Compose configuration and startup script.

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

The CODESYS deployment does **not** require the existing service to be stopped.

## HTTP

The preferred HTTP port is:

```text
80
```

If port 80 is already occupied, the startup script searches for an available port beginning with:

```text
8081
```

For example:

```text
8081
```

or:

```text
8082
```

or:

```text
8083
```

depending on availability.

## HTTPS

The preferred HTTPS port is:

```text
443
```

If port 443 is already occupied, the startup script searches for an available port beginning with:

```text
8443
```

For example:

```text
8443
```

or:

```text
8444
```

or:

```text
8445
```

depending on availability.

---

# 7. Example Port Scenarios

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

Access:

```text
https://<device-ip>/
```

HTTP access:

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

The actual ports are displayed by the startup script.

---

# 8. Example Startup Output

A typical deployment may display:

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

depending on the automatically selected port.

---

# 10. HTTPS Certificate

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

# 11. Production Certificates

For production deployments, a CA-issued certificate can be used instead of the automatically generated self-signed certificate.

The TLS termination remains at the NGINX reverse proxy.

The CODESYS 4 service itself continues to run internally over the Docker network.

---

# 12. Docker Architecture

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

NGINX forwards traffic to:

```text
http://codesys-4:8080
```

---

# 13. Docker Network

The containers communicate through:

```text
codesys-4-network
```

The network is created automatically by Docker Compose.

You normally do not need to configure the Docker network manually.

---

# 14. Persistent Data

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

This allows CODESYS user/project configuration to persist.

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

# 15. Start / Stop / Restart

## Start

Recommended:

```bash
sudo ./scripts/start.sh
```

---

## Stop

Using Docker Compose:

```bash
sudo docker compose down
```

If your system uses legacy Compose:

```bash
sudo docker-compose down
```

---

## Start Existing Deployment

If the runtime configuration has already been created:

```bash
sudo docker compose up -d
```

or:

```bash
sudo docker-compose up -d
```

For normal customer operation, however, it is recommended to use:

```bash
sudo ./scripts/start.sh
```

---

## Restart

```bash
sudo docker compose restart
```

or:

```bash
sudo docker-compose restart
```

---

# 16. Check Container Status

Run:

```bash
sudo docker ps
```

You should see containers similar to:

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

# 17. View Logs

### CODESYS 4

```bash
sudo docker logs codesys-4
```

Follow the logs:

```bash
sudo docker logs -f codesys-4
```

### NGINX

```bash
sudo docker logs codesys-4-nginx
```

Follow the logs:

```bash
sudo docker logs -f codesys-4-nginx
```

---

# 18. Check Port Usage

To check which ports are being used on the Linux host:

```bash
sudo ss -lntp
```

To check port 80:

```bash
sudo ss -lntp | grep ':80 '
```

To check port 443:

```bash
sudo ss -lntp | grep ':443 '
```

The CODESYS startup script performs this detection automatically.

---

# 19. Docker Images

The deployment uses published Docker images.

CODESYS 4:

```text
jugaadtech/c
