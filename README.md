# Project 3: Kubernetes Deployment

Deploy the Flask app from **dockerized-app-cicd-aws-1125** (Project 2) on Kubernetes (local k3d cluster). See `ARCHITECTURE.md` for request flow and components.

## Registry

**Docker Hub.** Image: `matalve/flask-app`. Same as Project 2.

## Image naming and tagging convention

| Context | Image reference | Tag(s) | Use |
|--------|-----------------|--------|-----|
| **Local (Docker Compose)** | `flask-app` | `local` | Local only; never pushed. |
| **Registry / CD / Kubernetes** | `matalve/flask-app` | `latest`, `$SHA` | CD pushes to Docker Hub. `latest` = current; SHA = rollback. |

- **Local (Project 2):** `flask-app:local` in `docker-compose.yml`.
- **CI (Project 2):** Builds with a local tag only to verify the Dockerfile; image is not pushed.
- **CD (Project 2):** Builds and pushes `matalve/flask-app:latest` and `matalve/flask-app:$SHA`.
- **Kubernetes (this project):** Use the same registry image in Deployment manifests, e.g. `matalve/flask-app:latest` (or a specific SHA for pinned deploys).

## Git commit → new image flow

1. Push to `main` in **Project 2** (`dockerized-app-cicd-aws-1125`).
2. CD workflow runs: builds image, pushes to Docker Hub as `matalve/flask-app:latest` and `matalve/flask-app:$SHA`.
3. Image is available for K8s. To pick it up: `kubectl rollout restart deployment/flask-app-deployment` (uses `latest`), or update the image tag in the manifest and `kubectl apply`.

## Prerequisites

- k3d and kubectl
- Docker

## Deploy

1. **Start the cluster**
   ```bash
   k3d cluster create dev-cluster -p 8080:80
   ```
   Or: `k3d cluster start dev-cluster` if already created.

2. **Apply manifests**
   ```bash
   kubectl apply -f k8s/flask-app/
   kubectl apply -f k8s/ingress.yaml
   ```

3. **Wait for pods** (`kubectl get pods -w`), then access **http://localhost:8080**

See **[DEPLOYMENT.md](DEPLOYMENT.md)** for full steps (picking up new images, teardown, load test).

## Logging and debugging

The app logs to stdout (Gunicorn access and error logs via `--access-logfile - --error-logfile -`). Access logs show HTTP requests; error logs show tracebacks when unhandled exceptions or worker issues occur. Both appear in the same stream. Use:

- **`kubectl logs -l app=flask-app --tail=50`** — recent logs from all Flask pods (access + error)
- **`kubectl logs <pod-name> -f`** — stream logs from a specific pod
- **`kubectl describe pod <pod-name>`** — events, restarts, probes, resource limits
- **`kubectl describe deployment flask-app-deployment`** — rollout status, conditions

## Design decisions and trade-offs

- **k3d** — Lightweight (k3s in Docker), Traefik included. Chosen for simplicity.
- **ClusterIP Service** — Internal only; Ingress handles external traffic.
- **ConfigMap + Secret** — Non-sensitive (APP_VERSION, ENVIRONMENT) in ConfigMap; sensitive (API_KEY) in Secret.
- **HPA on CPU** — Target 60%, min 2 / max 5 replicas.
- **Manual `kubectl apply`** — No GitOps; CD runners cannot reach local k3d. See [DEPLOYMENT.md](DEPLOYMENT.md).
- **No database** — Stateless. See [ARCHITECTURE.md](ARCHITECTURE.md).
