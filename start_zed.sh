#!/bin/bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:1}"

# Pick a sensible default library path based on CPU architecture.
arch="$(uname -m)"
case "$arch" in
    x86_64)
        lib_dir="/usr/lib/x86_64-linux-gnu"
        ;;
    aarch64|arm64)
        lib_dir="/usr/lib/aarch64-linux-gnu"
        ;;
    *)
        lib_dir=""
        ;;
esac

if [ -n "$lib_dir" ] && [ -d "$lib_dir" ]; then
    export LD_LIBRARY_PATH="$lib_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

zed_bin="/home/kasm-user/.local/bin/zed"
if [ ! -x "$zed_bin" ]; then
    echo "Error: Zed binary not found or not executable at $zed_bin" >&2
    exit 1
fi

exec "$zed_bin" --foreground --wait
