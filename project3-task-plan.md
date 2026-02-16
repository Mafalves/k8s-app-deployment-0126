## Project 3 – Kubernetes Deployment: Task Plan & Timelines

This document breaks Project 3 into concrete, time-bound tasks. Assume roughly **1–2 hours per day, 5 days per week**; adjust pacing as needed.

---

## Week 1 – Foundations and Architecture (Steps 1–2)

**Goal:** Know exactly what you’re building on Kubernetes and have Kubernetes-ready images.

### Task 1: Clarify the App Shape (≈ 0.5 day) — done
- **Start with Project 2's Flask app** – dockerized application from Project 2.
- Sketch a simple diagram: browser → Ingress → Service → Pod(s).
- Write a short `ARCHITECTURE.md` describing:
  - Components and data flow.
  - How this builds on Project 2's Flask app.
  - Why single-service deployment is appropriate for this project (DevOps engineers work with existing applications).

### Task 2: Kubernetes Environment – k3d (≈ 0.5 day) — done
- Install k3d and `kubectl`. Create cluster, then verify with `kubectl get nodes`.
- **Which tool and why:** k3d was chosen. It runs k3s (a CNCF-certified Kubernetes distribution) inside Docker, so it is lightweight and fast to create/destroy. It closely matches “real” Kubernetes behaviour, and k3s ships with Traefik as the default ingress controller, which simplifies the later Ingress work (Task 7).
- **How to start/stop the cluster:**
  - Create cluster: `k3d cluster create dev-cluster`
  - List clusters: `k3d cluster list`
  - Stop cluster (keeps state): `k3d cluster stop dev-cluster`
  - Start cluster again: `k3d cluster start dev-cluster`
  - Delete cluster (full teardown): `k3d cluster delete dev-cluster`
- **Verification:** After create, `kubectl` context is set automatically. Confirm with `kubectl config get-contexts` and `kubectl get nodes` (node should be Ready).

### Task 3: Review / Harden Docker Images (≈ 1 day) — done 
- Review the Flask app's Docker image from Project 2:
  - Confirm a single main process and clear entrypoint.
  - Ensure configuration is via environment variables (ports, etc.).
  - Avoid storing state on the container filesystem (prefer volumes or external services if needed).
- Decide on an image naming and tagging convention (e.g., `flask-app:0.1.0` or reuse Project 2's convention).

### Task 4: Registry Plan and Test Push (≈ 0.5 day) — done
- Decide on Docker Hub vs a private registry.
- Create repositories/namespaces as needed.
- Push one test image and confirm you can pull it locally.

---

## Week 2 – Core Kubernetes Manifests (Steps 3–5, Minimal Slice)

**Goal:** Get **one service** running on Kubernetes end-to-end.

### Task 5: Design Kubernetes Objects for the Flask App (≈ 0.5 day, planning only) — done
- For the Flask service, decide:
  - Desired replicas (e.g., 2).
  - Container and Service ports (likely port 5000 from Project 2).
  - Required environment variables (e.g. APP_ENV, PORT).
- Capture this in a small table or notes document.
- **Captured in `k8s-design-notes.md`:** replicas 2, port 5000, env APP_VERSION + ENVIRONMENT.

### Task 6: Deploy the Flask App Service (≈ 1–1.5 days) — done
- Create a `Deployment` for the Flask application.
- Create a ClusterIP `Service` exposing the Flask app inside the cluster.
- Verify:
  - Pods are running (`kubectl get pods`).
  - You can reach the Flask app via `kubectl port-forward` or similar.

### Task 7: Introduce a Simple Ingress Path (≈ 1 day) — done
- Use k3d’s default Traefik ingress controller (no extra install).
- Create an `Ingress` that routes `/` to the Flask app Service.
- Test:
  - Hit the Ingress endpoint from your browser or `curl`.
  - Confirm requests reach the Flask application.

### Task 8: Basic Config & Secrets for the Flask App (≈ 0.5–1 day) — done
- Move at least one config item into a `ConfigMap` (e.g., `APP_ENV`, `ENVIRONMENT`).
- Move at least one sensitive value into a `Secret` (even if fake for now).
- Wire these into the Flask app `Deployment` as environment variables.

---

## Week 3 – Scaling, Resilience, and Structure (Steps 5–7)

**Goal:** Flask app running reliably with scaling, health checks, and organized structure.

### Task 9: Verify End-to-End Functionality (≈ 0.5 day) — done
- Confirm the Flask app is accessible via Ingress.
- Test the basic user flow end-to-end.
- Verify all routes and features work as expected.

### Task 10: DB Strategy (≈ 0.5 day) — done
- This project’s Flask app does **not** use a database (see `ARCHITECTURE.md`). Document that decision and skip DB setup.

### Task 11: Add Probes and HPA for the Flask App (≈ 1 day) — done
- Add a readiness probe (e.g., `/health` - check if Project 2's Flask app has this) and a liveness probe to the Flask app Deployment.
- Configure a Horizontal Pod Autoscaler (HPA) for the Flask app:
  - Scale on CPU to start (e.g., target 60% utilization).
  - Set min/max replicas (e.g., 2–5).
- Generate some load (even with a simple script or curl loop) to observe scaling behavior.

### Task 12: Organize Manifests and Think Environments (≈ 0.5–1 day) — done
- Decide a folder structure for manifests (e.g., per-service files under a `k8s/` directory).
- Optionally plan for dev/prod separation:
  - Separate folders, or
  - A future move to Kustomize/Helm (document the plan even if you don’t implement it yet).

---

## Week 4 – CI/CD, Observability Basics, and Polish (Steps 8–10)

**Goal:** Have a reasonable automation story and strong documentation for portfolio use.

### Task 13: Connect CI to Image Builds (≈ 1–1.5 days)
- Ensure your existing CI pipeline from Project 2:
  - Builds the Flask app image.
  - Pushes it to your chosen registry (Docker Hub) with the expected tags.
- Document the “git commit → new image” flow.

### Task 14: Define a Simple Deployment Flow (≈ 1 day)
- Decide for now:
  - Manual flow: update image tags in manifests and run `kubectl apply`, or
  - Basic CI job that runs `kubectl apply` on main.
- Write a `DEPLOYMENT.md` that describes the exact deployment steps you follow.

### Task 15: Logging and Basic Observability (≈ 0.5 day)
- Confirm apps log to stdout/stderr and you can use `kubectl logs` and `kubectl describe` to debug.

### Task 16: Documentation and Diagrams (≈ 1 day)
- Create a Kubernetes architecture diagram (pods, services, ingress).
- Write or refine the main Project 3 `README` to include:
  - Prerequisites (k3d, kubectl, etc.).
  - How to deploy the application.
  - How to access the application.
  - Key design decisions and trade-offs you made.

---