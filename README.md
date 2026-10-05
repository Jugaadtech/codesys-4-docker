# CODESYS 4 Docker + HTTPS Reverse Proxy

Production-oriented deployment layout for CODESYS 4 on Linux/Raspberry Pi.

## Architecture

Browser
  |
  | HTTPS :443
  v
NGINX
  |
  | HTTP :8080
  v
CODESYS 4 c4-server

CODESYS 4 is not exposed directly to the host. NGINX terminates TLS and
reverse-proxies Web UI/WebSocket traffic to the CODESYS container.

## Images

CODESYS 4:

    jugaadtech/codesys-4:1.0.0.0-arm64
    jugaadtech/codesys-4:1.0.0.0-amd64

NGINX:

    jugaadtech/codesys-4-nginx:1.0.0

A multi-architecture CODESYS tag can later be published as:

    jugaadtech/codesys-4:1.0.0.0

## First test

Copy `.env.example` to `.env` and adjust `CODESYS_IP` to the host IP if
browser access will be performed using the IP address.

Then:

    docker compose up -d --build

Check:

    docker compose ps
    docker compose logs --tail=100 codesys-4
    docker compose logs --tail=100 codesys-4-nginx

Open:

    https://<HOST-IP>/

HTTP automatically redirects to HTTPS.

Because the default certificate is self-signed, the browser will display a
certificate warning until the certificate is trusted.

## CODESYS login

The CODESYS container runs c4-server as a non-root Linux user.

The user must belong to the `codesys-4` group. The default container setup
creates `admin` with the configured UID/GID and adds it to `codesys-4`.

Set the password after the first deployment:

    docker exec -it codesys-4 passwd admin

Verify:

    docker exec codesys-4 id admin

The password is stored inside the container filesystem. For a production
deployment, use a persistent/secure credential initialization mechanism
rather than relying on a default password.

## Certificate

The NGINX entrypoint creates the certificate automatically on first start.

Certificate:

    /etc/ssl/certs/codesys-4-certificate.crt

Private key:

    /etc/ssl/private/codesys-4.key

Both are stored in named Docker volumes:

    codesys-4-certs
    codesys-4-private

Therefore a normal container restart does not generate a new certificate.

The generated certificate is self-signed and intended for development/testing.
For production, replace it with a CA-issued certificate while keeping the
same NGINX certificate/key paths.

## Build NGINX image

    docker build \
      -f Dockerfile.nginx \
      -t jugaadtech/codesys-4-nginx:1.0.0 .

Push:

    docker push jugaadtech/codesys-4-nginx:1.0.0

The official nginx:1.29-alpine base supports both amd64 and arm64, so the
NGINX image can also be published as a multi-architecture image.

## Build CODESYS 4 architecture-specific images

ARM64 on Raspberry Pi:

    docker buildx build \
      --platform linux/arm64 \
      -t jugaadtech/codesys-4:1.0.0.0-arm64 \
      --push .

AMD64 on Debian/VM:

    docker buildx build \
      --platform linux/amd64 \
      -t jugaadtech/codesys-4:1.0.0.0-amd64 \
      --push .

The proprietary CODESYS Debian package must be supplied in `output/`.

## Publish CODESYS multi-architecture manifest

After both architecture images are available:

    docker manifest create \
      jugaadtech/codesys-4:1.0.0.0 \
      jugaadtech/codesys-4:1.0.0.0-arm64 \
      jugaadtech/codesys-4:1.0.0.0-amd64

    docker manifest push jugaadtech/codesys-4:1.0.0.0

Verify:

    docker buildx imagetools inspect jugaadtech/codesys-4:1.0.0.0

## Publish NGINX multi-architecture image

Recommended:

    docker buildx build \
      --platform linux/amd64,linux/arm64 \
      -f Dockerfile.nginx \
      -t jugaadtech/codesys-4-nginx:1.0.0 \
      --push .

Verify:

    docker buildx imagetools inspect jugaadtech/codesys-4-nginx:1.0.0

## Important

Do not configure TLS inside c4-server. CODESYS 4 c4-server exposes HTTP and
NGINX provides the HTTPS endpoint.

Do not use `127.0.0.1:8080` in the NGINX container. The correct upstream is:

    proxy_pass http://codesys-4:8080;

because `codesys-4` is the Docker Compose service name.
