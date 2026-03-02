# Zed & Antigravity - Mr. Hajjaj's Sovereign IDE

This project implements the strategy for running Zed and Antigravity in a high-performance ARM64 cloud environment.

## Architecture
- **Dockerfile.sovereign**: Base container using Kasm for high-performance streaming.
- **start_zed.sh**: Script to launch Zed with low latency.
- **configure_antigravity.sh**: Injects Antigravity identity into code-server.
- **health_check.sh**: Self-healing agent for service reliability.
- **cloudflared_setup.sh**: Zero-Trust tunnel for secure access.
- **run_zed_local.sh**: Build and run the Docker image locally on `localhost`.

## Run Zed image locally
1. Ensure Docker is installed.
2. Run:
   ```bash
   ./run_zed_local.sh
   ```
3. Open:
   ```
   http://localhost:6901
   ```

You can customize with environment variables:

```bash
IMAGE_NAME=my-zed CONTAINER_NAME=my-zed-local PORT=8080 ./run_zed_local.sh
```

## Implementation Details
The project follows the "Mr. Robot" (Mr. Hajjaj Edition) standards for rapid production and infrastructure dominance.
