#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-zed-antigravity}"
CONTAINER_NAME="${CONTAINER_NAME:-zed-local}"
PORT="${PORT:-6901}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed."
  echo "Install Docker, then run this script again."
  exit 1
fi

echo "Building image: ${IMAGE_NAME}"
docker build -t "${IMAGE_NAME}" -f Dockerfile.sovereign .

if docker ps -a --format '{{.Names}}' | grep -Fxq "${CONTAINER_NAME}"; then
  echo "Removing existing container: ${CONTAINER_NAME}"
  docker rm -f "${CONTAINER_NAME}" >/dev/null
fi

echo "Starting container ${CONTAINER_NAME} on http://localhost:${PORT}"
docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${PORT}:6901" \
  "${IMAGE_NAME}"

echo "Container started."
echo "Open: http://localhost:${PORT}"
