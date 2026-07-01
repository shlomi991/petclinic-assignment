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
| **Traceability** | JFrog Build Info links the Docker image to its Maven build and Git commit |
| **DevSecOps** | JFrog Xray SCA + Contextual Analysis scan, with a policy-driven Quality Gate stage |
| **Container Security** | Lightweight `eclipse-temurin:17-jre-alpine` image, `linux/amd64`, non-root `spring` user |
| **Infrastructure as Code** | Helm chart with environment-specific `values.yaml` |

---

## Pipeline Stages

The [`Jenkinsfile`](Jenkinsfile) defines the following stages:

1. **Compile & Test** — Resolves Maven dependencies via Artifactory Virtual Repositories, then compiles and runs the tests (`jf mvn clean install`).
2. **Docker Build** — Packages the compiled `.jar` into a secure Docker image.
3. **Docker Push & Traceability** — Pushes the image to Artifactory and publishes Build Info to the JFrog Project.
4. **Xray Scan & Quality Gate** — Scans the published build with Xray. When an Xray Watch/Policy is configured, the stage fails the pipeline on a policy violation (`jf bs --fail=true`).

---

## Security Scanning (JFrog Xray)

Every build is scanned by JFrog Xray for known vulnerabilities (SCA) and enriched with **Contextual Analysis** to determine whether each CVE is actually exploitable in the image.

A JFrog **Watch + Security Policy** (`petclinic-watch` / `petclinic-security-policy`) enforces the Quality Gate: the `jf bs --fail=true` stage **fails the pipeline** on any High or Critical violation. This was verified end-to-end — an early build was blocked on Critical Tomcat CVEs before remediation.

### Detect → Remediate → Pass

| CVE | Severity | Source | Remediation |
|-----|----------|--------|-------------|
| CVE-2026-55276 | Critical | `tomcat-embed-core` 11.0.22 | Upgraded to **11.0.23** via `tomcat.version` in `pom.xml` |
| CVE-2026-53434 | Critical | `tomcat-embed-core` 11.0.22 | Upgraded to **11.0.23** |
| CVE-2026-53404 | High | `tomcat-embed-core` 11.0.22 | Upgraded to **11.0.23** |
| CVE-2026-2100 | High | Alpine `p11-kit` | `apk upgrade` in `Dockerfile` (fixed in `0.26.2-r0`) |
| CVE-2026-11824 / 11822 | High | Alpine `sqlite-libs` | Not applicable per Contextual Analysis; no upstream fix yet |

The full machine-readable results (Security, Violations, License and Operational-risk exports) are provided as a separate **Xray JSON export** deliverable alongside this repository.

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

> **Note:** Credentials are included here only to simplify reviewer access — not a recommended security practice. In production, use Jenkins Credentials or a secrets manager instead.

**Step 2 — Pull and run the container**

Port `8081` is used on the host to avoid conflicts with local services (e.g. Jenkins on `8080`):

```bash
docker run -d -p 8081:8080 trialjdz9wr.jfrog.io/petclinic-docker/spring-petclinic:12
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
kubectl get svc petclinic-spring-petclinic-svc
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
