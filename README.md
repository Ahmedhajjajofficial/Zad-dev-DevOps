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


## Local Deployment (Antigravity Container)
To publish and run the Antigravity Docker image on a local server:

```bash
./deploy_antigravity_local.sh
```

Optional environment overrides:

```bash
IMAGE_NAME=zed-antigravity \
CONTAINER_NAME=antigravity-local \
HOST_PORT=6901 \
CONTAINER_PORT=6901 \
./deploy_antigravity_local.sh
```

This script will:
1. Build the image from `Dockerfile.sovereign`.
2. Remove any existing container with the same name.
3. Run the container in detached mode with `--restart unless-stopped`.
4. Print running status and exposed port mapping.
