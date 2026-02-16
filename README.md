# Project 3: Kubernetes Deployment

Deploy the Flask app from **dockerized-app-cicd-aws-1125** (Project 2) on Kubernetes (local k3d cluster). See `ARCHITECTURE.md` for request flow and components.

## Registry

**Docker Hub.** Image repository: `matalve/flask-app`. Same registry as Project 2’s CD; no private registry for this project.

## Image naming and tagging convention

| Context | Image reference | Tag(s) | Use |
|--------|-----------------|--------|-----|
| **Local (Docker Compose)** | `flask-app` | `local` | Built and run on your machine only; never pushed. |
| **Registry / CD / Kubernetes** | `matalve/flask-app` | `latest`, `$SHA` | Pushed by CD (Project 2) to Docker Hub. `latest` = current deploy; SHA = rollback. |

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
- Docker (for k3d and for building/pulling the app image).

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
