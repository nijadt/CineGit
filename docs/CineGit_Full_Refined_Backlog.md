# CineGit – Full Refined Backlog Extension

## EPIC-OPS: Infrastructure, CI/CD automation, observability, and system monitoring.

### OPS-001 – CI/CD pipeline setup for frontend and backend
**User Story**: As a dev, I want automated build/test/deploy for each commit so that the code is continuously integrated.

**Acceptance Criteria:**
- Pipeline triggered on PRs and main merges
- Unit tests and linting auto-run
- Deploys to staging and production clusters via ArgoCD

### OPS-002 – Set up centralized logging and metrics collection
**User Story**: As a devops engineer, I want Prometheus and Grafana configured so I can monitor system health.

**Acceptance Criteria:**
- Services export metrics to Prometheus
- Grafana dashboards created for CPU, mem, job queue, DB
- Loki collects logs and supports log-based alerts

## EPIC-SECURITY: Authentication, rate-limiting, and security hardening.

### SEC-001 – Enforce API rate limiting at gateway level
**User Story**: As an admin, I want rate limiting in place so abusive clients can't overload the system.

**Acceptance Criteria:**
- 100 requests/minute limit per user enforced
- 429 responses returned on abuse
- Metrics tracked for spikes

### SEC-002 – Configure Web Application Firewall (WAF)
**User Story**: As a security engineer, I want to block malicious traffic at the edge.

**Acceptance Criteria:**
- OWASP rule set applied to API gateway
- Common injection patterns logged and blocked
- Custom rules for brute force detection

## EPIC-DOCS: Documentation, SDKs, and onboarding materials.

### DOC-001 – Create API documentation with GraphQL Playground
**User Story**: As a dev, I want interactive docs so I can explore the API easily.

**Acceptance Criteria:**
- GraphQL playground enabled in staging
- Auto-generated schema introspection
- Sample queries and mutations provided

### DOC-002 – Write SDK for NLE Plugin API (JS/TS)
**User Story**: As a plugin developer, I want a typed SDK so I can interact with CineGit from my NLE extension.

**Acceptance Criteria:**
- SDK supports asset upload, branch fetch, and review submission
- README included with usage examples
- Type declarations provided

## EPIC-MOBILE: Exploratory phase for mobile clients.

### MOB-001 – Research native vs cross-platform mobile shell
**User Story**: As a product lead, I want a feasibility study on mobile app tech stack.

**Acceptance Criteria:**
- Compare Flutter, React Native, Native
- List pros/cons per requirement (video, comments, sync)
- Documented recommendation

## EPIC-ANALYTICS: User and system metrics collection.

### ANA-001 – Track project creation and timeline save events
**User Story**: As a PM, I want to know how users engage with editing features.

**Acceptance Criteria:**
- Events logged to analytics provider (Segment/Amplitude)
- Timeline diffs saved with metadata (duration, size)
- Reports segmented by user role

## EPIC-TEST: Testing framework, CI validation, and QA environments.

### TEST-001 – Setup unit and integration test suite
**User Story**: As a dev, I want coverage confidence so I can deploy safely.

**Acceptance Criteria:**
- Tests run in CI for each service
- Code coverage >80%
- Failures block deploy

## EPIC-AI-MERGE: Initial research on AI-assisted timeline merge.

### AI-001 – Explore AI models for timeline delta prediction
**User Story**: As a researcher, I want to assess ML approaches for merging timelines.

**Acceptance Criteria:**
- Experiment with OTIO diffs and heuristic merge strategies
- Identify merge conflict patterns
- Propose model architecture or rule engine

