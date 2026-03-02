#!/bin/bash
set -euo pipefail

LABEL_KEY="${LABEL_KEY:-zad.resilience}"
LABEL_VALUE="${LABEL_VALUE:-true}"
MANAGE_ALL_CONTAINERS="${MANAGE_ALL_CONTAINERS:-false}"
CPU_THRESHOLD="${CPU_THRESHOLD:-80}"
MAX_REPLICAS="${MAX_REPLICAS:-3}"
CHECK_INTERVAL="${CHECK_INTERVAL:-30}"

usage() {
  cat <<USAGE
Usage: $0 <command>

Commands:
  monitor                 Auto-heal unhealthy/exited containers + simple load autoscaling.
  migrate <container>     Launch temporary replacement during maintenance/outage.
  list                    List managed containers.

Environment:
  LABEL_KEY               Label key used to mark managed containers (default: zad.resilience)
  LABEL_VALUE             Label value used to mark managed containers (default: true)
  MANAGE_ALL_CONTAINERS   true/false. If true, ignore labels and manage all containers.
USAGE
}

require_docker() {
  command -v docker >/dev/null 2>&1 || {
    echo "docker is required." >&2
    exit 1
  }
}

label_filter() {
  printf "label=%s=%s" "$LABEL_KEY" "$LABEL_VALUE"
}

managed_containers() {
  if [ "$MANAGE_ALL_CONTAINERS" = "true" ]; then
    docker ps -a --format '{{.Names}}'
  else
    docker ps -a --filter "$(label_filter)" --format '{{.Names}}'
  fi
}

container_cpu() {
  local name="$1"
  local cpu
  cpu="$(docker stats --no-stream --format '{{.CPUPerc}}' "$name" | tr -d '%')"
  printf '%.*f\n' 0 "${cpu:-0}"
}

heal_container() {
  local name="$1"
  local status health
  status="$(docker inspect -f '{{.State.Status}}' "$name")"
  health="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$name")"

  if [ "$status" = "exited" ] || [ "$health" = "unhealthy" ]; then
    echo "[heal] Restarting $name (status=$status, health=$health)"
    docker restart "$name" >/dev/null
  fi
}

scale_if_needed() {
  local name="$1"
  local cpu count image base

  cpu="$(container_cpu "$name")"
  if [ "$cpu" -lt "$CPU_THRESHOLD" ]; then
    return
  fi

  base="${name%%-replica-*}"
  count="$(docker ps --filter "name=^${base}(-replica-[0-9]+)?$" --format '{{.Names}}' | wc -l | tr -d ' ')"
  if [ "$count" -ge "$MAX_REPLICAS" ]; then
    echo "[scale] $base is above threshold ($cpu%) but already at max replicas ($MAX_REPLICAS)."
    return
  fi

  image="$(docker inspect -f '{{.Config.Image}}' "$name")"
  local replica_name="${base}-replica-${count}"

  echo "[scale] High CPU detected on $name ($cpu%). Starting $replica_name"
  docker run -d \
    --name "$replica_name" \
    --label "$LABEL_SELECTOR" \
    "$image" >/dev/null
}

migrate_container() {
  local name="$1"
  local image temp_name container_port host_port candidate_port

  image="$(docker inspect -f '{{.Config.Image}}' "$name")"
  container_port="$(docker inspect -f '{{range $p, $_ := .Config.ExposedPorts}}{{printf "%s" $p}}{{end}}' "$name" | head -n1)"
  host_port="$(docker inspect -f '{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}{{(index $conf 0).HostPort}}{{end}}{{end}}' "$name" | head -n1)"

  temp_name="${name}-temp-$(date +%s)"
  candidate_port=""

  if [ -n "$host_port" ]; then
    candidate_port="$((host_port + 100))"
    echo "[migrate] Starting temporary container $temp_name on host port $candidate_port"
    docker run -d --name "$temp_name" --label "$LABEL_SELECTOR" -p "$candidate_port:${container_port%/*}" "$image" >/dev/null
    echo "[migrate] Redirect traffic from :$host_port to :$candidate_port during maintenance."
  else
    echo "[migrate] Starting temporary container $temp_name without published ports"
    docker run -d --name "$temp_name" --label "$LABEL_SELECTOR" "$image" >/dev/null
  fi

  docker update --restart unless-stopped "$temp_name" >/dev/null
  echo "[migrate] Temporary migration ready: $temp_name"
}

monitor_loop() {
  echo "[monitor] Watching containers with label: $LABEL_SELECTOR"
  while true; do
    while IFS= read -r c; do
      [ -z "$c" ] && continue
      heal_container "$c"
      scale_if_needed "$c"
    done < <(managed_containers)

    sleep "$CHECK_INTERVAL"
  done
}

main() {
  require_docker

  case "${1:-}" in
    monitor)
      monitor_loop
      ;;
    migrate)
      [ -n "${2:-}" ] || { echo "container name is required"; usage; exit 1; }
      migrate_container "$2"
      ;;
    list)
      managed_containers
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
