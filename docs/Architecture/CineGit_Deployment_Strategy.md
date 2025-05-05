
# CineGit – Deployment Strategy

This document outlines how CineGit code is deployed from development to production environments, including CI/CD practices, Git workflows, staging controls, and rollback mechanisms.

---

## 1. Environment Lifecycle

| Environment | Purpose                     | Domain Prefix    | Access Level         |
|-------------|-----------------------------|------------------|----------------------|
| Dev         | Feature testing, active dev | dev.cinegit.io   | Internal developers  |
| Staging     | Pre-production QA           | staging.cinegit.io| Internal + QA teams  |
| Production  | Live system                 | cinegit.io       | End users            |

---

## 2. Git Workflow

- **Main Branch**: Always deployable to production
- **Develop Branch**: Syncs with staging
- **Feature Branches**: Merged to `develop` via PR
- **Release Tags**: Used to mark production deployments

```bash
git checkout -b feat/timeline-merge
git push origin feat/timeline-merge
# Open PR -> develop -> main
```

---

## 3. CI/CD Pipeline (GitHub Actions + ArgoCD)

| Stage          | Trigger                  | Output                              |
|----------------|--------------------------|-------------------------------------|
| Lint/Test      | PR to any branch         | Unit tests, format checks, coverage |
| Build Docker   | Merge to develop         | Tagged dev container, push to ECR   |
| Deploy Staging | Merge to develop         | ArgoCD sync to staging namespace    |
| Promote Prod   | Tag release on main      | ArgoCD sync to prod namespace       |

Example GitHub Actions step:
```yaml
- name: Build and push image
  run: |
    docker build -t cinegit-api:latest .
    docker tag cinegit-api:latest $ECR_REGISTRY/cinegit-api:${{ github.sha }}
    docker push $ECR_REGISTRY/cinegit-api:${{ github.sha }}
```

---

## 4. ArgoCD GitOps Model

- Declarative Helm charts in Git repo
- Changes tracked in version control
- Auto-sync enabled for dev/staging
- Manual sync with approval gates for prod

---

## 5. Secrets & Config Management

- Sensitive values stored in AWS Secrets Manager
- Synced into Kubernetes via external-secrets controller
- Environment-specific Helm `values.yaml` control:

```yaml
image:
  tag: latest
resources:
  limits:
    cpu: 500m
    memory: 1Gi
```

---

## 6. Rollback Plan

- **Kubernetes Rollback**: Revert to previous deployment with ArgoCD
- **Database**: Point-in-time restore with AWS RDS snapshots
- **Media Assets**: S3 versioning + object lock enabled
- **Toggle flags**: Feature flags used for risky features

---

## 7. Observability & Health Checks

- Liveness and readiness probes on all pods
- Prometheus alerting (e.g., API 500 rate, queue latency)
- Grafana dashboards per service
- Loki log tailing on deploy failures

---

## 8. Traceability to System Architecture

| Service Component      | Deployment Unit        | CI/CD Responsibility |
|------------------------|------------------------|----------------------|
| API Gateway            | `api-gateway` service  | Docker + Helm chart  |
| Auth, Review, Media    | Go microservices       | Individual pipelines |
| Timeline Diff Engine   | WASM module in CDN     | Bundled with frontend|
| Media Jobs             | Lambda/EKS job queues  | Infra chart release  |
| PostgreSQL, Redis      | RDS/Elasticache        | Provisioned, not CI  |

---

## 9. Future Enhancements

- Blue/Green and Canary deployments
- Shadow testing for timeline merge engine
- SLA-backed uptime dashboard

