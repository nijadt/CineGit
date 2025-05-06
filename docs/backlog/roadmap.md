# CineGit MVP Roadmap 

This six-month plan maps **all** backlog epics—core infra, ops, security, docs, tests, notifications, API, frontend, backend—into discrete phases to ship a complete MVP.

---

## Phase 0: Kickoff, Foundations & Tooling  
**Timeline:** Weeks 1–2 (May 2025)  
**Goals & Deliverables:**  
- **Repo & IaC**  
  - `feature/mvp-roadmap` branch.  
  - Terraform: dev/staging/prod EKS clusters, VPC, RDS, Redis, S3, CDN.  
- **CI/CD & Observability**  
  - GitHub Actions + ArgoCD “Hello-World” service.  
  - Prometheus/Grafana + Loki stack.  
- **Security Baseline**  
  - WAF, TLS certs, IAM roles.  
  - API Gateway stub (OAuth2/JWT).  
- **Testing Framework**  
  - CI jobs run unit & integration tests (initial coverage target).  
- **API Docs Playground**  
  - GraphQL Playground enabled with schema introspection.  

**Epics:**  
- EPIC-INFRA (INFRA-001…INFRA-007)  
- EPIC-OPS (OPS-001, OPS-002)  
- EPIC-SECURITY (SEC-001, SEC-002)  
- EPIC-TEST (TEST-001)  
- EPIC-DOCS (DOC-001)  

---

## Phase 1: Auth, Projects & Docs  
**Timeline:** Weeks 3–6 (June 2025)  
**Goals & Deliverables:**  
- **Auth Service**  
  - Register/login (AUTH-001…AUTH-004), JWT issuance/validation (AUTH-006).  
- **RBAC & Projects**  
  - Basic Org-level roles (AUTH-005).  
  - `createProject`, `listProjects`, `getProject` (PROJ-001…PROJ-003).  
- **GraphQL & Playground**  
  - API-001, API-002: define core schema, integrate Auth & Project resolvers.  
  - Auto-generated docs & sample queries.  
- **Basic Frontend**  
  - Pages: Sign-Up, Sign-In, Projects list, Create Project.  
- **Tests & Coverage**  
  - Unit tests for Auth & Project services; CI gating.  

**Epics:**  
- EPIC-AUTH (AUTH-001…AUTH-006)  
- EPIC-PROJECT (PROJ-001…PROJ-003, PROJ-007)  
- EPIC-API (API-001, API-002)  
- EPIC-TEST (TEST-001)  
- EPIC-DOCS (DOC-001)  

---

## Phase 2: Asset Upload, Notifications & Media Pipeline  
**Timeline:** Weeks 7–10 (July 2025)  
**Goals & Deliverables:**  
- **Asset Service**  
  - S3 pre-signed URL endpoint (ASSET-001, ASSET-002).  
  - “asset_uploaded” webhook/SQS consumer.  
- **Media Processing**  
  - FFmpeg workers for proxy & thumbnail (MPROC-001…MPROC-003).  
  - Metadata extraction (MPROC-004).  
  - State transitions: `pending`→`processing`→`available`.  
- **Notification Service**  
  - Basic in-app/email on asset available (NOTIFY-001…NOTIFY-004).  
  - “notifications” table, API endpoint to list unread.  
- **Frontend**  
  - Drag-drop uploader with progress; asset gallery with thumbnail/status.  
  - Notifications panel.  
- **Tests**  
  - Integration tests for upload flow & media pipeline.  

**Epics:**  
- EPIC-ASSET (ASSET-001…ASSET-006)  
- EPIC-MEDIA-PROC (MPROC-001…MPROC-005, MPROC-006)  
- EPIC-NOTIFY (NOTIFY-001…NOTIFY-005)  
- EPIC-TEST (TEST-001)  

---

## Phase 3: Timeline Versioning, Branching & API Subscriptions  
**Timeline:** Weeks 11–14 (August 2025)  
**Goals & Deliverables:**  
- **Timeline Service**  
  - JSON schema & initial “main” branch (TL-001, TL-002).  
  - Commit versions (TL-003, TL-005).  
- **Branching**  
  - Create/switch/list branches (VER-001…VER-005).  
- **GraphQL Subscriptions**  
  - API-003: commentAdded, cutRequestCreated subscriptions.  
- **Frontend**  
  - Read-only timeline viewer (TL-004).  
  - Branch selector UI.  
  - Real-time timeline events via subscriptions.  
- **Tests**  
  - Unit tests for timeline & branch services.  

**Epics:**  
- EPIC-TIMELINE (TL-001…TL-005)  
- EPIC-VERSIONING (VER-001…VER-005)  
- EPIC-API (API-003)  
- EPIC-TEST (TEST-001)  

---

## Phase 4: Diff Engine, Cut Requests & Notifications  
**Timeline:** Weeks 15–18 (September 2025)  
**Goals & Deliverables:**  
- **Diff Engine Service**  
  - Compute diffs (DIFF-001, DIFF-002).  
  - Merge stub for UI (DIFF-004).  
- **Cut Requests**  
  - Create/List/Edit CRs (CR-001…CR-003).  
  - Attach diff view (DIFF-003).  
- **Notifications**  
  - Notify on CR creation & updates (NOTIFY-001…NOTIFY-007).  
- **Frontend**  
  - Pull-request-style CR page with diff & comment panel.  
- **Tests**  
  - End-to-end test: diff + CR lifecycle.  

**Epics:**  
- EPIC-DIFF (DIFF-001…DIFF-004)  
- EPIC-CUTREQ (CR-001…CR-003)  
- EPIC-NOTIFY (NOTIFY-006, NOTIFY-007)  
- EPIC-TEST (TEST-001)  

---

## Phase 5: Review, Commenting & Access Control  
**Timeline:** Weeks 19–22 (October 2025)  
**Goals & Deliverables:**  
- **Review Service**  
  - Frame-accurate comments & threading (REV-001…REV-004).  
  - Resolve/unresolve flows (REV-004).  
- **Real-time Updates**  
  - WebSocket push for commentAdded (WebSocketService + API-003 subscription).  
- **Cut-Request Discussion**  
  - CR comments & approvals (CR-004, CR-005).  
- **Access Control**  
  - Enforce RBAC on all new endpoints.  
- **Frontend**  
  - Comment markers, thread panel, approve/request-changes UI.  
- **Tests**  
  - Integration tests for comments & real-time.  

**Epics:**  
- EPIC-REVIEW (REV-001…REV-006)  
- EPIC-CUTREQ (CR-004, CR-005)  
- EPIC-API (API-003)  
- EPIC-SECURITY (verify RBAC)  
- EPIC-TEST (TEST-001)  

---

## Phase 6: Merge Workflow, Conflict Handling & Final Polish  
**Timeline:** Weeks 23–26 (November 2025)  
**Goals & Deliverables:**  
- **Merge Logic**  
  - 3-way merge + conflict detection (CR-006, CR-007).  
  - API endpoint `mergeCutRequest`.  
- **Merge UI**  
  - Merge button, conflict resolution hints.  
  - Finalize CR status transitions (CR-008).  
- **Notifications**  
  - Merge success/failure notifications (NOTIFY-007).  
- **Performance & Security**  
  - Diff under 2s, proxy under 60s.  
  - Security audit (RBAC, signed URLs, rate-limits).  
- **Documentation**  
  - Complete user guide, API reference, developer onboarding.  
- **Tests**  
  - Full E2E smoke: upload→branch→diff→review→merge.  
  - Coverage >80%.  

**Epics:**  
- EPIC-DIFF (merge support)  
- EPIC-CUTREQ (CR-006…CR-008)  
- EPIC-NOTIFY (NOTIFY-007)  
- EPIC-SECURITY (full audit)  
- EPIC-DOCS (DOC-001…DOC-002)  
- EPIC-TEST (TEST-001)  

---

## MVP Acceptance & Alpha Release  
**Timeline:** Week 27 (Early December 2025)  
**Activities:**  
1. **End-to-End QA**  
2. **Performance & Security Testing**  
3. **Stakeholder Demo & Feedback**  
4. **Documentation & Onboarding**  

---

### Post-MVP Extensions (After Dec 2025)

- **Billing & Subscription** (EPIC-BILLING)  
- **Offline Cloning & Sync**  
- **NLE Plugins** (EPIC-NLE)  
- **AI-Assisted Merge** (EPIC-AI-MERGE)  
- **Mobile Clients** (EPIC-MOBILE)  

---

This  roadmap ensures **all** epics—from infra to notifications to testing and docs—are woven into the MVP phases, delivering a fully functional, secure, tested, and documented CineGit MVP in six months.
