#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-zed-antigravity}"
CONTAINER_NAME="${CONTAINER_NAME:-antigravity-local}"
DOCKERFILE="${DOCKERFILE:-Dockerfile.sovereign}"
HOST_PORT="${HOST_PORT:-6901}"
CONTAINER_PORT="${CONTAINER_PORT:-6901}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' is not installed." >&2
    exit 1
  fi
}

require_cmd docker

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Error: Dockerfile '$DOCKERFILE' not found." >&2
  exit 1
fi

echo "[1/4] Building image '$IMAGE_NAME' from '$DOCKERFILE'..."
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .

if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  echo "[2/4] Removing existing container '$CONTAINER_NAME'..."
  docker rm -f "$CONTAINER_NAME" >/dev/null
else
  echo "[2/4] No existing container named '$CONTAINER_NAME'."
fi

echo "[3/4] Starting container '$CONTAINER_NAME' on port $HOST_PORT:$CONTAINER_PORT..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "$HOST_PORT:$CONTAINER_PORT" \
  --restart unless-stopped \
  "$IMAGE_NAME"

echo "[4/4] Container status:"
docker ps --filter "name=$CONTAINER_NAME" --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

echo
echo "Antigravity is running locally. Access URL: http://localhost:$HOST_PORT"
