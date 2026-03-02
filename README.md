# Zed & Antigravity - Mr. Hajjaj's Sovereign IDE

This project implements the strategy for running Zed and Antigravity in a high-performance ARM64 cloud environment.

## Architecture
- **Dockerfile.sovereign**: Base container using Kasm for high-performance streaming.
- **start_zed.sh**: Script to launch Zed with low latency.
- **configure_antigravity.sh**: Injects Antigravity identity into code-server.
- **health_check.sh**: Self-healing agent for service reliability.
- **cloudflared_setup.sh**: Zero-Trust tunnel for secure access.

## Implementation Details
The project follows the "Mr. Robot" (Mr. Hajjaj Edition) standards for rapid production and infrastructure dominance.

## Run Zed image on a local server
Use the helper script to build and run the local container:

```bash
./run_local_zad.sh
```

Optional environment variables:
- `IMAGE_NAME` (default: `zad-local`)
- `CONTAINER_NAME` (default: `zad-local-server`)
- `PORT` (default: `6901`)
- `DOCKERFILE` (default: `Dockerfile.sovereign`)

If Docker is not installed, install it first (Ubuntu example):

```bash
sudo apt-get update && sudo apt-get install -y docker.io
```
