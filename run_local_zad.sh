#!/bin/bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-zad-local}"
CONTAINER_NAME="${CONTAINER_NAME:-zad-local-server}"
PORT="${PORT:-6901}"
DOCKERFILE="${DOCKERFILE:-Dockerfile.sovereign}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is not installed. Install Docker then re-run this script." >&2
  echo "Suggested Ubuntu command: sudo apt-get update && sudo apt-get install -y docker.io" >&2
  exit 1
fi

if [ ! -f "$DOCKERFILE" ]; then
  echo "Error: $DOCKERFILE not found in $(pwd)" >&2
  exit 1
fi

echo "[1/3] Building image '$IMAGE_NAME' from $DOCKERFILE"
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .

if docker ps -a --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
  echo "[2/3] Removing previous container '$CONTAINER_NAME'"
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

echo "[3/3] Starting local server container '$CONTAINER_NAME' on port $PORT"
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "$PORT:6901" \
  "$IMAGE_NAME" >/dev/null

echo "Done. Zed image is running locally on: http://localhost:$PORT"
echo "Logs: docker logs -f $CONTAINER_NAME"
echo "Stop: docker rm -f $CONTAINER_NAME"
