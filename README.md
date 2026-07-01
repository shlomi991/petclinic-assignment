# Spring Petclinic — DevSecOps Pipeline & Helm Deployment

[![GitHub Repository](https://img.shields.io/badge/GitHub-PetClinic--Assignment-blue?logo=github)](https://github.com/shlomi991/PetClinic-Assignment)

## Overview

This repository contains a fully automated, secure CI/CD pipeline for the Spring Petclinic application. It demonstrates an enterprise-grade software supply chain architecture using **Jenkins**, **Docker**, **Helm**, and the **JFrog Platform** (Artifactory & Xray).

This project was built with a Solutions Engineering mindset, focusing on security, traceability, scalable repository management, and deployment best practices.

---

## Architecture & Best Practices

| Area | Implementation |
|------|----------------|
| **Repository Management** | 3-tier Artifactory structure (Local, Remote, Virtual) for Maven and Docker |
| **Traceability** | JFrog Build Info links Docker images to Maven builds and Git commits |
| **DevSecOps** | Automated Xray scans with Quality Gates on every pipeline run |
| **Container Security** | Lightweight `eclipse-temurin:17-jre-alpine` image, `linux/amd64`, non-root `spring` user |
| **Infrastructure as Code** | Helm Chart with environment-specific `values.yaml` |

---

## Pipeline Stages

The [`Jenkinsfile`](Jenkinsfile) defines the following stages:

1. **Compile & Test** — Resolves Maven dependencies via Artifactory Virtual Repositories and compiles the code.
2. **Docker Build** — Packages the compiled `.jar` into a secure Docker image.
3. **Docker Push & Traceability** — Pushes the image to Artifactory and publishes Build Info to the JFrog Project.
4. **Xray Scan & Quality Gate** — Triggers an automated Xray scan and enforces security policies.

---

## How to Run the Application

The application is fully containerized. The Docker image is hosted on JFrog Artifactory.

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- (Optional) [Helm](https://helm.sh/docs/intro/install/) for Kubernetes deployment

### Option 1: Run with Docker (Local Testing)

**Step 1 — Authenticate with the registry**

Use the dedicated read-only reviewer account:

```bash
docker login trialjdz9wr.jfrog.io -u jfrog-reviewer -p Jfrog-reviewer99
```

**Step 2 — Pull and run the container**

Port `8081` is used on the host to avoid conflicts with local services (e.g. Jenkins on `8080`):

```bash
docker run -d -p 8081:8080 trialjdz9wr.jfrog.io/petclinic-docker/spring-petclinic:8
```

**Step 3 — Open the application**

Visit [http://localhost:8081](http://localhost:8081) in your browser.

---

### Option 2: Deploy with Helm (Kubernetes)

**Step 1 — Authenticate with the registry** (same as above)

```bash
docker login trialjdz9wr.jfrog.io -u jfrog-reviewer -p Jfrog-reviewer99
```

**Step 2 — Install the Helm chart**

```bash
helm install petclinic ./helm
```

**Step 3 — Verify the deployment**

```bash
kubectl get pods
kubectl get svc petclinic
```

> Image tag and repository can be customized in [`helm/values.yaml`](helm/values.yaml).

---

## Repository Structure

```
.
├── Dockerfile          # Secure container image definition
├── Jenkinsfile         # CI/CD pipeline (JFrog CLI integration)
├── helm/               # Helm chart for Kubernetes deployment
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── src/                # Spring Petclinic application source
```

---

## Links

- **GitHub:** [shlomi991/PetClinic-Assignment](https://github.com/shlomi991/PetClinic-Assignment)
- **JFrog Registry:** `trialjdz9wr.jfrog.io/petclinic-docker/spring-petclinic`
