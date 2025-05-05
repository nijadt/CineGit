# CineGit - System Architecture Document

**Version:** 0.1
**Date:** May 4, 2025

## 1. Introduction

This document outlines the proposed system architecture for CineGit, a cloud-native platform for collaborative video editing and version control. It details the major components, their interactions, data flows, technology choices, and considerations for scalability, security, and maintainability, addressing the requirements outlined in the project prompt.

## 2. High-Level Architecture

The system follows a microservices architecture pattern, deployed on a cloud platform (e.g., AWS, GCP, Azure) using container orchestration (Kubernetes). A central API Gateway manages external access, routing requests to appropriate backend services. Media processing is handled asynchronously, and data is stored in dedicated databases and object storage.

```mermaid
graph TD
    subgraph User Facing
        A[Web Client (React/Next.js PWA)]
        B[NLE Plugins (Premiere, Resolve, FCPX)]
        C[Mobile Apps (Future)]
    end

    subgraph Core Services
        D[API Gateway (GraphQL)]
        E[Auth Service]
        F[Project Service]
        G[Timeline Service]
        H[Asset Service]
        I[Review Service]
        J[Notification Service]
        K[Billing Service]
    end

    subgraph Data & Processing
        L[Media Processing Pipeline (FFmpeg, WASM Diff)]
        M[Event Bus (Kafka/EventBridge)]
        N[PostgreSQL (Metadata)]
        O[Redis (Cache/Sessions)]
        P[Object Storage (S3/GCS)]
        Q[CDN (CloudFront/Cloudflare)]
    end

    subgraph Infrastructure & Ops
        R[Kubernetes Cluster (EKS/GKE)]
        S[CI/CD Pipeline (GitHub Actions/ArgoCD)]
        T[Monitoring & Logging (Prometheus/Grafana/Loki)]
        U[Infrastructure as Code (Terraform)]
    end

    A --> D
    B --> D
    C --> D

    D --> E
    D --> F
    D --> G
    D --> H
    D --> I
    D --> J
    D --> K

    H -- Triggers Processing --> M
    M -- Events --> L
    L -- Stores Results --> P
    L -- Updates Metadata --> G
    L -- Updates Metadata --> H

    E -- Reads/Writes --> N
    F -- Reads/Writes --> N
    G -- Reads/Writes --> N
    H -- Reads/Writes --> N
    I -- Reads/Writes --> N
    K -- Reads/Writes --> N

    E -- Uses --> O
    F -- Uses --> O
    G -- Uses --> O
    H -- Uses --> O
    I -- Uses --> O

    H -- Stores/Retrieves --> P
    P -- Serves Content --> Q
    A -- Requests Content --> Q
    B -- Requests Content --> Q
    C -- Requests Content --> Q

    M -- Events --> J
    I -- Events --> J
    F -- Events --> J

    R -- Hosts --> D
    R -- Hosts --> E
    R -- Hosts --> F
    R -- Hosts --> G
    R -- Hosts --> H
    R -- Hosts --> I
    R -- Hosts --> J
    R -- Hosts --> K
    R -- Hosts --> L
    R -- Hosts --> M

    S -- Deploys --> R
    T -- Monitors --> R
    U -- Defines --> R
    U -- Defines --> N
    U -- Defines --> O
    U -- Defines --> P
    U -- Defines --> Q
    U -- Defines --> M
```

**Key Principles:**

*   **Modularity:** Services are independent and focused on specific domains.
*   **Scalability:** Components can be scaled independently based on load.
*   **Resilience:** Failure in one service should minimally impact others.
*   **Cloud-Native:** Leverages cloud provider services for storage, compute, and managed databases/queues.
*   **Asynchronous Processing:** Heavy tasks like media transcoding are handled offline.

---


## 3. Component Descriptions

### 3.1. User Facing Components

*   **Web Client (React/Next.js PWA):** The primary user interface for accessing CineGit features. Built as a Progressive Web App for potential offline capabilities and installability. Handles user interactions, displays project data, timelines, assets, comments, and integrates with the API Gateway.
*   **NLE Plugins (Premiere, Resolve, FCPX):** Extensions for popular Non-Linear Editing software. Allow users to interact with CineGit directly from their editing environment (e.g., push/pull timelines, manage assets, receive comments). Connects to the API Gateway.
*   **Mobile Apps (Future):** Native or PWA-based mobile applications for on-the-go review, commenting, and project status monitoring.

### 3.2. Core Services (Microservices)

*   **API Gateway (GraphQL):** Single entry point for all client requests. Authenticates requests (using Auth Service), routes them to appropriate backend microservices, and aggregates responses. GraphQL provides flexibility for client queries.
*   **Auth Service (GoLang):** Manages user identity, authentication (e.g., passwords, OAuth2, SSO via SAML/OIDC), authorization (RBAC), and issues/validates JWTs.
*   **Project Service (GoLang):** Handles creation, management, and organization of projects, including user roles and permissions within projects.
*   **Timeline Service (GoLang):** Manages timeline data structures, branching, merging logic (coordinating with the Diff Engine), version history, and Cut Requests. Stores timeline metadata and structure (likely referencing assets managed by the Asset Service).
*   **Asset Service (GoLang):** Responsible for managing media assets, including metadata, storage locations (pointers to Object Storage), versioning of assets (if needed, distinct from timeline versions), and triggering processing tasks (via Event Bus).
*   **Review Service (GoLang):** Manages comments, annotations (time-based, frame-accurate), review sessions, and approval workflows associated with timelines and assets.
*   **Notification Service (GoLang):** Handles sending notifications (email, in-app, webhooks) based on events within the system (e.g., new comment, cut request update, processing complete).
*   **Billing Service (GoLang):** Manages subscription plans, usage tracking (storage, processing time), invoicing, and payment processing (integrating with Stripe).

### 3.3. Data & Processing Components

*   **Media Processing Pipeline (GoLang/Python/WASM):** A set of asynchronous workers responsible for tasks triggered by the Asset Service via the Event Bus. Includes:
    *   *Transcoding:* Creating different resolutions/formats (proxies).
    *   *Thumbnail Generation:* Creating preview images.
    *   *Metadata Extraction:* Reading technical metadata from files.
    *   *Timeline Diff Engine:* Comparing timeline versions (potentially using WASM for complex logic or specific algorithms).
*   **Event Bus (Kafka/AWS EventBridge/Google PubSub):** Decouples services. Used for signaling events like 'asset uploaded', 'processing required', 'comment added', 'cut request created'. Allows services to react to events without direct coupling.
*   **PostgreSQL Database:** Primary relational database for storing structured metadata: user accounts, project details, timeline structures (references to assets), branch history, comment data, permissions, billing info, etc.
*   **Redis:** In-memory data store used for caching frequently accessed data (e.g., user sessions, project lists, hot timeline data), rate limiting, and potentially managing WebSocket connection states.
*   **Object Storage (AWS S3 / Google Cloud Storage):** Scalable and durable storage for all media assets (original files, proxies, thumbnails, potentially diff artifacts). Versioning can be enabled for asset history.
*   **CDN (AWS CloudFront / Cloudflare):** Distributes media assets (especially proxies and thumbnails) globally for low-latency access by users.

### 3.4. Infrastructure & Operations

*   **Kubernetes Cluster (EKS/GKE/AKS):** Container orchestration platform for deploying, scaling, and managing the microservices.
*   **CI/CD Pipeline (e.g., GitHub Actions, GitLab CI, Jenkins + ArgoCD):** Automates building, testing, and deploying code changes to the Kubernetes cluster.
*   **Monitoring & Logging (e.g., Prometheus, Grafana, Loki, ELK Stack):** Collects metrics, logs, and traces from all services for performance monitoring, debugging, and alerting.
*   **Infrastructure as Code (Terraform/Pulumi):** Manages cloud infrastructure resources (Kubernetes cluster, databases, storage buckets, networking) declaratively.

---


## 4. Data Flows

This section describes the sequence of interactions for key user actions.

### 4.1. Media Upload Flow

1.  **Client (Web/Plugin):** User initiates upload for a specific project/branch.
2.  **Client -> API Gateway:** Sends request with file metadata (name, size, type) and project/branch context, including auth token.
3.  **API Gateway -> Auth Service:** Validates token.
4.  **API Gateway -> Project Service:** Verifies user has upload permissions for the project/branch.
5.  **API Gateway -> Asset Service:** Forwards request to initiate upload.
6.  **Asset Service:** Creates an asset record in the database (PostgreSQL) with status "pending_upload".
7.  **Asset Service -> Object Storage (S3/GCS):** Requests a secure, time-limited pre-signed URL for direct upload.
8.  **Object Storage -> Asset Service:** Returns the pre-signed URL.
9.  **Asset Service -> API Gateway -> Client:** Returns the pre-signed URL and the new asset ID.
10. **Client -> Object Storage:** Uploads the file directly using the pre-signed URL (using multipart upload for large files).
11. **Object Storage:** Upon successful upload completion, triggers an event (e.g., S3 Event Notification).
12. **Object Storage -> Event Bus (SNS/SQS/PubSub):** Publishes an "asset_uploaded" event containing asset ID and storage location details.
13. **Event Bus -> Asset Service (Subscriber):** Consumes the event, updates the asset record status to "uploaded" or "processing" in PostgreSQL.
14. **Event Bus -> Media Processing Pipeline (Subscriber):** Consumes the event, initiating jobs for proxy generation, thumbnail extraction, and metadata analysis.
15. **Media Processing Pipeline:** Performs tasks (e.g., using FFmpeg workers).
16. **Media Processing Pipeline -> Object Storage:** Stores generated proxies and thumbnails.
17. **Media Processing Pipeline -> Event Bus:** Publishes "processing_complete" or "processing_failed" events with asset ID and results (e.g., proxy paths).
18. **Event Bus -> Asset Service (Subscriber):** Updates asset record with proxy/thumbnail locations and status "available".
19. **Event Bus -> Notification Service (Subscriber):** Optionally notifies the user of upload/processing completion.

### 4.2. Create Branch Flow

1.  **Client (Web/Plugin):** User requests to create a new branch from an existing branch within a project.
2.  **Client -> API Gateway:** Sends request with project ID, source branch ID, and new branch name, including auth token.
3.  **API Gateway -> Auth Service:** Validates token.
4.  **API Gateway -> Project Service:** Verifies user has branching permissions for the project.
5.  **API Gateway -> Timeline Service:** Forwards request to create the branch.
6.  **Timeline Service:** Reads the latest timeline version data associated with the source branch ID from PostgreSQL.
7.  **Timeline Service:** Creates a new branch record in PostgreSQL, linking it to the project and setting its parent branch ID.
8.  **Timeline Service:** Creates a new initial timeline version record for the new branch, copying or referencing the timeline data from the source branch's latest version.
9.  **Timeline Service -> API Gateway -> Client:** Returns confirmation of branch creation, including the new branch ID.

### 4.3. Add Comment Flow

1.  **Client (Web/Plugin):** User adds a comment (text, potentially drawing) at a specific timecode/frame on a timeline/asset viewer.
2.  **Client -> API Gateway:** Sends request with project ID, timeline/asset ID, timecode/frame, comment content, and auth token.
3.  **API Gateway -> Auth Service:** Validates token.
4.  **API Gateway -> Project Service:** Verifies user has commenting permissions.
5.  **API Gateway -> Review Service:** Forwards request to add the comment.
6.  **Review Service:** Validates input (e.g., timecode range).
7.  **Review Service -> Database (PostgreSQL):** Stores the comment record, linking it to the user, project, timeline/asset, and timecode.
8.  **Review Service -> Event Bus:** Publishes a "comment_added" event with relevant details (project ID, timeline ID, comment ID, user ID).
9.  **Event Bus -> Notification Service (Subscriber):** Consumes the event, determines recipients based on project settings/mentions, and sends notifications (email, in-app).
10. **Event Bus -> Realtime Layer (e.g., WebSocket Service integrated with Review Service or separate):** Pushes the new comment data to subscribed clients viewing the same timeline/asset in real-time.
11. **Review Service -> API Gateway -> Client:** Returns confirmation that the comment was added.

### 4.4. Create Cut Request Flow

1.  **Client (Web/Plugin):** User initiates a Cut Request to merge changes from a source branch into a target branch.
2.  **Client -> API Gateway:** Sends request with project ID, source branch ID, target branch ID, title, description, and auth token.
3.  **API Gateway -> Auth Service:** Validates token.
4.  **API Gateway -> Project Service:** Verifies user has permission to create Cut Requests.
5.  **API Gateway -> Timeline Service:** Forwards request to create the Cut Request.
6.  **Timeline Service:** Validates branches exist and are related.
7.  **Timeline Service -> Database (PostgreSQL):** Creates a Cut Request record with status "open", linking source/target branches, user, title, description.
8.  **Timeline Service (Optional):** May trigger an initial diff calculation via the Media Processing Pipeline to show changes immediately.
9.  **Timeline Service -> Event Bus:** Publishes a "cut_request_created" event.
10. **Event Bus -> Notification Service (Subscriber):** Notifies potential reviewers based on project settings.
11. **Timeline Service -> API Gateway -> Client:** Returns confirmation and the new Cut Request ID.

### 4.5. Merge Cut Request Flow (Simplified)

1.  **Client (Web/Plugin):** An authorized user (reviewer/owner) approves the Cut Request.
2.  **Client -> API Gateway:** Sends request to merge Cut Request ID, including auth token.
3.  **API Gateway -> Auth Service:** Validates token.
4.  **API Gateway -> Project Service:** Verifies user has merge permissions.
5.  **API Gateway -> Timeline Service:** Forwards request to merge the Cut Request.
6.  **Timeline Service:** Retrieves Cut Request details and latest timeline versions for source and target branches from PostgreSQL.
7.  **Timeline Service -> Media Processing Pipeline (Diff/Merge Engine):** Requests a merge operation between the source and target timeline data. This might involve complex 3-way merge logic based on a common ancestor.
8.  **Media Processing Pipeline -> Timeline Service:** Returns the result: either the merged timeline data or details about merge conflicts.
9.  **Timeline Service (If Conflicts):** Updates Cut Request status to "conflicted" in PostgreSQL, notifies user via Event Bus -> Notification Service. Merge stops.
10. **Timeline Service (If Successful Merge):** Creates a new timeline version record for the *target* branch in PostgreSQL, containing the merged timeline data. Updates the Cut Request status to "merged".
11. **Timeline Service -> Event Bus:** Publishes a "cut_request_merged" event.
12. **Event Bus -> Notification Service (Subscriber):** Notifies relevant users.
13. **Timeline Service -> API Gateway -> Client:** Returns confirmation of successful merge.

---


## 5. Technical Challenges and Solutions

This section addresses key technical challenges identified in the project requirements and proposes solutions within the context of the defined architecture.

### 5.1. Handling Large Media Files (>20GB)

*   **Challenge:** Efficiently uploading, storing, and processing large video files without overwhelming the system or providing a poor user experience.
*   **Solutions:**
    *   **Upload:** Implement direct-to-cloud storage uploads using pre-signed URLs (e.g., S3 PUT Object pre-signed URLs). Utilize browser/client-side multipart uploads to handle large files reliably, allowing for pausing, resuming, and parallel chunk uploads. Include checksums (e.g., MD5/SHA) for integrity verification.
    *   **Storage:** Use scalable cloud object storage (AWS S3, Google Cloud Storage) with appropriate lifecycle policies and versioning enabled if asset history is required.
    *   **Processing:** Decouple processing from uploads using the Event Bus (Kafka/EventBridge). When an upload completes (signaled by an S3 Event Notification or similar), an event triggers the Media Processing Pipeline. This pipeline should use scalable, containerized workers (managed by Kubernetes, potentially using KEDA for event-driven scaling or tools like AWS Batch) running FFmpeg for transcoding (proxies), thumbnail generation, and metadata extraction. Processing jobs should be managed via a queue (SQS, RabbitMQ) for resilience and load balancing.
    *   **Proxy Generation (<60s):** Optimize FFmpeg commands for speed (e.g., using hardware acceleration if available on worker nodes, balancing quality vs. speed). Ensure the processing pipeline can scale horizontally to meet demand and achieve the target time.

### 5.2. Efficient Timeline Diffing/Merging

*   **Challenge:** Comparing two versions of a non-linear editing timeline (represented as potentially complex XML or JSON) to identify changes (cuts, trims, moves, effect changes) and enabling merging of branches.
*   **Solutions:**
    *   **Standardized Timeline Format:** Define a consistent internal JSON representation for timelines, abstracting away from specific NLE formats (like FCPXML, EDL, AAF). This format should be granular, representing clips, tracks, transitions, effects, markers, and metadata with unique, stable identifiers for elements where possible. Consider adapting or drawing inspiration from standards like OpenTimelineIO (OTIO).
    *   **Diff Algorithm:** Implement a structure-aware diff algorithm, not just text-based diff. This requires parsing the timeline JSON into an internal model (e.g., a tree or graph) and comparing these structures. Algorithms like tree differencing (e.g., based on Zhang-Shasha algorithm) or specialized sequence alignment algorithms adapted for timeline events (considering timecodes, track placement, asset references) are needed. The output should clearly identify insertions, deletions, modifications (e.g., clip trim, effect parameter change), and moves.
    *   **Merge Strategy:** Implement a 3-way merge approach. When merging branch A into branch B, find the common ancestor timeline version. Perform diffs (Ancestor -> A) and (Ancestor -> B). Apply changes from A to B, detecting conflicts where both A and B modified the same element relative to the ancestor. Simple conflicts might be auto-resolved (e.g., non-overlapping changes), but complex ones (e.g., conflicting edits to the same clip) will require manual user resolution via the UI, guided by the diff information.
    *   **Implementation:** House the core diff/merge logic within the Timeline Service or a dedicated sub-component (potentially called by the Media Processing Pipeline for async operations). While WASM on the client is feasible for *visualizing* diffs, the authoritative diff and merge logic should reside server-side for consistency and handling complexity. Performance target (<2s for 500+ edits) requires significant optimization and potentially pre-computation or caching.

### 5.3. Scaling Review/Comment System

*   **Challenge:** Handling potentially large numbers of frame-accurate comments and annotations across many projects and users, including real-time updates.
*   **Solutions:**
    *   **Data Model:** Store comments in PostgreSQL, indexed efficiently on `project_id`, `timeline_id`/`asset_id`, and `timestamp`/`frame_number`. Consider partitioning the comments table by project or time if scale demands.
    *   **Querying:** Optimize database queries to fetch comments within specific time ranges relevant to the user's viewport on the timeline. Implement pagination for comment lists.
    *   **Caching:** Use Redis to cache frequently accessed comment threads or counts for specific timeline segments.
    *   **Real-time Updates:** Implement a WebSocket layer (potentially a dedicated service or integrated with the Review Service). Use the Event Bus: when the Review Service saves a comment, it publishes an event. A WebSocket handler consumes this event and pushes the update to relevant subscribed clients (those viewing the specific project/timeline). Use Redis Pub/Sub or similar to broadcast messages across multiple WebSocket service instances.

### 5.4. Synchronization and Consistency (Branching/Merging)

*   **Challenge:** Ensuring data integrity and consistency when multiple users work on different branches of a timeline and perform merges.
*   **Solutions:**
    *   **Atomic Operations:** Use database transactions (ACID properties of PostgreSQL) within the Timeline Service for critical operations like creating branches, recording timeline versions, and updating merge status. This ensures that metadata remains consistent.
    *   **Timeline Immutability:** Treat timeline versions as immutable. Creating a branch creates a new version referencing the parent. Saving changes creates a new version on the current branch. Merging creates a new merge commit version on the target branch.
    *   **Locking:** Implement optimistic locking on timeline/branch records during merge operations to prevent concurrent merges on the same target branch causing inconsistencies. If conflicts occur, the operation fails, and the user must retry.
    *   **Eventual Consistency:** Accept eventual consistency for non-critical updates propagated via the Event Bus (e.g., notifications, search indexing).

### 5.5. Multi-Tenancy and Secure Project Isolation

*   **Challenge:** Securely separating data and access between different organizations or teams using the platform.
*   **Solutions:**
    *   **Tenant Identification:** Assign a unique `tenant_id` (or `organization_id`) to each user, project, asset, timeline, etc.
    *   **Data Isolation:** Enforce tenant isolation at the data layer. All database queries across all microservices *must* include a `WHERE tenant_id = ?` clause. This can be enforced via application logic, ORM middleware, or potentially PostgreSQL Row-Level Security (RLS) policies tied to the authenticated user's tenant ID (requires careful setup).
    *   **Authentication:** The Auth Service validates credentials and associates the user with their correct `tenant_id`. JWTs issued should contain the `tenant_id`.
    *   **Authorization (RBAC):** The API Gateway and downstream services use the `tenant_id` and user roles (from JWT or fetched from Auth Service) to enforce permissions (defined in the Project/Auth services) specific to that tenant's projects.
    *   **Resource Isolation (Optional):** For higher-tier plans, consider deploying tenant-specific resources (e.g., dedicated database instances, Kubernetes namespaces with resource quotas), but start with logical data separation in shared infrastructure for cost-effectiveness.
    *   **Storage Isolation:** Use distinct prefixes based on `tenant_id` within the shared Object Storage buckets (e.g., `s3://cinegit-assets/{tenant_id}/project_id/...`) and enforce access control using IAM policies or pre-signed URLs generated with tenant context.

---


## 6. Data Models and Storage Strategies

This section outlines the conceptual data models for key entities and the strategies for storing different types of data.

### 6.1. Core Entities and Relationships

*   **Organization (Tenant):** Represents a distinct customer entity (studio, company, individual group). Contains users and projects.
*   **User:** Represents an individual user account, belonging to one or more Organizations.
*   **Role:** Defines a set of permissions (e.g., Admin, Editor, Viewer).
*   **Membership:** Links Users to Organizations with a specific Role.
*   **Project:** A container for timelines, assets, and collaboration, belonging to an Organization.
*   **ProjectMember:** Links Users to Projects with specific project-level Roles/Permissions.
*   **Asset:** Represents a media file (video, audio, image). Includes metadata and pointers to files in Object Storage.
*   **Branch:** A named line of development for a timeline within a project.
*   **TimelineVersion:** An immutable snapshot of a timeline's structure at a specific point in time on a specific Branch. Contains the actual timeline data (e.g., JSON) and references Assets.
*   **CutRequest:** Represents a proposal to merge changes from one Branch into another.
*   **Comment:** A time-based annotation on a TimelineVersion or Asset.
*   **Notification:** Records notifications sent to users.
*   **BillingInfo:** Stores subscription details, usage metrics, etc., linked to an Organization.

### 6.2. PostgreSQL Schema (Conceptual Overview)

Primary storage for structured metadata. All tables should include `tenant_id` (or `organization_id`) for multi-tenancy enforcement and relevant timestamp columns (`created_at`, `updated_at`).

*   `organizations`: `id`, `name`, `subscription_plan`, ...
*   `users`: `id`, `email`, `hashed_password`, `name`, ...
*   `roles`: `id`, `name` (e.g., 'org_admin', 'project_editor')
*   `memberships`: `user_id` (FK to users), `organization_id` (FK to organizations), `role_id` (FK to roles)
*   `projects`: `id`, `organization_id` (FK), `name`, `description`, ...
*   `project_members`: `user_id` (FK), `project_id` (FK), `role_id` (FK)
*   `assets`: `id`, `project_id` (FK), `uploader_user_id` (FK), `original_filename`, `mime_type`, `size`, `status` ('pending', 'uploaded', 'processing', 'available', 'error'), `storage_path_original`, `storage_path_proxy`, `storage_path_thumbnail`, `metadata` (JSONB), `duration`, `width`, `height`, ... (Indexed on `project_id`, `status`)
*   `branches`: `id`, `project_id` (FK), `name`, `created_by_user_id` (FK), `parent_branch_id` (FK, nullable), `head_timeline_version_id` (FK, nullable)
*   `timeline_versions`: `id`, `branch_id` (FK), `project_id` (FK), `created_by_user_id` (FK), `commit_message`, `timeline_data` (JSONB or TEXT), `parent_version_id` (FK, nullable), `timestamp` (Indexed on `branch_id`, `timestamp`)
*   `timeline_version_assets`: Links `timeline_versions` to `assets` (Many-to-Many, if assets can be reused across versions/timelines)
*   `cut_requests`: `id`, `project_id` (FK), `source_branch_id` (FK to branches), `target_branch_id` (FK to branches), `created_by_user_id` (FK), `status` ('open', 'merged', 'closed', 'conflicted'), `title`, `description`, `merged_by_user_id` (FK, nullable), `merged_at` (nullable)
*   `comments`: `id`, `project_id` (FK), `timeline_version_id` (FK, nullable), `asset_id` (FK, nullable), `user_id` (FK), `timestamp_ms` (or frame number), `content` (TEXT), `position_x` (nullable), `position_y` (nullable), `parent_comment_id` (FK, nullable) (Indexed on `timeline_version_id`/`asset_id` and `timestamp_ms`)
*   `notifications`: `id`, `user_id` (FK), `type`, `message`, `related_entity_id`, `related_entity_type`, `read_status`
*   `billing_info`: `organization_id` (FK), `stripe_customer_id`, `subscription_id`, `current_period_end`, ...

*(Note: This is conceptual; actual implementation requires detailed design, normalization, indexing strategies, and potentially breaking down tables further.)*

### 6.3. Object Storage (S3/GCS)

*   **Purpose:** Store large binary files (original media, proxies, thumbnails).
*   **Structure:** Use a structured path convention including tenant and project identifiers:
    *   `s3://<bucket-name>/<tenant_id>/projects/<project_id>/assets/<asset_id>/original/<filename>`
    *   `s3://<bucket-name>/<tenant_id>/projects/<project_id>/assets/<asset_id>/proxies/<resolution>/<proxy_filename>`
    *   `s3://<bucket-name>/<tenant_id>/projects/<project_id>/assets/<asset_id>/thumbnails/<thumbnail_filename>`
*   **Access Control:** Primarily use pre-signed URLs generated by the Asset Service for uploads and downloads to ensure security and temporary access.
*   **Versioning:** Enable bucket versioning for recovery and potential asset history tracking.
*   **Lifecycle Policies:** Define policies for moving older/unused versions to cheaper storage tiers (e.g., S3 Glacier) or deleting them.

### 6.4. Redis (Cache)

*   **Purpose:** Improve performance by caching frequently accessed, non-critical data.
*   **Data:**
    *   User Sessions (if using session-based auth alongside JWTs).
    *   User permissions/roles (cache results from Auth/Project services).
    *   Project lists and basic details.
    *   Recent activity feeds.
    *   Rate limiting counters.
    *   WebSocket connection mapping (User ID -> Connection ID).
    *   Potentially short-lived locks for distributed operations.
*   **Key Strategy:** Use clear prefixes, e.g., `sess:<session_id>`, `user:<user_id>:perms`, `project:<project_id>:meta`.
*   **Eviction:** Use appropriate TTLs (Time-To-Live) for cached data.

### 6.5. Timeline Data (`timeline_data` field)

*   **Storage:** Stored within the `timeline_versions` table in PostgreSQL, likely as JSONB for queryability or TEXT if primarily treated as opaque data by the DB.
*   **Content:** Contains the structured representation of the timeline (clips, tracks, transitions, effects, asset references, timing information) based on the chosen standardized format (e.g., OTIO-like JSON).

---


## 7. Security and Scalability Considerations

### 7.1. Security

Security is paramount for a platform handling potentially sensitive media assets and user data.

*   **Authentication:** Implement robust authentication using industry standards like OAuth 2.0 and OpenID Connect. Support password-based login, social logins, and SAML/SSO for enterprise tenants. Use JWTs for session management, ensuring short expiry times and refresh token mechanisms.
*   **Authorization (RBAC):** Implement fine-grained Role-Based Access Control at both the organization and project levels. Permissions should be clearly defined and enforced consistently across the API Gateway and relevant microservices (Project, Timeline, Asset, Review). Tenant isolation (as described in 5.5) is crucial.
*   **Data Encryption:**
    *   **At Rest:** Encrypt sensitive data in PostgreSQL (e.g., user credentials, potentially PII) and all data in Object Storage (S3 server-side encryption with managed keys or customer-managed keys).
    *   **In Transit:** Enforce TLS 1.3 for all communication (client-to-gateway, gateway-to-service, service-to-service, service-to-database/storage).
*   **API Security:**
    *   Protect the API Gateway with a Web Application Firewall (WAF) to mitigate common web attacks (SQLi, XSS, etc.).
    *   Implement strict input validation and output encoding in all services.
    *   Apply rate limiting at the API Gateway to prevent abuse.
*   **Media Access Control:** Use short-lived, pre-signed URLs for direct uploads and downloads to Object Storage, generated by the Asset Service based on user permissions.
*   **Infrastructure Security:**
    *   Use Kubernetes network policies to restrict communication between services.
    *   Manage secrets (API keys, database passwords) securely using tools like HashiCorp Vault or cloud provider secret managers (AWS Secrets Manager, GCP Secret Manager).
    *   Regularly patch and update OS, containers, and dependencies.
*   **Auditing:** Maintain comprehensive activity logs (stored potentially in a separate logging system like ELK or a dedicated audit table) tracking user actions, administrative changes, and significant system events.
*   **Dependency Management:** Implement automated scanning for vulnerabilities in third-party libraries (e.g., Snyk, Dependabot).

### 7.2. Scalability

The architecture is designed for scalability, but specific strategies include:

*   **Microservices:** Allows individual services (e.g., Media Processing, Review Service) to be scaled independently based on their specific load using Kubernetes Horizontal Pod Autoscaling (HPA).
*   **Stateless Services:** Design backend services to be stateless where possible, storing state in databases or caches, which simplifies scaling horizontally.
*   **Asynchronous Processing:** Using an Event Bus (Kafka/EventBridge) and message queues decouples heavy tasks (media processing) from synchronous API requests, allowing the processing pipeline to scale independently and handle bursts of activity.
*   **Database Scaling:**
    *   **Read Replicas:** Utilize PostgreSQL read replicas to scale read-heavy workloads.
    *   **Connection Pooling:** Use connection poolers (like PgBouncer) to manage database connections efficiently.
    *   **Partitioning/Sharding:** Plan for potential future partitioning or sharding of large tables (e.g., `comments`, `timeline_versions`, `assets`) based on `tenant_id` or `project_id` if single-node performance becomes a bottleneck.
*   **Caching:** Leverage Redis extensively to reduce database load for frequently accessed data.
*   **CDN:** Use a CDN for global, low-latency delivery of static assets and media, offloading traffic from origin servers.
*   **Load Balancing:** Utilize load balancers at multiple levels (internet-facing for the API Gateway, internal load balancing between services, potentially via a service mesh like Istio or Linkerd).
*   **Auto-Scaling:** Configure auto-scaling for Kubernetes node pools and processing worker deployments based on metrics like CPU/memory utilization or queue length (using KEDA).

---


## 8. Conclusion

This architecture provides a robust, scalable, and secure foundation for the CineGit platform. By leveraging a microservices approach, cloud-native technologies, and asynchronous processing, it addresses the core requirements of collaborative video editing with Git-style version control. Key technical challenges, such as large file handling and timeline diffing/merging, have been addressed with specific solutions involving direct cloud uploads, standardized data formats, specialized algorithms, and event-driven processing.

Security and multi-tenancy are integrated throughout the design, ensuring data isolation and controlled access. The proposed technology stack (GoLang, React/Next.js, PostgreSQL, Redis, Kubernetes, S3, GraphQL) offers a balance of performance, developer productivity, and scalability.

Successful implementation will depend on careful execution, particularly in the development of the Timeline Service and the Media Processing Pipeline (especially the diff/merge engine), along with robust testing and monitoring. This architecture provides a solid blueprint for building a powerful and differentiated platform in the video collaboration market.

---

*(End of Document)*

