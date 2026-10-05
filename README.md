# CODESYS 4 Docker + HTTPS Reverse Proxy

Run **CODESYS 4 on Linux and Raspberry Pi using Docker**.

This package provides a ready-to-run CODESYS 4 environment with an HTTPS web interface. CODESYS 4 runs inside Docker, while NGINX provides HTTPS access.

No CODESYS 4 installation is required on the host operating system.

---

## What You Get

The package provides:

- CODESYS 4 runtime/server
- Docker-based deployment
- Linux support
- Raspberry Pi ARM64 support
- AMD64 Linux support
- HTTPS web access
- Automatic self-signed certificate generation
- Persistent CODESYS configuration
- Persistent TLS certificates
- Automatic Docker image download from Docker Hub
- No local Docker image build required

The customer does **not** need to build the Docker images or install CODESYS 4 directly on Linux.

---

# Requirements

Before starting, make sure your system has:

## Hardware

One of the following:

- Raspberry Pi with a supported 64-bit Linux operating system
- AMD64/x86-64 Linux computer or server

## Software

Install:

- Docker
- Docker Compose

Verify Docker:

```bash
sudo docker --version
```

Verify Docker Compose V2:

```bash
sudo docker compose version
```

If the `docker compose` command is not available, check for the older Docker Compose command:

```bash
sudo docker-compose version
```

If either Compose command returns a version number, you can use that command throughout this guide.

> **Note:** Some Linux systems use `docker compose`, while older installations use `docker-compose`. Both are supported by this deployment package.

---

# Installation

## 1. Download the Deployment Package

Clone this repository:

```bash
sudo git clone https://github.com/Jugaadtech/codesys-4-docker.git
```

Enter the directory:

```bash
cd codesys-4-docker
```

Alternatively, download the ZIP package from the GitHub Releases page and extract it.

> **Note:** If Git is not installed, install it using your Linux distribution's package manager.

---

# 2. Download the CODESYS 4 Docker Images

### Using Docker Compose V2

If your system supports:

```bash
sudo docker compose version
```

run:

```bash
sudo docker compose pull
```

### Using Docker Compose V1 / legacy command

If your system uses:

```bash
sudo docker-compose version
```

run:

```bash
sudo docker-compose pull
```

This downloads the required CODESYS 4 and HTTPS gateway images from Docker Hub.

---

# 3. Start CODESYS 4

### Docker Compose V2

```bash
sudo docker compose up -d
```

### Legacy Docker Compose

```bash
sudo docker-compose up -d
```

That's it.

You do **not** need to:

- Build a Docker image
- Install a CODESYS `.deb` package
- Install CODESYS 4 directly on Linux
- Configure NGINX manually
- Generate an SSL certificate manually

The required Docker images and HTTPS configuration are provided by this deployment package.

---

# Check the Installation

Check the running containers.

### Docker Compose V2

```bash
sudo docker compose ps
```

### Legacy Docker Compose

```bash
sudo docker-compose ps
```

You should see two services:

```text
codesys-4
codesys-4-nginx
```

Both services should be running.

You can also check the logs.

### Docker Compose V2

```bash
sudo docker compose logs -f
```

### Legacy Docker Compose

```bash
sudo docker-compose logs -f
```

Press:

```text
Ctrl+C
```

to leave the log view.

---

# Open CODESYS 4

Find the IP address of the computer running Docker:

```bash
hostname -I
```

For example:

```text
192.168.1.100
```

Open a web browser on a computer connected to the same network and go to:

```text
https://192.168.1.100/
```

Replace the IP address with the IP address of your Linux/Raspberry Pi system.

---

# HTTPS Certificate

The first time the system starts, it automatically generates a self-signed HTTPS certificate.

Your browser may therefore display a warning such as:

> Your connection is not private

This is expected when using the automatically generated self-signed certificate.

For a test or local installation, you can proceed to the CODESYS 4 web interface.

The certificate is stored in Docker volumes and is reused when the containers are restarted.

For production deployments, a trusted CA-issued certificate can be used instead of the automatically generated self-signed certificate.

---

# CODESYS 4 Access

CODESYS 4 runs internally in Docker and is accessed through the HTTPS gateway.

The architecture is:

```text
Web Browser
     |
     | HTTPS
     | Port 443
     v
+------------------+
|      NGINX       |
|  HTTPS Gateway   |
+------------------+
         |
         | Internal Docker Network
         | HTTP :8080
         v
+------------------+
|    CODESYS 4     |
|     Server       |
+------------------+
```

CODESYS 4 is not directly exposed on the host network.

---

# Starting and Stopping CODESYS 4

## Stop

### Docker Compose V2

```bash
sudo docker compose down
```

### Legacy Docker Compose

```bash
sudo docker-compose down
```

Your persistent configuration and certificates are retained.

---

## Start Again

### Docker Compose V2

```bash
sudo docker compose up -d
```

### Legacy Docker Compose

```bash
sudo docker-compose up -d
```

---

# Restart

### Docker Compose V2

```bash
sudo docker compose restart
```

### Legacy Docker Compose

```bash
sudo docker-compose restart
```

---

# Updating

When a new version is released, download the updated deployment package.

Then download the latest Docker images.

### Docker Compose V2

```bash
sudo docker compose pull
sudo docker compose up -d
```

### Legacy Docker Compose

```bash
sudo docker-compose pull
sudo docker-compose up -d
```

Docker will download the newer images from Docker Hub.

---

# Viewing Logs

## CODESYS 4 Logs

### Docker Compose V2

```bash
sudo docker compose logs -f codesys-4
```

### Legacy Docker Compose

```bash
sudo docker-compose logs -f codesys-4
```

---

## NGINX / HTTPS Logs

### Docker Compose V2

```bash
sudo docker compose logs -f codesys-4-nginx
```

### Legacy Docker Compose

```bash
sudo docker-compose logs -f codesys-4-nginx
```

---

## All Logs

### Docker Compose V2

```bash
sudo docker compose logs -f
```

### Legacy Docker Compose

```bash
sudo docker-compose logs -f
```

Press `Ctrl+C` to stop viewing the logs.

---

# Network Ports

The standard installation uses:

| Port | Protocol | Purpose |
|---:|---|---|
| 80 | HTTP | Redirects to HTTPS |
| 443 | HTTPS | CODESYS 4 web access |
| 8080 | Internal | CODESYS 4 service |

Port `8080` is **not exposed directly to the host**.

Users should access CODESYS 4 through:

```text
https://<device-ip>/
```

---

# Configuration

The standard installation requires no configuration.

Simply run:

### Docker Compose V2

```bash
sudo docker compose pull
sudo docker compose up -d
```

### Legacy Docker Compose

```bash
sudo docker-compose pull
sudo docker-compose up -d
```

An optional `.env` file can be used for advanced configuration.

For example:

```text
CODESYS_HTTP_PORT=80
CODESYS_HTTPS_PORT=443
CODESYS_HOSTNAME=codesys-4
CODESYS_IP=
CERT_DAYS=365
```

Most users do not need to modify these settings.

---

# Raspberry Pi

For Raspberry Pi systems, make sure you are running a 64-bit operating system.

Check the architecture:

```bash
uname -m
```

A typical ARM64 system reports:

```text
aarch64
```

The CODESYS 4 Docker image is provided for ARM64.

---

# AMD64 Linux

For an AMD64/x86-64 Linux system:

```bash
uname -m
```

typically returns:

```text
x86_64
```

The corresponding Docker image is provided for AMD64.

When a multi-architecture image is available, Docker automatically selects the appropriate image for the host architecture.

---

# Persistent Data

The deployment uses Docker volumes for persistent TLS data.

The CODESYS `/home` directory is also mapped to the host so that CODESYS configuration and project-related data can persist across container recreation.

Removing and recreating the containers does not automatically remove these persistent resources.

---

# Troubleshooting

## CODESYS 4 Does Not Start

Check the container status.

### Docker Compose V2

```bash
sudo docker compose ps
```

### Legacy Docker Compose

```bash
sudo docker-compose ps
```

Then check the CODESYS logs.

### Docker Compose V2

```bash
sudo docker compose logs codesys-4
```

### Legacy Docker Compose

```bash
sudo docker-compose logs codesys-4
```

---

## HTTPS Does Not Open

Check the NGINX service.

### Docker Compose V2

```bash
sudo docker compose logs codesys-4-nginx
```

### Legacy Docker Compose

```bash
sudo docker-compose logs codesys-4-nginx
```

Also verify that port 443 is available:

```bash
sudo ss -lntp | grep :443
```

---

## Port 80 or 443 Is Already in Use

Check which application is using the port:

```bash
sudo ss -lntp | grep :80
```

or:

```bash
sudo ss -lntp | grep :443
```

You can use different host ports through the optional `.env` configuration.

---

## Check Container Status

### Docker Compose V2

```bash
sudo docker compose ps
```

### Legacy Docker Compose

```bash
sudo docker-compose ps
```

---

## Restart Everything

### Docker Compose V2

```bash
sudo docker compose down
sudo docker compose up -d
```

### Legacy Docker Compose

```bash
sudo docker-compose down
sudo docker-compose up -d
```

---

# Remove the Installation

To stop and remove the containers:

### Docker Compose V2

```bash
sudo docker compose down
```

### Legacy Docker Compose

```bash
sudo docker-compose down
```

Your persistent volumes remain intact.

## Remove Containers and Persistent Volumes

Only use this if you intentionally want to remove the stored configuration and certificates.

### Docker Compose V2

```bash
sudo docker compose down -v
```

### Legacy Docker Compose

```bash
sudo docker-compose down -v
```

> **Warning:** Removing volumes permanently removes the data stored in those volumes.

---

# Quick Reference

## Start

### Docker Compose V2

```bash
sudo docker compose up -d
```

### Legacy Docker Compose

```bash
sudo docker-compose up -d
```

---

## Stop

### Docker Compose V2

```bash
sudo docker compose down
```

### Legacy Docker Compose

```bash
sudo docker-compose down
```

---

## Restart

### Docker Compose V2

```bash
sudo docker compose restart
```

### Legacy Docker Compose

```bash
sudo docker-compose restart
```

---

## Update Images

### Docker Compose V2

```bash
sudo docker compose pull
sudo docker compose up -d
```

### Legacy Docker Compose

```bash
sudo docker-compose pull
sudo docker-compose up -d
```

---

## Check Status

### Docker Compose V2

```bash
sudo docker compose ps
```

### Legacy Docker Compose

```bash
sudo docker-compose ps
```

---

## View Logs

### Docker Compose V2

```bash
sudo docker compose logs -f
```

### Legacy Docker Compose

```bash
sudo docker-compose logs -f
```

---

## Open CODESYS 4

```text
https://<device-ip>/
```

---

# Support

For product support, please provide the following information.

### Container Status

```bash
sudo docker compose ps
```

If your system uses the legacy command:

```bash
sudo docker-compose ps
```

### Recent Logs

```bash
sudo docker compose logs --tail=200
```

or:

```bash
sudo docker-compose logs --tail=200
```

Also provide:

- Operating system
- Hardware platform
- Docker version
- Docker Compose version
- Description of the problem

---

# CODESYS 4 Docker

**CODESYS 4 on Linux — packaged for containerized deployment.**
