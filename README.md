# Spring Petclinic - DevSecOps Pipeline & Helm Deployment

## Overview
This repository contains a fully automated, secure CI/CD pipeline for the Spring Petclinic application. It demonstrates an enterprise-grade software supply chain architecture using **Jenkins**, **Docker**, **Helm**, and the **JFrog Platform** (Artifactory & Xray).

This project was built with a Solutions Engineering mindset, focusing on security, traceability, scalable repository management, and deployment best practices.

## Architecture & Best Practices Showcase

* **Repository Management (Artifactory):** Utilizes the recommended 3-tier structure (Local, Remote, and Virtual repositories) for both Maven dependencies and Docker images. This ensures secure, cached, and reliable dependency resolution.
* **Complete Traceability (Build Info):** The Jenkins pipeline (`Jenkinsfile`) leverages the JFrog CLI to separate the compilation stage from the Docker build. This captures comprehensive Build Info (environment variables, dependencies, and artifacts), linking the final Docker image directly to the Git commit and Maven build.
* **DevSecOps & Quality Gates (Xray):** Every build is automatically scanned for vulnerabilities (CVEs) and policy violations. A Quality Gate is enforced to fail the CI process if severe security threats are detected.
* **Secure Containerization:** The `Dockerfile` uses a lightweight `eclipse-temurin:17-jre-alpine` base image, pinned to `linux/amd64` for cross-platform stability. It implements a non-root user (`spring`) to minimize the attack surface.
* **Infrastructure as Code (Helm):** Instead of static YAMLs, the application is packaged as a Helm Chart, allowing for dynamic multi-environment deployments via `values.yaml`.

## Pipeline Stages (`Jenkinsfile`)
1.  **Compile & Test:** Resolves Maven dependencies securely via Artifactory Virtual Repositories and compiles the code.
2.  **Docker Build:** Packages the compiled `.jar` into a secure Docker image.
3.  **Docker Push & Traceability:** Pushes the image to Artifactory and publishes the explicit Build Info to a dedicated JFrog Project.
4.  **Xray Scan & Quality Gate:** Triggers an automated Xray scan to enforce security policies.

---

## How to Run the Application (Runnable Docker Image)

As per the assignment requirements, the application is fully containerized. The image is hosted on a secure JFrog Artifactory registry.

**1. Authenticate with the Registry:**
To pull the image, please authenticate using this dedicated Read-Only reviewer account:
```bash
docker login trialjdz9wr.jfrog.io -u jfrog-reviewer -p Jfrog-reviewer99

### Run via Docker (Local Testing)
To run the containerized application locally, use the following command. The application port is mapped to `8081` to prevent conflicts with standard services (like local Jenkins/Tomcat on 8080):

```bash
docker run -d -p 8081:8080 trialjdz9wr.jfrog.io/petclinic-docker/spring-petclinic:8