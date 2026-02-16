## Project 3 – Kubernetes Architecture Overview

This document explains how the Flask app from **`dockerized-app-cicd-aws-1125` (Project 2)** is deployed on Kubernetes. It focuses on the **request flow** (browser → Ingress → Service → Pods) and the core objects.

---

## High-Level Components

- **User / Client**
  - Browser or `curl` calling:
    - `/` – main page.
    - `/health` – health check.
    - `/api/info` – JSON with app/env details.

- **Ingress Controller + Ingress**
  - Ingress Controller (e.g. NGINX Ingress) terminates external HTTP/HTTPS traffic.
  - An `Ingress` resource routes external traffic (e.g. `http://flask.local/*`) to the internal Service.

- **Service (`ClusterIP`)**
  - Internal load balancer for the Flask Pods.
  - Type: `ClusterIP`, selected by labels like `app: flask-app`.
  - Provides a stable DNS name inside the cluster that the Ingress targets.

- **Deployment + Pods**
  - `Deployment` manages one or more replicas of the Flask app.
  - Each Pod runs the Docker image built in **`dockerized-app-cicd-aws-1125`**.
  - Container listens on port `5000` (configurable via environment variable).
  - Environment variables such as `APP_VERSION` and `ENVIRONMENT` are injected through the Pod spec (later wired to ConfigMaps/Secrets).

- **Database (optional, future)**
  - The current Flask app does **not use a database**.
  - If needed later, a DB would be exposed via its own Service (in-cluster) or a managed endpoint (e.g. RDS).

---

## Database Strategy

**Decision:** This project does **not** use a database. No DB setup is required.

**Rationale:**

- The Flask app from Project 2 is **stateless**. It serves `/`, `/health`, and `/api/info` using only environment variables and runtime info (hostname, version). No persistent data is stored.
- This project focuses on **Kubernetes deployment patterns** (Deployment, Service, Ingress, ConfigMaps, Secrets, HPA). Adding a database would expand scope without demonstrating additional K8s concepts for this portfolio slice.
- Project 1 (Terraform) already includes RDS. A future iteration could wire this app to a managed DB; for now, documenting the decision is sufficient.

**If a database were needed later:**

- Use a managed service (e.g. AWS RDS) or an in-cluster DB (e.g. PostgreSQL StatefulSet).
- Expose it via a ClusterIP Service and inject connection details via Secrets.
- Add an init container or startup logic in the app to verify connectivity before serving traffic.

---

## Data Flow: Request Path

At a high level, HTTP requests follow this path:

```text
User Browser / curl
        |
        v
Ingress Controller (Ingress rules)
        |
        v
Service (ClusterIP)
        |
        v
Flask Pods (Deployment)
        |
        v
Flask routes inside container
```

### Request examples

- **`GET /`**
  - Purpose: user-facing home page.
  - Flow: Browser → Ingress → Service → Flask Pod → `home()` route → HTML response.

- **`GET /health`**
  - Purpose: health endpoint for probes and basic diagnostics.
  - Flow: Client/probe → Ingress → Service → Flask Pod → `health()` route → JSON.
  - Used later for Kubernetes **liveness/readiness probes**.

- **`GET /api/info`**
  - Purpose: quick way to inspect version, environment, hostname, and runtime info.
  - Flow: Client → Ingress → Service → Flask Pod → `info()` route → JSON response.

---

## Relationship to Project 2 (Flask + Docker)

- **Reused Pieces**
  - The same Flask application (`main.py`) and Docker image from Project 2 (dockerized-app-cicd-aws-1125) are reused without major code changes.
  - Configuration is still driven by environment variables, which maps cleanly to Kubernetes `env` configuration, ConfigMaps, and Secrets.

- **What Kubernetes Adds**
  - **Scheduling and replicas**: multiple Pods can run the same image for high availability and horizontal scaling.
  - **Stable networking**: Services and Ingress provide stable endpoints independent of Pod lifecycles.
  - **Health management**: readiness/liveness probes can leverage `/health` to restart or remove unhealthy Pods from traffic.

---