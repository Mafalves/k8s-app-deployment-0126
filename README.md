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

## Prerequisites

- k3d and kubectl
- Docker (for k3d and for building/pulling the app image).

## Deploy

1. **Start the cluster**
   - First time: `k3d cluster create dev-cluster -p 8080:80`
     - Maps host port 8080 → Traefik port 80 (avoids needing root for port 80 on Linux)
   - Already created: `k3d cluster start dev-cluster`
   - Verify: `kubectl get nodes`

2. **Apply manifests**
   ```bash
   kubectl apply -f k8s/flask-app/
   kubectl apply -f k8s/ingress.yaml
   ```

3. **Wait for pods**
   ```bash
   kubectl get pods -w
   ```
   Exit when pods are `Running` and `Ready`.

4. **Access the app**
   - **http://localhost:8080** (with `-p 8080:80` mapping)
   - Routes: `/`, `/health`, `/api/info`

5. **Load test (optional)**
   ```bash
   ./scripts/load-test.sh http://localhost:8080 60
   ```
   Watch HPA in another terminal: `kubectl get hpa -w`
