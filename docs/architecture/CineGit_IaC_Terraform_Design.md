
# CineGit – Infrastructure as Code (IaC) Design

## Overview

CineGit's infrastructure will be provisioned using **Terraform**. The goal is to provide:
- Modular, reusable infrastructure components
- Clear separation of environments (dev, staging, prod)
- Scalability, high availability, and observability

---

## 1. Repository Structure

```
infrastructure/
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── terraform.tfvars
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   ├── redis/
│   ├── s3/
│   ├── cloudfront/
│   ├── observability/
│   └── media-processing/
└── environments/
    ├── dev/
    ├── staging/
    └── prod/
```

---

## 2. Modules and Responsibilities

### VPC Module
- Sets up isolated networking
- Subnets: public/private
- NAT gateways and route tables

### EKS Module
- Manages the Kubernetes control plane
- Node groups for general workloads and media jobs
- Auto-scaling and IRSA support for IAM roles

### RDS Module
- PostgreSQL provisioned with multi-AZ
- Automated backups
- Encryption enabled

### Redis Module
- Elasticache Redis cluster for sessions and diff previews
- Low latency read/write

### S3 + CloudFront Module
- Versioned buckets for media, thumbnails, proxies
- CDN distribution with signed URLs and WAF integration

### Observability Module
- Prometheus, Grafana, Loki deployment on EKS via Helm
- Dashboards, alerts, and logs preconfigured

### Media Processing Module
- Lambda + EFS for FFmpeg jobs
- IAM roles for containerized fallback jobs on EKS

---

## 3. Environments

- **Dev**: Ephemeral, feature testing, low scale
- **Staging**: Full replica of prod (without data), for integration tests
- **Prod**: Scaled to meet SLA requirements

---

## 4. Remote State & Backend

Use an S3 bucket with DynamoDB locking for storing remote state:
```hcl
terraform {
  backend "s3" {
    bucket         = "cinegit-tf-state"
    key            = "env/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cinegit-tf-locks"
  }
}
```

---

## 5. Security Best Practices

- All resources tagged with `project = cinegit`
- IAM roles with least privilege
- Secrets managed via AWS Secrets Manager (injected into pods)

---

## 6. Tooling & Automation

- Validate and plan using `pre-commit` hooks
- CI/CD with GitHub Actions:
  - `terraform fmt`, `validate`, `plan` on PR
  - `apply` gated to main branch only
- ArgoCD or Flux for EKS deployments from GitOps repo

---

## 7. Traceability to Architecture

| Component             | Terraform Module       | Service Dependency       |
|-----------------------|------------------------|--------------------------|
| Kubernetes (EKS)      | `eks/`                 | All backend microservices|
| Object Storage        | `s3/`                  | Media Service, Proxy     |
| CDN                   | `cloudfront/`          | Proxy & playback         |
| Relational DB         | `rds/`                 | Project, Timeline, Review|
| Redis Cache           | `redis/`               | Diffing & session tokens |
| Media Processing      | `media-processing/`    | FFmpeg Lambda + EKS jobs |
| Observability         | `observability/`       | Prometheus, Loki, Grafana|

---

## 8. Next Steps

- Bootstrap Terraform workspace per environment
- Connect CI/CD pipeline to auto-validate Terraform changes
- Run security scans (e.g. tfsec, checkov)

