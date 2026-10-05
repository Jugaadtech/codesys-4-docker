#!/bin/bash
set -Eeuo pipefail

COMPOSE_FILE="docker-compose.yml"
RUNTIME_ENV=".codesys-runtime.env"

HTTP_DEFAULT=80
HTTPS_DEFAULT=443

HTTP_FALLBACK_START=8081
HTTPS_FALLBACK_START=8443

if sudo docker compose version >/dev/null 2>&1; then
    COMPOSE_COMMAND="docker compose"
elif sudo docker-compose version >/dev/null 2>&1; then
    COMPOSE_COMMAND="docker-compose"
else
    echo
    echo "ERROR: Docker Compose was not found."
    echo
    exit 1
fi

echo
echo "============================================================"
echo " CODESYS 4 Docker"
echo " Automatic Host Port Detection"
echo "============================================================"
echo

port_in_use() {
    local port="$1"

    if sudo ss -lntH 2>/dev/null | awk -v port=":${port}" '
        $4 ~ port "$" {
            found=1
            exit
        }
        END {
            exit(found ? 0 : 1)
        }
    '; then
        return 0
    fi

    return 1
}

find_free_port() {
    local start_port="$1"
    local port="${start_port}"

    while port_in_use "${port}"; do
        port=$((port + 1))

        if [ "${port}" -gt 65535 ]; then
            echo "ERROR: No available TCP port found." >&2
            exit 1
        fi
    done

    echo "${port}"
}

if port_in_use "${HTTP_DEFAULT}"; then
    HTTP_PORT="$(find_free_port "${HTTP_FALLBACK_START}")"

    echo "Port 80 is already in use."
    echo "Selected HTTP port: ${HTTP_PORT}"
else
    HTTP_PORT="${HTTP_DEFAULT}"

    echo "HTTP port 80 is available."
fi

if port_in_use "${HTTPS_DEFAULT}"; then
    HTTPS_PORT="$(find_free_port "${HTTPS_FALLBACK_START}")"

    echo "Port 443 is already in use."
    echo "Selected HTTPS port: ${HTTPS_PORT}"
else
    HTTPS_PORT="${HTTPS_DEFAULT}"

    echo "HTTPS port 443 is available."
fi

if [ "${HTTP_PORT}" = "${HTTPS_PORT}" ]; then
    HTTPS_PORT="$(find_free_port "$((HTTPS_PORT + 1))")"
fi

cat > "${RUNTIME_ENV}" <<EOF2
CODESYS_HTTP_PORT=${HTTP_PORT}
CODESYS_HTTPS_PORT=${HTTPS_PORT}
EOF2

echo
echo "Selected ports:"
echo "  HTTP  : ${HTTP_PORT}"
echo "  HTTPS : ${HTTPS_PORT}"
echo

echo "Pulling Docker images..."
echo

sudo ${COMPOSE_COMMAND} --env-file "${RUNTIME_ENV}" pull

echo
echo "Starting CODESYS 4..."
echo

sudo ${COMPOSE_COMMAND} --env-file "${RUNTIME_ENV}" up -d

HOST_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"

if [ -z "${HOST_IP}" ]; then
    HOST_IP="<device-ip>"
fi

echo
echo "============================================================"
echo " CODESYS 4 Docker Started"
echo "============================================================"
echo
echo "HTTP  : ${HTTP_PORT}"
echo "HTTPS : ${HTTPS_PORT}"
echo
echo "CODESYS 4 URL:"
echo
echo "  https://${HOST_IP}:${HTTPS_PORT}/"
echo
echo "Container status:"
echo

sudo ${COMPOSE_COMMAND} --env-file "${RUNTIME_ENV}" ps

echo
echo "============================================================"
echo

