# CineGit: Key Components and Requirements

This document outlines the key components, features, technical requirements, and other specifications derived from the CineGit project description.

## 1. Key Architectural Components

*   **Frontend:**
    *   Web Application (React + Next.js + TailwindCSS)
    *   Progressive Web App (PWA) support
    *   Mobile Apps (Implied, potentially via PWA or native)
    *   GraphQL Client (Apollo)
    *   State Management (Zustand or Redux)
*   **API Gateway:**
    *   GraphQL Server
    *   Handles API requests and authentication (OAuth)
*   **Core Backend Services (Kubernetes Microservices in GoLang):**
    *   Auth Service (JWT, OAuth2, SSO, RBAC)
    *   Project Service (Manages projects, timelines, branches)
    *   Review Service (Handles comments, cut requests)
    *   Media Service (Manages asset upload, proxy generation, diffing)
    *   Billing Service (Stripe Integration)
    *   Notification Service (Webhooks, Emails)
    *   Inter-service communication via gRPC
*   **Media Processing Layer:**
    *   FFmpeg Transcoder (Async processing, potentially Lambda/EKS)
    *   Thumbnail Generator
    *   Timeline Diff Engine (WebAssembly - WASM)
    *   Proxy Generator (Low-resolution previews)
*   **Data Stores:**
    *   PostgreSQL (Relational data: project metadata, users, etc.)
    *   Redis (Caching, session management, potentially diff storage)
*   **Media Storage & Delivery:**
    *   S3 Object Storage (Versioned, for assets, proxies)
    *   CDN (CloudFront or Cloudflare R2 for global delivery)
*   **Infrastructure & Operations:**
    *   Kubernetes (EKS suggested)
    *   Infrastructure as Code (Terraform)
    *   Monitoring & Observability (Prometheus, Grafana, Loki)
    *   CI/CD (GitHub Actions + ArgoCD)
    *   Security Layer (WAF, TLS, Encryption, Signed URLs)

## 2. Core Features

*   **MVP Features:**
    *   Timeline Versioning (Git-style)
    *   Asset Upload & Management (incl. large files >20GB)
    *   Timeline Branching System
    *   Cut Requests (Pull Request equivalent for timelines)
    *   Visual Timeline Diff Viewer (Insert/Delete/Move detection)
    *   Frame-accurate Commenting & Review Tools
    *   Role-Based Access Control (RBAC)
    *   Activity Logs/Audit Trails
*   **Post-MVP Roadmap:**
    *   AI-Assisted Merge Conflict Resolution
    *   Offline Cloning with Sync
    *   Automatic Proxy Generation
    *   NLE Plugins (Premiere Pro, DaVinci Resolve, FCPX)
    *   Cloud Rendering Farm Integrations

## 3. Technology Stack Summary

*   **Frontend:** React, Next.js, TailwindCSS, PWA, Zustand/Redux, Apollo Client
*   **Backend:** GoLang (Microservices), GraphQL (API Gateway), gRPC (Inter-service)
*   **Databases:** PostgreSQL, Redis
*   **Media Processing:** FFmpeg, WebAssembly (for diffing)
*   **Storage/CDN:** AWS S3 (Versioned), AWS CloudFront / Cloudflare R2
*   **Infrastructure:** Kubernetes (EKS), Terraform, Docker
*   **Ops/Monitoring:** Prometheus, Grafana, Loki, GitHub Actions, ArgoCD

## 4. Performance Requirements

*   **Timeline Diff:** < 2 seconds for timelines with 500+ edits.
*   **Uploads:** Support for >20GB files via multipart S3 uploads.
*   **Proxy Generation:** Automatic trigger within 60 seconds of upload completion.
*   **Delivery:** Global, low-latency delivery via CDN.

## 5. Security Requirements

*   **Encryption:** AES-256 at rest, TLS 1.3 in transit.
*   **Access Control:** Signed URLs for uploads/downloads, RBAC.
*   **API Security:** OWASP Top 10 hardening, WAF protection.

## 6. Database Schema (Initial Draft - Key Tables)

*   **Users:** id, email, name, role, auth_provider, timestamps
*   **Projects:** id, owner_id, title, description, visibility, timestamps
*   **Branches:** id, project_id, name, parent_branch_id, timestamps
*   **Assets:** id, project_id, branch_id, file_path, proxy_path, metadata (incl. fingerprint hashes for deduplication)
*   **Timelines:** id, project_id, branch_id, timeline_json, timestamps
*   **CutRequests:** id, from_branch_id, to_branch_id, status, timestamps
*   **Comments:** id, project_id, asset_id, timestamp (frame-accurate), comment_text, user_id

## 7. Integrations

*   **NLE Plugins:** Adobe Premiere Pro, DaVinci Resolve, Final Cut Pro X (Post-MVP)
*   **Automation:** Webhooks, Zapier
*   **API:** Full REST/GraphQL API for third-party development.
*   **Billing:** Stripe
*   **Authentication:** OAuth2, SSO (Enterprise)

## 8. Business Model Tiers

*   Freemium (Limits: 20GB, 2 collaborators)
*   Studio ($29/user/mo, Unlimited projects, 5TB, private domains)
*   Per-Project (One-time fee)
*   Enterprise (Custom pricing, private cloud, SSO, priority support)
