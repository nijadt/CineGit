
# CineGit – Testing Strategy

This document defines the quality assurance approach for CineGit across unit, integration, system, and end-to-end layers. The goal is to ensure high confidence, fast feedback, and scalable automation throughout the delivery pipeline.

---

## 1. Testing Objectives

- Ensure correctness and regressions across backend services and frontend components
- Provide automated validation at multiple levels (unit to production)
- Enable fast, parallel, CI-compatible feedback loops
- Cover critical media pipeline logic and timeline diffing reliability

---

## 2. Test Types & Scopes

| Test Type        | Description                                 | Tools/Frameworks                  |
|------------------|---------------------------------------------|-----------------------------------|
| Unit             | Individual function/module behavior         | Go test, Jest                     |
| Integration      | Services working together (API + DB + Cache)| Postman/Newman, Supertest         |
| End-to-End (E2E) | User journeys across system layers          | Playwright, Cypress               |
| Load/Stress      | High-volume scenarios (uploads, diffs)      | Artillery, k6                     |
| Media Validation | Proxy, thumbnail, timeline merge integrity  | Custom test harness, ffprobe      |
| Security Testing | Auth checks, API abuse, WAF bypass attempts | OWASP ZAP, Burp Suite, tfsec      |

---

## 3. Testing Layers

### A. Frontend (Next.js)
- Unit test components with Jest + React Testing Library
- Cypress for UI E2E across flows:
  - Upload & edit timeline
  - Submit/merge Cut Request
  - Frame-accurate commenting

### B. Backend (Go Services)
- `*_test.go` for business logic
- Mocks for Redis, S3, and DB (pgxmock)
- Integration test runners using Docker Compose
- Use `httptest`, `sqlmock`, and `testcontainers-go`

### C. Media Processing
- Golden-file tests for:
  - Proxy generation
  - Visual diffs (OTIO / JSONB diffs)
- Use FFmpeg + ffprobe for post-processing checks

---

## 4. Continuous Integration Testing

| Stage            | Trigger                       | Action                                  |
|------------------|-------------------------------|-----------------------------------------|
| Pull Request     | Commit to feature branch      | Run all unit & integration tests        |
| Merge to Main    | Staging pipeline              | Run full E2E tests + deployment preview |
| Release Tag      | Production promotion          | Smoke test + Canary validation          |

CI pipelines run via GitHub Actions + test matrix:
```yaml
strategy:
  matrix:
    go-version: [1.20]
    node-version: [18]
```

---

## 5. Quality Gates

- Unit test coverage: **> 80%**
- Lint and format checks must pass (eslint, go fmt)
- E2E test suite for MVP: **> 90% pass rate**

---

## 6. Developer Experience

- `make test` or `npm test` unified entry points
- Dev containers include test runners (VSCode devcontainers)
- Optional test stubs and scaffolds generated via CLI

---

## 7. Traceability

| Feature             | Test Layer             | Tool        |
|---------------------|------------------------|-------------|
| Timeline Versioning | Unit + Integration     | Go, Jest    |
| Cut Requests        | E2E + Integration      | Cypress     |
| Upload Proxy Flow   | Media Tests + E2E      | ffmpeg, k6  |
| Auth + Role Logic   | Unit + Security        | ZAP, Jest   |
| Merge Conflicts     | Media Integration      | Custom diff harness |

---

## 8. Future Work

- Snapshot testing for visual diffs
- Chaos testing for job queue failures
- Nightly regression suites for staging

