#!/bin/bash
set -euo pipefail

ZED_BIN="${ZED_BIN:-/home/kasm-user/.local/bin/zed}"
CODE_SERVER_BIN="${CODE_SERVER_BIN:-code-server}"
CHECK_INTERVAL="${CHECK_INTERVAL:-30}"
MAX_RETRIES="${MAX_RETRIES:-3}"

start_zed() {
  if [ -x "$ZED_BIN" ]; then
    nohup "$ZED_BIN" --foreground --wait >/tmp/zed.log 2>&1 &
  else
    echo "[health-check] Zed binary missing at $ZED_BIN"
  fi
}

start_code_server() {
  nohup "$CODE_SERVER_BIN" --bind-addr 0.0.0.0:8080 >/tmp/code-server.log 2>&1 &
}

restart_service() {
  local service="$1"
  local retries=0

  while [ "$retries" -lt "$MAX_RETRIES" ]; do
    case "$service" in
      zed)
        pkill -f "$ZED_BIN" >/dev/null 2>&1 || true
        start_zed
        sleep 2
        pgrep -f "$ZED_BIN" >/dev/null 2>&1 && return 0
        ;;
      code-server)
        pkill -f "$CODE_SERVER_BIN" >/dev/null 2>&1 || true
        start_code_server
        sleep 2
        pgrep -f "$CODE_SERVER_BIN" >/dev/null 2>&1 && return 0
        ;;
    esac
    retries=$((retries + 1))
  done

  return 1
}

while true; do
  if ! pgrep -f "$ZED_BIN" >/dev/null 2>&1; then
    echo "[health-check] Zed is down. Restarting..."
    restart_service zed || echo "[health-check] Failed to recover Zed after $MAX_RETRIES attempts"
  fi

  if ! pgrep -f "$CODE_SERVER_BIN" >/dev/null 2>&1; then
    echo "[health-check] code-server is down. Restarting..."
    restart_service code-server || echo "[health-check] Failed to recover code-server after $MAX_RETRIES attempts"
  fi

  sleep "$CHECK_INTERVAL"
done
