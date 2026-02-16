# Deployment Guide

Manual deployment flow for the Flask app on k3d. Uses `kubectl apply` (no CD workflow—GitHub Actions runners cannot reach local k3d).

## Prerequisites

- k3d and kubectl
- Docker (for k3d and for pulling the app image)

## Initial deployment

1. **Start the cluster**
   ```bash
   k3d cluster create dev-cluster -p 8080:80
   ```
   Or if already created: `k3d cluster start dev-cluster`

2. **Verify cluster**
   ```bash
   kubectl get nodes
   ```

3. **Apply manifests**
   ```bash
   kubectl apply -f k8s/flask-app/
   kubectl apply -f k8s/ingress.yaml
   ```

4. **Wait for pods**
   ```bash
   kubectl get pods -w
   ```
   Exit when pods are `Running` and `Ready`.

5. **Access the app**
   - **http://localhost:8080**
   - Routes: `/`, `/health`, `/api/info`

6. **Load test (optional)**
   ```bash
   ./scripts/load-test.sh http://localhost:8080 60
   ```
   Watch HPA: `kubectl get hpa -w`

## Picking up a new image

After pushing to Project 2 main (new image on Docker Hub):

```bash
kubectl rollout restart deployment/flask-app-deployment
```

Or: update the image tag in `k8s/flask-app/deployment.yaml` and run `kubectl apply -f k8s/flask-app/`.

## Teardown

**Remove app resources only (cluster stays):**
```bash
kubectl delete -f k8s/flask-app/ -f k8s/ingress.yaml
```

**Remove entire cluster:**
```bash
k3d cluster delete dev-cluster
```
