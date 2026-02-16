# Task 5: Kubernetes Object Design for the Flask App

Planning document for the Flask service deployment. Decisions are informed by the Project 2 app (`dockerized-app-cicd-aws-1125`).

**Task 5 complete.** Final decision: **use port 5000** for container, Service, and Compose/K8s alignment (Gunicorn listens on 5000; keep manifests and compose in sync).

---

## Design Decisions Summary

| Setting | Decision | Notes |
|--------|----------|-------|
| **Desired replicas** | 2 | Enough to show multi-pod behavior; HPA will adjust later (Task 11) |
| **Container port** | 5000 | Gunicorn listens on 5000 (Dockerfile: `${PORT:-5000}`; we use 5000 for K8s) |
| **Service port** | 5000 | Matches container; same port for both is simplest |
| **Target port** | 5000 | Service forwards to container port 5000 |

---

## Environment Variables

| Variable | Source | Required? | Purpose |
|----------|--------|-----------|---------|
| `APP_VERSION` | ConfigMap | Yes | Displayed in UI and `/api/info`; useful for debugging |
| `ENVIRONMENT` | ConfigMap | Yes | `development` / `production`; controls debug mode |
| `PORT` | Optional | No | Gunicorn binds to `${PORT:-5000}` in the Dockerfile; we use 5000 in K8s (omit or set PORT=5000 for consistency) |

**ConfigMap candidates (Task 8):** `APP_VERSION`, `ENVIRONMENT`  
**Secret candidate (Task 8):** None required today; add a placeholder (e.g. `API_KEY`) for practice if desired.

---

## Rationale (Why These Choices?)

### Replicas: 2
- **Why 2:** Demonstrates that the Service load-balances across multiple Pods. One replica hides failures; 2+ shows the pattern.
- **Trade-off:** More resource usage than 1; HPA (Task 11) will manage scaling later.
- **When to change:** Production might use `minReplicas: 3` for better availability.

### Port 5000 (final)
- **Why 5000:** Gunicorn in the Dockerfile binds to `${PORT:-5000}`; we use port **5000** for K8s and Compose so everything stays aligned.
- **Rule:** Compose and K8s (containerPort, targetPort) must match the port Gunicorn listens on. We stick with 5000.

### Config via env vars
- **Why:** The Flask app already reads `APP_VERSION` and `ENVIRONMENT` from the environment. Kubernetes ConfigMaps/Secrets map cleanly to env vars.
- **Benefit:** No code changes; same pattern as Project 2’s docker-compose.

---