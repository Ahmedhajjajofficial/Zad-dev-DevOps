#!/bin/bash
set -euo pipefail

TUNNEL_NAME="${TUNNEL_NAME:-zad-cloud}"
TUNNEL_HOSTNAME="${TUNNEL_HOSTNAME:-code.example.com}"
PACKAGE_FILE="cloudflared.deb"

curl -fL --output "$PACKAGE_FILE" \
  https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb

if command -v sudo >/dev/null 2>&1; then
  sudo dpkg -i "$PACKAGE_FILE"
else
  dpkg -i "$PACKAGE_FILE"
fi

echo "cloudflared installed."
echo "Next steps (interactive):"
echo "  cloudflared tunnel login"
echo "  cloudflared tunnel create $TUNNEL_NAME"
echo "  cloudflared tunnel route dns $TUNNEL_NAME $TUNNEL_HOSTNAME"
