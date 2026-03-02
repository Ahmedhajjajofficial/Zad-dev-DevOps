#!/bin/bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-zad-local}"
CONTAINER_NAME="${CONTAINER_NAME:-zad-local-server}"
PORT="${PORT:-6901}"
DOCKERFILE="${DOCKERFILE:-Dockerfile.sovereign}"
REPLICAS="${REPLICAS:-1}"
RESILIENCE_LABEL_KEY="${RESILIENCE_LABEL_KEY:-zad.resilience}"
RESILIENCE_LABEL_VALUE="${RESILIENCE_LABEL_VALUE:-true}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is not installed. Install Docker then re-run this script." >&2
  echo "Suggested Ubuntu command: sudo apt-get update && sudo apt-get install -y docker.io" >&2
  exit 1
fi

if [ ! -f "$DOCKERFILE" ]; then
  echo "Error: $DOCKERFILE not found in $(pwd)" >&2
  exit 1
fi

if ! [[ "$REPLICAS" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: REPLICAS must be a positive integer." >&2
  exit 1
fi

echo "[1/4] Building image '$IMAGE_NAME' from $DOCKERFILE"
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .

echo "[2/4] Removing previous containers with prefix '$CONTAINER_NAME'"
docker ps -a --format '{{.Names}}' | rg -x "${CONTAINER_NAME}(-replica-[0-9]+)?" | while read -r old; do
  docker rm -f "$old" >/dev/null || true
done

echo "[3/4] Starting $REPLICAS container(s) with self-healing labels and health checks"
for ((i = 0; i < REPLICAS; i++)); do
  name="$CONTAINER_NAME"
  host_port="$PORT"
  if [ "$i" -gt 0 ]; then
    name="${CONTAINER_NAME}-replica-${i}"
    host_port="$((PORT + i))"
  fi

  docker run -d \
    --name "$name" \
    --label "$RESILIENCE_LABEL_KEY=$RESILIENCE_LABEL_VALUE" \
    --restart unless-stopped \
    --health-cmd='pgrep -f zed >/dev/null && pgrep -f code-server >/dev/null' \
    --health-interval=30s \
    --health-retries=3 \
    --health-timeout=5s \
    -p "$host_port:6901" \
    "$IMAGE_NAME" >/dev/null

  echo "  - $name => http://localhost:$host_port"
done

echo "[4/4] Done"
echo "Use auto-healing + scaling monitor: ./container_resilience.sh monitor"
echo "Temporary migration example: ./container_resilience.sh migrate $CONTAINER_NAME"
