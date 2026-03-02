# Zed & Antigravity Cloud IDE

Repository for building and operating a cloud-hosted development workspace based on:

- **Kasm Ubuntu base image**
- **Zed editor**
- **code-server extensions/configuration for Antigravity workflows**
- **Optional Cloudflare Tunnel exposure**

## Repository structure

- `Dockerfile.sovereign`: builds the main runtime image.
- `start_zed.sh`: starts Zed with architecture-aware library path handling.
- `configure_antigravity.sh`: installs optional VSIX extensions and writes code-server settings.
- `health_check.sh`: lightweight process watchdog for Zed and code-server.
- `cloudflared_setup.sh`: helper for downloading/installing cloudflared and printing next steps.
- `run_local_zad.sh`: local Docker build/run helper.
- `kasm_app_config.json`: sample Kasm app definition.

## Quick start (local)

```bash
./run_local_zad.sh
```

Optional environment variables:

- `IMAGE_NAME` (default: `zad-local`)
- `CONTAINER_NAME` (default: `zad-local-server`)
- `PORT` (default: `6901`)
- `DOCKERFILE` (default: `Dockerfile.sovereign`)

## Cloudflare tunnel helper

The tunnel helper is intentionally non-interactive-safe and does **not** run login/create commands automatically.

```bash
TUNNEL_NAME=my-zad \
TUNNEL_HOSTNAME=code.example.com \
./cloudflared_setup.sh
```

Then run the printed `cloudflared tunnel ...` commands manually in an authenticated shell.

## GitHub readiness and safety notes

- Do not commit secrets, tunnel tokens, kubeconfigs, private keys, or generated artifacts.
- Use GitHub Actions secrets for credentials.
- Prefer environment variables for tenant/domain-specific values.
- `.gitignore` includes common local/runtime artifacts for this project.
