# CineGit - Technical Backlog

**Version:** 0.1
**Date:** May 4, 2025

This document contains the technical backlog for the CineGit project, derived from the project description and the system architecture document. It is organized into Epics and User Stories with Acceptance Criteria.

---

## Epics

Epics represent large bodies of work that can be broken down into smaller, manageable User Stories. They align with major features or architectural components.

1.  **EPIC-AUTH: User Authentication & Authorization**
    *   *Description:* Implement user registration, login, session management, password handling, OAuth integration, and Role-Based Access Control (RBAC) for organizations and projects.
2.  **EPIC-PROJECT: Project & Workspace Management**
    *   *Description:* Allow users to create, manage, and organize projects within their organization/tenant. Handle project membership and basic settings.
3.  **EPIC-ASSET: Asset Management & Upload**
    *   *Description:* Implement functionality for uploading, storing, retrieving metadata, and managing media assets (video, audio, images) within projects. Includes handling large file uploads.
4.  **EPIC-MEDIA-PROC: Media Processing Pipeline**
    *   *Description:* Develop the asynchronous pipeline for processing uploaded assets, including transcoding (proxy generation), thumbnail extraction, and metadata analysis.
5.  **EPIC-TIMELINE: Timeline Core & Data Model**
    *   *Description:* Define and implement the core data structures and APIs for representing non-linear editing timelines, including clips, tracks, transitions, and references to assets.
6.  **EPIC-VERSIONING: Timeline Versioning & Branching**
    *   *Description:* Implement the Git-style versioning system for timelines, allowing users to create branches, commit changes (creating new timeline versions), and view history.
7.  **EPIC-DIFF: Timeline Diff Engine & Viewer**
    *   *Description:* Develop the engine to compare two timeline versions and identify differences (insertions, deletions, modifications, moves). Implement a visual representation of these diffs in the frontend.
8.  **EPIC-CUTREQ: Cut Request & Merge Workflow**
    *   *Description:* Implement the workflow for proposing (Cut Request), reviewing, and merging timeline changes between branches, including conflict detection.
9.  **EPIC-REVIEW: Review & Commenting System**
    *   *Description:* Implement frame-accurate commenting, annotations, replies, and status tracking for reviewing timelines and assets. Includes real-time updates.
10. **EPIC-NOTIFY: Notification System**
    *   *Description:* Develop the service responsible for sending notifications (in-app, email, webhooks) based on system events.
11. **EPIC-BILLING: Billing & Subscription Management**
    *   *Description:* Integrate with Stripe to handle subscription plans, usage tracking, and payment processing.
12. **EPIC-INFRA: Infrastructure & Deployment**
    *   *Description:* Set up the cloud infrastructure (Kubernetes, databases, storage, networking), CI/CD pipelines, monitoring, and logging.
13. **EPIC-FRONTEND: Core Frontend Application**
    *   *Description:* Develop the main React/Next.js web application shell, navigation, user settings, and basic UI components.
14. **EPIC-API: API Gateway & Integrations**
    *   *Description:* Implement the GraphQL API Gateway and define the external API for third-party integrations (including NLE plugins).
15. **EPIC-NLE: NLE Plugin Integration (Post-MVP)**
    *   *Description:* Develop plugins for Adobe Premiere Pro, DaVinci Resolve, and FCPX to integrate CineGit workflows directly into the editing software.

---

## User Stories

*(User stories will be detailed under each Epic in subsequent steps)*



### EPIC-AUTH: User Authentication & Authorization

**User Stories:**

*   **AUTH-001: User Registration (Email/Password)**
    *   **As a** new user,
    *   **I want to** register for an account using my email address and a password,
    *   **so that** I can access the CineGit platform.
    *   **Acceptance Criteria:**
        *   User provides email and password.
        *   Password meets complexity requirements (e.g., min length, character types).
        *   Email uniqueness is checked.
        *   A new user account and a default organization/tenant are created.
        *   User receives a confirmation email (optional for MVP, but recommended).
        *   User is logged in upon successful registration or redirected to login.

*   **AUTH-002: User Login (Email/Password)**
    *   **As a** registered user,
    *   **I want to** log in using my email and password,
    *   **so that** I can access my projects and data.
    *   **Acceptance Criteria:**
        *   User provides email and password.
        *   Credentials are validated against stored hashes.
        *   On success, a session (e.g., JWT) is created and returned to the client.
        *   On failure, an appropriate error message is shown.
        *   Account locking mechanism after multiple failed attempts is considered.

*   **AUTH-003: User Logout**
    *   **As a** logged-in user,
    *   **I want to** log out of my account,
    *   **so that** my session is securely terminated.
    *   **Acceptance Criteria:**
        *   Client-side session/token is cleared.
        *   Server-side session/token is invalidated (if applicable, e.g., via blacklist for JWTs).
        *   User is redirected to the login page.

*   **AUTH-004: Password Reset**
    *   **As a** user who forgot their password,
    *   **I want to** request a password reset link via email,
    *   **so that** I can regain access to my account.
    *   **Acceptance Criteria:**
        *   User provides their registered email address.
        *   If the email exists, a unique, time-limited reset token is generated and sent via email.
        *   User clicks the link, is taken to a reset form.
        *   User enters and confirms a new password.
        *   Password is updated, token is invalidated.

*   **AUTH-005: Basic Role-Based Access Control (RBAC) - Org Level**
    *   **As an** organization administrator,
    *   **I want to** assign basic roles (e.g., Admin, Member) to users within my organization,
    *   **so that** I can control their high-level permissions.
    *   **Acceptance Criteria:**
        *   Define initial roles (Admin, Member) with basic permission sets.
        *   Implement mechanism to assign roles to users within an organization (via Membership table).
        *   Auth Service can provide user roles upon authentication.
        *   API Gateway/Services can check for basic organization-level roles.

*   **AUTH-006: JWT Issuance and Validation**
    *   **As a** backend service,
    *   **I need** the Auth Service to issue secure JWTs upon successful login,
    *   **so that** user identity and basic roles/tenant info can be passed and validated.
    *   **Acceptance Criteria:**
        *   JWTs contain standard claims (iss, sub, aud, exp, iat) plus custom claims (user_id, tenant_id, roles).
        *   JWTs are signed using a secure algorithm (e.g., RS256) with proper key management.
        *   API Gateway and microservices can validate incoming JWTs.

---



### EPIC-PROJECT: Project & Workspace Management

**User Stories:**

*   **PROJ-001: Create New Project**
    *   **As a** logged-in user (Member or Admin),
    *   **I want to** create a new project within my organization,
    *   **so that** I can start organizing assets and timelines for a specific production.
    *   **Acceptance Criteria:**
        *   User provides a project name and optional description.
        *   A new project record is created in the database, associated with the user's organization/tenant.
        *   The creating user is automatically added as a Project Member (e.g., with an 'Owner' or 'Admin' role for the project).
        *   The user is redirected to the newly created project's dashboard/overview page.

*   **PROJ-002: View Project List**
    *   **As a** logged-in user,
    *   **I want to** see a list of all projects I have access to within my current organization,
    *   **so that** I can navigate between different productions.
    *   **Acceptance Criteria:**
        *   The dashboard or a dedicated projects page displays a list of projects.
        *   Each list item shows the project name and potentially other metadata (e.g., last updated date, number of members).
        *   The list is filtered based on the user's memberships and the current organization context.
        *   Projects are clickable, leading to the project's detail page.

*   **PROJ-003: View Project Details**
    *   **As a** project member,
    *   **I want to** view the main dashboard or details page for a specific project,
    *   **so that** I can see its assets, timelines, branches, and activity.
    *   **Acceptance Criteria:**
        *   Displays project name and description.
        *   Provides navigation to different sections (Assets, Timelines, Branches, Settings, etc.).
        *   May show recent activity or key metrics.

*   **PROJ-004: Invite User to Project**
    *   **As a** project administrator,
    *   **I want to** invite other users (by email) to join a specific project,
    *   **so that** we can collaborate.
    *   **Acceptance Criteria:**
        *   Admin enters the email address of the user to invite.
        *   Admin selects a project-specific role for the invitee (e.g., Editor, Viewer).
        *   If the invited user exists in the system, a project membership invitation is created.
        *   If the invited user does not exist, an invitation email is sent prompting them to sign up.
        *   The invited user receives a notification (in-app or email).
        *   A pending invitation status is visible to project admins.

*   **PROJ-005: Accept/Decline Project Invitation**
    *   **As an** invited user,
    *   **I want to** accept or decline an invitation to join a project,
    *   **so that** I can control which projects I participate in.
    *   **Acceptance Criteria:**
        *   User sees pending invitations in their dashboard or via notification.
        *   User can click "Accept" or "Decline".
        *   Accepting creates a `project_members` record with the assigned role.
        *   Declining updates the invitation status.
        *   The inviting admin is notified of the outcome.

*   **PROJ-006: Manage Project Members & Roles**
    *   **As a** project administrator,
    *   **I want to** view the list of members in a project and change their roles or remove them,
    *   **so that** I can manage access control for the project.
    *   **Acceptance Criteria:**
        *   A settings page lists all project members and their roles.
        *   Admin can select a member and change their assigned project role.
        *   Admin can select a member and remove them from the project.
        *   Users cannot remove themselves if they are the sole administrator (or owner).

*   **PROJ-007: Basic Project Settings**
    *   **As a** project administrator,
    *   **I want to** update the project name and description,
    *   **so that** the project information is accurate.
    *   **Acceptance Criteria:**
        *   Project settings page allows editing name and description.
        *   Changes are saved to the database.

---



### EPIC-ASSET: Asset Management & Upload

**User Stories:**

*   **ASSET-001: Initiate Asset Upload**
    *   **As a** project member with upload permissions,
    *   **I want to** select one or more media files (video, audio, image) from my local machine to upload to a project,
    *   **so that** I can add them to the project repository.
    *   **Acceptance Criteria:**
        *   UI provides a button or drag-and-drop area to select files.
        *   Client validates basic file type/size constraints (if any defined client-side).
        *   For each selected file, a request is sent to the backend to initiate the upload process (requesting a pre-signed URL).
        *   UI shows an indicator that the upload process is starting for each file.

*   **ASSET-002: Upload Large File via Pre-signed URL**
    *   **As a** client application (Web/Plugin),
    *   **I want to** receive a pre-signed URL from the Asset Service and use it to upload a large file directly to Object Storage (S3/GCS) using multipart upload,
    *   **so that** the upload is efficient, reliable, and doesn't overload the backend services.
    *   **Acceptance Criteria:**
        *   Client receives a pre-signed URL and asset ID from the backend.
        *   Client chunks the file and uploads parts using the S3 multipart upload API (or equivalent).
        *   Client displays upload progress to the user.
        *   Client handles potential upload errors and retries.
        *   Client notifies the backend (or S3 triggers notification) upon successful completion or failure.
        *   Upload supports files >20GB.

*   **ASSET-003: View Project Assets**
    *   **As a** project member,
    *   **I want to** view a list or grid of assets uploaded to the project,
    *   **so that** I can see the available media.
    *   **Acceptance Criteria:**
        *   An "Assets" section in the project displays uploaded files.
        *   Each asset shows a thumbnail (once generated), filename, type, and status (e.g., Processing, Available).
        *   Basic filtering or sorting options are available (e.g., by name, date, type).
        *   Clicking an asset opens a detail view or player.

*   **ASSET-004: View Asset Details**
    *   **As a** project member,
    *   **I want to** view detailed information about a specific asset,
    *   **so that** I can understand its properties and status.
    *   **Acceptance Criteria:**
        *   Displays a larger preview/thumbnail.
        *   Shows metadata: filename, type, size, duration, resolution, upload date, uploader.
        *   Shows processing status (original, proxy status, thumbnail status).
        *   Provides options for download (if permitted).
        *   Provides navigation to associated comments/reviews.

*   **ASSET-005: Update Asset Metadata (Basic)**
    *   **As a** project member with edit permissions,
    *   **I want to** rename an asset within CineGit,
    *   **so that** I can organize assets more effectively.
    *   **Acceptance Criteria:**
        *   User can edit the asset name in the UI.
        *   The change is saved to the asset record in the database.
        *   The original filename in storage remains unchanged (only the display name/metadata is updated).

*   **ASSET-006: Delete Asset**
    *   **As a** project member with delete permissions,
    *   **I want to** delete an asset from a project,
    *   **so that** I can remove unnecessary files.
    *   **Acceptance Criteria:**
        *   User confirms the deletion action.
        *   The asset record is marked as deleted or removed from the database.
        *   The corresponding files in Object Storage (original, proxies, thumbnails) are scheduled for deletion (or deleted immediately, considering potential use in old timeline versions - soft delete might be safer initially).
        *   Deletion considers dependencies (e.g., usage in timelines) - potentially prevent deletion if actively used or warn user.

---



### EPIC-MEDIA-PROC: Media Processing Pipeline

**User Stories:**

*   **MPROC-001: Trigger Processing on Upload Completion**
    *   **As the** system,
    *   **I want to** automatically trigger the media processing pipeline when an asset upload to Object Storage is successfully completed,
    *   **so that** proxies, thumbnails, and metadata extraction can begin without manual intervention.
    *   **Acceptance Criteria:**
        *   Object Storage event notifications (e.g., S3 Event Notifications) are configured to publish to the Event Bus (e.g., SQS/SNS/EventBridge).
        *   A listener/consumer (part of Asset Service or a dedicated trigger function) subscribes to these upload completion events.
        *   Upon receiving an event, the listener updates the asset status to "processing" in the database.
        *   The listener publishes specific processing job requests (e.g., `generate_proxy`, `generate_thumbnail`, `extract_metadata`) to relevant queues or topics on the Event Bus for the pipeline workers.

*   **MPROC-002: Generate Proxy Video**
    *   **As a** media processing worker,
    *   **I want to** consume a `generate_proxy` job request containing an asset ID and its storage location,
    *   **so that** I can create a low-resolution web-playable version of the video asset using FFmpeg.
    *   **Acceptance Criteria:**
        *   Worker retrieves the original asset from Object Storage.
        *   Worker runs an optimized FFmpeg command to generate a proxy (e.g., H.264 MP4, specific resolution like 720p).
        *   The generated proxy file is uploaded to a designated location in Object Storage (e.g., `/proxies/` path).
        *   The job completes within the target time frame (e.g., <60 seconds for typical inputs, needs benchmarking).
        *   On success, a `proxy_generation_complete` event is published to the Event Bus with the proxy file location.
        *   On failure, a `processing_failed` event is published with error details.

*   **MPROC-003: Generate Thumbnail**
    *   **As a** media processing worker,
    *   **I want to** consume a `generate_thumbnail` job request containing an asset ID and its storage location,
    *   **so that** I can create a representative image preview of the video or image asset using FFmpeg.
    *   **Acceptance Criteria:**
        *   Worker retrieves the original asset (or proxy if sufficient) from Object Storage.
        *   Worker runs an FFmpeg command to extract a frame (e.g., from the middle or a specified point) as an image (e.g., JPG/PNG).
        *   The generated thumbnail file is uploaded to a designated location in Object Storage (e.g., `/thumbnails/` path).
        *   On success, a `thumbnail_generation_complete` event is published to the Event Bus with the thumbnail file location.
        *   On failure, a `processing_failed` event is published.

*   **MPROC-004: Extract Technical Metadata**
    *   **As a** media processing worker,
    *   **I want to** consume an `extract_metadata` job request containing an asset ID and its storage location,
    *   **so that** I can read technical details (codec, resolution, duration, frame rate, etc.) from the media file using tools like `ffprobe`.
    *   **Acceptance Criteria:**
        *   Worker retrieves the original asset from Object Storage.
        *   Worker runs `ffprobe` (or similar library) to extract metadata.
        *   Extracted metadata is parsed into a structured format (JSON).
        *   On success, a `metadata_extraction_complete` event is published to the Event Bus with the extracted metadata.
        *   On failure, a `processing_failed` event is published.

*   **MPROC-005: Update Asset Record on Processing Completion**
    *   **As the** Asset Service,
    *   **I want to** consume `proxy_generation_complete`, `thumbnail_generation_complete`, and `metadata_extraction_complete` events,
    *   **so that** I can update the corresponding asset record in the database with proxy/thumbnail locations, extracted metadata, and set the status to "available".
    *   **Acceptance Criteria:**
        *   Asset Service subscribes to relevant completion events on the Event Bus.
        *   Upon receiving an event, the service updates the correct asset record in PostgreSQL.
        *   If all required processing steps for an asset are complete, the asset status is updated to "available".

*   **MPROC-006: Handle Processing Failures**
    *   **As the** system,
    *   **I want to** gracefully handle failures during media processing,
    *   **so that** issues can be logged, potentially retried, and users can be informed.
    *   **Acceptance Criteria:**
        *   Processing workers publish `processing_failed` events upon encountering errors.
        *   Asset Service consumes failure events and updates the asset status to "error" in the database, storing error details.
        *   Implement a retry mechanism (e.g., using dead-letter queues and exponential backoff) for transient failures.
        *   Notification Service consumes failure events (after retries exhausted) to inform the uploader or project admins.
        *   Monitoring system tracks processing failure rates.

---



### EPIC-TIMELINE: Timeline Core & Data Model

**User Stories:**

*   **TL-001: Define Standardized Timeline JSON Format**
    *   **As a** developer team,
    *   **We need to** define and document a standardized JSON format for representing timeline data (inspired by OTIO or similar),
    *   **so that** we have a consistent structure for storing, processing, diffing, and rendering timelines across different services and clients.
    *   **Acceptance Criteria:**
        *   JSON schema is defined, covering tracks (video, audio), clips (with asset references, in/out points, source ranges), transitions, basic effects/filters (as placeholders initially), markers, and overall timeline metadata (resolution, frame rate).
        *   Schema includes stable identifiers for clips/elements where feasible to aid diffing.
        *   Schema is documented clearly.
        *   Initial validation scripts or libraries are created.

*   **TL-002: Create Initial Timeline Version on Project Creation**
    *   **As the** system,
    *   **I want to** automatically create an initial, empty timeline version and a default branch (e.g., "main") when a new project is created,
    *   **so that** users have a starting point for adding assets and edits.
    *   **Acceptance Criteria:**
        *   When Project Service creates a project, it triggers the Timeline Service.
        *   Timeline Service creates a `branches` record named "main" for the project.
        *   Timeline Service creates an initial `timeline_versions` record linked to the "main" branch, containing an empty timeline structure according to the defined JSON format.
        *   The `head_timeline_version_id` on the "main" branch points to this initial version.

*   **TL-003: API Endpoint to Get Timeline Version Data**
    *   **As a** frontend client or NLE plugin,
    *   **I want to** request the JSON data for a specific timeline version (by version ID or branch name/head),
    *   **so that** I can display or interpret the timeline structure.
    *   **Acceptance Criteria:**
        *   API Gateway exposes a GraphQL query/mutation (or REST endpoint) to fetch timeline data.
        *   Request includes project ID and timeline version ID (or branch ID).
        *   Timeline Service retrieves the corresponding `timeline_data` (JSON) from PostgreSQL.
        *   Appropriate authorization checks are performed (user must be project member).
        *   Timeline JSON data is returned to the client.

*   **TL-004: Basic Timeline Viewer (Read-Only)**
    *   **As a** frontend developer,
    *   **I want to** implement a basic, read-only timeline viewer component in the web client,
    *   **so that** users can visualize the structure of a timeline version fetched from the API.
    *   **Acceptance Criteria:**
        *   Component accepts timeline JSON data as input.
        *   Displays tracks and clips visually.
        *   Shows clip thumbnails (if available) and names.
        *   Represents basic timing and layering.
        *   Does not need to support playback or editing initially.

*   **TL-005: Associate Assets with Timeline Clips**
    *   **As a** backend developer (Timeline Service),
    *   **I need to** ensure the timeline JSON format and database schema correctly reference assets managed by the Asset Service,
    *   **so that** timelines can accurately represent which media files are used in edits.
    *   **Acceptance Criteria:**
        *   Timeline JSON format includes a clear way to reference assets (e.g., by `asset_id`).
        *   Clip objects within the JSON specify the `asset_id` and potentially source time ranges.
        *   Database schema supports linking `timeline_versions` to `assets` (e.g., via the JSON data or a separate join table if needed for complex queries).

---



### EPIC-VERSIONING: Timeline Versioning & Branching

**User Stories:**

*   **VER-001: Create New Branch from Existing Branch**
    *   **As a** project member with edit permissions,
    *   **I want to** create a new branch based on the current state of an existing branch (e.g., "main"),
    *   **so that** I can experiment with edits without affecting the original timeline.
    *   **Acceptance Criteria:**
        *   UI provides an option to create a branch from a selected branch.
        *   User provides a name for the new branch.
        *   API request is sent to the Timeline Service.
        *   Timeline Service creates a new `branches` record, linking it to the source branch's current `head_timeline_version_id` as its starting point (or copying the version data).
        *   The new branch appears in the list of branches for the project.

*   **VER-002: Switch Between Branches**
    *   **As a** project member,
    *   **I want to** easily switch the timeline view to display the content of a different branch,
    *   **so that** I can view or work on different versions of the edit.
    *   **Acceptance Criteria:**
        *   UI provides a dropdown or list to select the active branch for viewing/editing.
        *   Selecting a branch fetches and displays the `head_timeline_version_id` for that branch in the timeline viewer.

*   **VER-003: Commit Timeline Changes (Save New Version)**
    *   **As a** project member with edit permissions,
    *   **I want to** save my changes to the current branch's timeline with a descriptive commit message,
    *   **so that** a new version is created, preserving the history of edits.
    *   **Acceptance Criteria:**
        *   UI provides a "Save" or "Commit" action when changes are made to the timeline.
        *   User provides a commit message.
        *   Client sends the updated timeline JSON data and commit message to the Timeline Service API.
        *   Timeline Service creates a new `timeline_versions` record linked to the current branch.
        *   The new version's `parent_version_id` points to the previous head of the branch.
        *   The `head_timeline_version_id` for the current branch is updated to point to the new version.
        *   The commit appears in the branch history.

*   **VER-004: View Branch History (Commit Log)**
    *   **As a** project member,
    *   **I want to** view the history of commits (timeline versions) for a specific branch,
    *   **so that** I can understand the evolution of the edit on that branch.
    *   **Acceptance Criteria:**
        *   UI displays a list of commits for the selected branch in reverse chronological order.
        *   Each entry shows the commit message, author, and timestamp.
        *   Selecting a commit allows viewing the timeline state at that specific version (read-only).

*   **VER-005: View List of Branches**
    *   **As a** project member,
    *   **I want to** see a list of all available branches within the project,
    *   **so that** I know what lines of development exist.
    *   **Acceptance Criteria:**
        *   A dedicated "Branches" section or dropdown lists all branches.
        *   Indicates the currently active branch.
        *   May show the last commit date/author for each branch.

---



### EPIC-DIFF: Timeline Diff Engine & Viewer

**User Stories:**

*   **DIFF-001: Develop Timeline Diff Algorithm**
    *   **As a** backend developer (Timeline Service / Media Processing),
    *   **I need to** implement an algorithm that compares two timeline JSON structures (based on the defined standard format) and identifies differences,
    *   **so that** the system can determine what changed between two versions (e.g., for Cut Requests or visual comparison).
    *   **Acceptance Criteria:**
        *   Algorithm correctly identifies added, deleted, and modified clips/elements.
        *   Algorithm identifies changes in clip properties (e.g., in/out points, source asset, position on track).
        *   Algorithm identifies moved clips (within track or between tracks).
        *   Algorithm handles comparison based on common ancestor (for 3-way diff context, needed for merges).
        *   Output format for the diff is defined (e.g., a JSON structure highlighting changes).
        *   Initial implementation focuses on core clip changes; effects/transitions diffing might be deferred.
        *   Performance is benchmarked against requirements (<2s for 500+ edits target).

*   **DIFF-002: API Endpoint for Timeline Diff**
    *   **As a** frontend client,
    *   **I want to** request a comparison (diff) between two specified timeline versions (e.g., two branch heads, or a branch head and its parent),
    *   **so that** I can retrieve the data needed to visualize the changes.
    *   **Acceptance Criteria:**
        *   API Gateway exposes a GraphQL query/mutation (or REST endpoint) to request a diff.
        *   Request includes project ID and identifiers for the two timeline versions to compare (e.g., version IDs or branch names).
        *   Timeline Service orchestrates the diff calculation (potentially calling the diff engine asynchronously via the Event Bus/Media Pipeline if complex).
        *   Appropriate authorization checks are performed.
        *   The diff result (in the defined JSON format) is returned to the client.

*   **DIFF-003: Develop Visual Timeline Diff Viewer Component**
    *   **As a** frontend developer,
    *   **I want to** create a UI component that takes the diff result data from the API and visually represents the changes between two timelines,
    *   **so that** users can easily understand what has been added, removed, or modified.
    *   **Acceptance Criteria:**
        *   Component displays the two timelines (or a combined view) side-by-side or overlaid.
        *   Clearly highlights added clips (e.g., green outline/background).
        *   Clearly highlights deleted clips (e.g., red outline/strikethrough).
        *   Clearly highlights modified clips (e.g., yellow outline/indicator), potentially showing specific changed properties on hover/click.
        *   Visually indicates moved clips.
        *   Component integrates with the timeline viewer (TL-004).

*   **DIFF-004: Integrate Diff View into Cut Request**
    *   **As a** user reviewing a Cut Request,
    *   **I want to** see a visual diff of the changes proposed in the Cut Request,
    *   **so that** I can easily evaluate the proposed merge.
    *   **Acceptance Criteria:**
        *   The Cut Request page includes a tab or section displaying the visual timeline diff (DIFF-003).
        *   The diff is automatically calculated between the source branch head and the target branch head (or common ancestor).

---



### EPIC-CUTREQ: Cut Request & Merge Workflow

**User Stories:**

*   **CR-001: Create Cut Request**
    *   **As a** project member with edit permissions,
    *   **I want to** create a Cut Request to propose merging changes from my feature branch into a target branch (e.g., "main"),
    *   **so that** my changes can be reviewed and integrated.
    *   **Acceptance Criteria:**
        *   UI allows selecting source and target branches within a project.
        *   User provides a title and description for the Cut Request.
        *   API request sent to Timeline Service.
        *   Timeline Service creates a `cut_requests` record in the database with status "open".
        *   An event `cut_request_created` is published.
        *   User is redirected to the newly created Cut Request page.
        *   Initial diff calculation may be triggered (see DIFF-004).

*   **CR-002: List Cut Requests**
    *   **As a** project member,
    *   **I want to** view a list of open and closed Cut Requests for a project,
    *   **so that** I can track the status of proposed changes.
    *   **Acceptance Criteria:**
        *   A dedicated "Cut Requests" section lists requests.
        *   Each entry shows title, source/target branches, author, status (Open, Merged, Closed, Conflicted), and creation date.
        *   Filtering options (e.g., by status, author) are available.
        *   Clicking an entry navigates to the Cut Request detail view.

*   **CR-003: View Cut Request Details**
    *   **As a** project member,
    *   **I want to** view the details of a specific Cut Request,
    *   **so that** I can understand the proposed changes and discussion.
    *   **Acceptance Criteria:**
        *   Displays title, description, author, status, source/target branches.
        *   Includes a tab/section for the visual timeline diff (integrates DIFF-004).
        *   Includes a section for comments and review discussion (integrates with Review Service).
        *   Shows commit history related to the source branch since divergence (optional).
        *   Displays merge status (e.g., "Ready to merge", "Conflicts detected", "Merged", "Closed").

*   **CR-004: Comment on Cut Request**
    *   **As a** project member,
    *   **I want to** add comments to a Cut Request discussion thread,
    *   **so that** I can provide feedback or ask questions about the proposed changes.
    *   **Acceptance Criteria:**
        *   UI provides a text area to add comments on the Cut Request page.
        *   Comments are associated with the Cut Request (potentially via Review Service, linking comments to the CR entity).
        *   Comments support basic formatting and user mentions.
        *   New comments trigger notifications to relevant parties (author, reviewers).

*   **CR-005: Approve/Request Changes on Cut Request**
    *   **As a** designated reviewer or project admin,
    *   **I want to** formally approve a Cut Request or request changes,
    *   **so that** the status of the review is clear.
    *   **Acceptance Criteria:**
        *   UI provides buttons/options for "Approve" and "Request Changes".
        *   Actions update the status or metadata associated with the Cut Request review.
        *   Approvals might be required from a certain number of reviewers before merging is allowed (configurable setting - future).
        *   Actions trigger notifications.

*   **CR-006: Merge Approved Cut Request (No Conflicts)**
    *   **As a** project member with merge permissions,
    *   **I want to** merge an approved Cut Request when there are no conflicts,
    *   **so that** the changes from the source branch are integrated into the target branch.
    *   **Acceptance Criteria:**
        *   UI provides a "Merge" button, enabled only if the CR is approved and conflict-free.
        *   API request sent to Timeline Service.
        *   Timeline Service performs the 3-way merge logic (using the diff engine).
        *   A new merge commit (timeline version) is created on the *target* branch, referencing both parent versions (target head and source head).
        *   The `head_timeline_version_id` of the target branch is updated.
        *   The Cut Request status is updated to "Merged".
        *   An event `cut_request_merged` is published.
        *   Optionally, the source branch can be automatically deleted after merge.

*   **CR-007: Detect and Display Merge Conflicts**
    *   **As the** system (Timeline Service / Diff Engine),
    *   **I want to** detect conflicts during a merge attempt (when changes in both source and target branches affect the same part of the timeline relative to the common ancestor),
    *   **so that** incompatible changes are not automatically merged.
    *   **Acceptance Criteria:**
        *   The merge logic identifies conflicting changes.
        *   If conflicts are detected, the merge process is halted.
        *   The Cut Request status is updated to "Conflicted".
        *   Conflict details are stored and made available via the API.
        *   UI on the Cut Request page indicates that there are conflicts and ideally highlights the conflicting sections/clips (requires advanced UI support).

*   **CR-008: Close Cut Request**
    *   **As a** project member with appropriate permissions (author or admin),
    *   **I want to** close a Cut Request without merging it,
    *   **so that** I can abandon the proposed changes.
    *   **Acceptance Criteria:**
        *   UI provides a "Close" button.
        *   API request sent to Timeline Service.
        *   Cut Request status is updated to "Closed".
        *   An event `cut_request_closed` is published.

---



### EPIC-REVIEW: Review & Commenting System

**User Stories:**

*   **REV-001: Add Frame-Accurate Comment to Timeline/Asset**
    *   **As a** project member,
    *   **I want to** add a text comment at a specific frame or timecode on a timeline version or asset preview,
    *   **so that** I can provide precise feedback.
    *   **Acceptance Criteria:**
        *   UI allows clicking on a specific frame/timecode in the viewer.
        *   A comment input box appears.
        *   User enters text comment.
        *   API request sent to Review Service with comment text, timeline/asset ID, version ID (if applicable), and precise timecode/frame number.
        *   Review Service saves the comment to the database, linked to the correct entity and timecode.
        *   The comment appears visually on the timeline/viewer at the specified point.
        *   A `comment_added` event is published.

*   **REV-002: View Comments on Timeline/Asset**
    *   **As a** project member,
    *   **I want to** see existing comments displayed as markers on the timeline/asset viewer and in a list,
    *   **so that** I can review the feedback provided.
    *   **Acceptance Criteria:**
        *   API provides comments associated with a specific timeline version or asset.
        *   UI displays markers on the viewer at the timecodes where comments exist.
        *   Clicking a marker highlights the comment in a separate list/panel.
        *   The comment list displays comment text, author, timestamp, and timecode.
        *   Comments in the list are ordered by timecode.

*   **REV-003: Reply to Comment**
    *   **As a** project member,
    *   **I want to** reply to an existing comment,
    *   **so that** I can create a discussion thread around specific feedback.
    *   **Acceptance Criteria:**
        *   UI provides a "Reply" option on existing comments.
        *   Reply is saved as a new comment record with a `parent_comment_id` linking it to the original comment.
        *   Replies are displayed nested under the parent comment in the UI.
        *   Replying triggers a `comment_added` event and notifications.

*   **REV-004: Resolve/Unresolve Comment Thread**
    *   **As a** project member (potentially with specific permissions),
    *   **I want to** mark a comment thread (a comment and its replies) as resolved or unresolved,
    *   **so that** we can track the status of feedback items.
    *   **Acceptance Criteria:**
        *   UI provides a "Resolve" / "Unresolve" button/checkbox on comment threads.
        *   Action updates a status field on the parent comment record in the database.
        *   Resolved comments might be visually distinct or filtered out by default in the UI.
        *   Changing resolution status triggers an event and potentially notifications.

*   **REV-005: Real-time Comment Updates**
    *   **As a** user viewing a timeline or asset,
    *   **I want to** see new comments appear in real-time without needing to refresh the page,
    *   **so that** collaboration feels immediate.
    *   **Acceptance Criteria:**
        *   Frontend establishes a WebSocket connection for the current project/timeline view.
        *   Backend WebSocket service subscribes to `comment_added` events from the Event Bus for relevant contexts.
        *   When a new comment event is received, the WebSocket service pushes the comment data to connected clients viewing the same timeline/asset.
        *   Frontend receives the push message and dynamically adds the new comment to the viewer and list.

*   **REV-006: Basic Comment Filtering**
    *   **As a** project member,
    *   **I want to** filter the displayed comments (e.g., show only unresolved, show only mine),
    *   **so that** I can focus on relevant feedback.
    *   **Acceptance Criteria:**
        *   UI provides basic filter options (e.g., by status, by author).
        *   Selecting a filter updates the displayed comment list and potentially the markers on the viewer.
        *   Filtering is performed client-side or via API parameters.

---



### EPIC-NOTIFY: Notification System

**User Stories:**

*   **NOTIFY-001: Subscribe to Relevant Business Events**
    *   **As the** Notification Service,
    *   **I need to** subscribe to relevant events on the Event Bus (e.g., `comment_added`, `cut_request_created`, `cut_request_merged`, `processing_complete`, `processing_failed`, `user_invited_to_project`),
    *   **so that** I can trigger notifications based on system activity.
    *   **Acceptance Criteria:**
        *   Notification Service successfully subscribes to specified event types on the Event Bus (Kafka/EventBridge/etc.).
        *   Events are consumed reliably.

*   **NOTIFY-002: Determine Notification Recipients**
    *   **As the** Notification Service,
    *   **I need to** determine the appropriate recipients for a notification based on the event type and context (e.g., project members, user mentions, specific roles),
    *   **so that** the right users are informed.
    *   **Acceptance Criteria:**
        *   Logic correctly identifies recipients for `comment_added` (e.g., thread participants, mentioned users, project followers).
        *   Logic correctly identifies recipients for `cut_request_created` (e.g., project admins, potential reviewers).
        *   Logic correctly identifies recipients for `user_invited_to_project` (the invited user).
        *   Logic correctly identifies recipients for `processing_complete`/`failed` (the user who uploaded the asset).
        *   User notification preferences are considered (future enhancement, initially notify all relevant parties).

*   **NOTIFY-003: Send Email Notifications**
    *   **As the** Notification Service,
    *   **I want to** format and send email notifications to users based on triggered events,
    *   **so that** users are informed of important activities even when not actively using the platform.
    *   **Acceptance Criteria:**
        *   Integrates with an email sending service (e.g., AWS SES, SendGrid, Mailgun).
        *   Email templates are created for different notification types (e.g., new comment, new cut request).
        *   Emails include relevant context and a link back to the specific item in CineGit.
        *   Emails are sent reliably to the determined recipients.
        *   Unsubscribe mechanism is considered.

*   **NOTIFY-004: Generate In-App Notifications**
    *   **As the** Notification Service,
    *   **I want to** create in-app notification records in the database when events occur,
    *   **so that** users can see a list of relevant updates within the application.
    *   **Acceptance Criteria:**
        *   A `notifications` table exists in PostgreSQL.
        *   Notification Service creates records in this table for relevant events and recipients.
        *   Notification records include type, message, link to related entity, and read status.

*   **NOTIFY-005: API Endpoint for In-App Notifications**
    *   **As a** frontend client,
    *   **I want to** fetch a list of unread and recent in-app notifications for the logged-in user,
    *   **so that** I can display them in the UI.
    *   **Acceptance Criteria:**
        *   API Gateway exposes an endpoint (GraphQL query) to fetch notifications.
        *   Notification Service provides the data, filtered by user ID and potentially read status/timestamp.
        *   Endpoint supports pagination.

*   **NOTIFY-006: Mark In-App Notification as Read**
    *   **As a** frontend client,
    *   **I want to** mark specific in-app notifications as read,
    *   **so that** the user's notification count is updated and the notification is visually distinct.
    *   **Acceptance Criteria:**
        *   API Gateway exposes an endpoint (GraphQL mutation) to mark notifications as read (individually or in bulk).
        *   Notification Service updates the `read_status` in the database.

*   **NOTIFY-007: Basic Webhook Support (Post-MVP/Enterprise)**
    *   **As an** administrator or developer,
    *   **I want to** configure webhooks for specific project events (e.g., cut request merged, asset processing complete),
    *   **so that** I can integrate CineGit with external systems.
    *   **Acceptance Criteria:**
        *   UI allows configuring webhook URLs and selecting event types per project.
        *   Notification Service consumes relevant events and sends POST requests to configured webhook URLs with event payload.
        *   Basic security measures (e.g., secret signature) are included.

---



### EPIC-BILLING: Billing & Subscription Management

**User Stories:**

*   **BILL-001: Define Subscription Plans & Limits**
    *   **As a** product owner,
    *   **I want to** define the different subscription tiers (Freemium, Studio, Per-Project, Enterprise) with their associated features, limits (storage, users, processing), and pricing,
    *   **so that** the billing system can enforce them.
    *   **Acceptance Criteria:**
        *   Plans (Freemium, Studio, etc.) are defined in a configuration file or database table.
        *   Limits for each plan (e.g., storage GB, number of collaborators, projects) are clearly specified.
        *   Features included in each plan are documented.
        *   Pricing information is associated with each paid plan.

*   **BILL-002: Integrate Stripe Customer Creation**
    *   **As the** Billing Service,
    *   **I want to** create a customer record in Stripe when a new organization signs up for a paid plan (or upgrades from free),
    *   **so that** Stripe can manage payment details and subscriptions.
    *   **Acceptance Criteria:**
        *   Billing Service integrates with the Stripe API.
        *   When an organization is created or upgrades, a corresponding Stripe Customer object is created.
        *   The Stripe Customer ID is stored in the `billing_info` table associated with the organization.

*   **BILL-03: Handle Subscription Creation/Upgrade**
    *   **As a** user (Org Admin),
    *   **I want to** select a paid subscription plan and provide payment details,
    *   **so that** I can access the features associated with that plan.
    *   **Acceptance Criteria:**
        *   UI presents available plans and pricing.
        *   User selects a plan.
        *   Frontend integrates with Stripe Elements or Checkout for secure payment information collection.
        *   On successful payment setup, the Billing Service creates a Stripe Subscription linked to the Stripe Customer.
        *   The subscription details (plan ID, status, current period end) are stored in the `billing_info` table.
        *   Organization's plan/limits are updated in the CineGit system.

*   **BILL-004: Handle Subscription Cancellation/Downgrade**
    *   **As a** user (Org Admin),
    *   **I want to** cancel my paid subscription or downgrade to a lower tier (including free),
    *   **so that** I am no longer billed or billed at a lower rate.
    *   **Acceptance Criteria:**
        *   UI provides options to manage subscription.
        *   Billing Service interacts with Stripe API to cancel or modify the subscription (e.g., effective at period end).
        *   `billing_info` table is updated.
        *   Organization's plan/limits are adjusted accordingly (potentially requiring enforcement if downgrading below current usage).

*   **BILL-005: Stripe Webhook Handler for Subscription Events**
    *   **As the** Billing Service,
    *   **I want to** receive and process webhooks from Stripe for subscription events (e.g., `invoice.payment_succeeded`, `invoice.payment_failed`, `customer.subscription.updated`, `customer.subscription.deleted`),
    *   **so that** the application state stays synchronized with the Stripe subscription status.
    *   **Acceptance Criteria:**
        *   A secure webhook endpoint is exposed by the Billing Service.
        *   Endpoint validates webhook signatures.
        *   Handler processes relevant events and updates the `billing_info` table and organization status/limits accordingly.
        *   Failed payments trigger notifications or account state changes (e.g., grace period, suspension).

*   **BILL-006: Basic Usage Tracking (Storage)**
    *   **As the** system,
    *   **I need to** track the total storage used by each organization,
    *   **so that** usage limits for subscription plans can be enforced.
    *   **Acceptance Criteria:**
        *   A mechanism (e.g., periodic background job, updates triggered by Asset Service) calculates and updates the total storage used per organization.
        *   Storage usage is stored (e.g., in the `organizations` or `billing_info` table).
        *   Checks are implemented (e.g., during upload) to prevent exceeding storage limits based on the organization's plan.

*   **(Future) BILL-007: Usage Tracking (Processing Time, Bandwidth)**
    *   **As the** system,
    *   **I need to** track other usage metrics like media processing time or CDN bandwidth per organization,
    *   **so that** these can be used for billing or enforcing limits in higher tiers.
    *   **Acceptance Criteria:**
        *   Media Processing Pipeline logs processing time per job, associated with an organization.
        *   CDN logs are analyzed to attribute bandwidth usage to organizations.
        *   Metrics are aggregated and stored.

---



### EPIC-INFRA: Infrastructure & Deployment

**User Stories:**

*   **INFRA-001: Setup Cloud Provider Account & Basic Networking**
    *   **As an** Ops/Infrastructure Engineer,
    *   **I want to** set up the primary cloud provider account (AWS/GCP/Azure) and configure basic networking (VPC, subnets, security groups),
    *   **so that** we have a secure foundation for deploying resources.
    *   **Acceptance Criteria:**
        *   Cloud account created and secured (MFA, billing alerts).
        *   VPC with public and private subnets across multiple availability zones is configured.
        *   Basic security groups/firewall rules are defined.
        *   Infrastructure is managed using Infrastructure as Code (IaC - Terraform/Pulumi).

*   **INFRA-002: Provision Kubernetes Cluster**
    *   **As an** Ops/Infrastructure Engineer,
    *   **I want to** provision a managed Kubernetes cluster (EKS/GKE/AKS) using IaC,
    *   **so that** we have a platform to deploy and manage our containerized microservices.
    *   **Acceptance Criteria:**
        *   Kubernetes cluster is provisioned with appropriate node pools (potentially different types for general compute vs. media processing).
        *   Cluster networking (e.g., CNI plugin) is configured.
        *   Access controls (RBAC) for the cluster are set up.
        *   Cluster configuration is managed via IaC.

*   **INFRA-003: Provision Managed Database (PostgreSQL)**
    *   **As an** Ops/Infrastructure Engineer,
    *   **I want to** provision a managed PostgreSQL database instance (e.g., AWS RDS, Google Cloud SQL) using IaC,
    *   **so that** microservices have a reliable relational database for metadata storage.
    *   **Acceptance Criteria:**
        *   Database instance is provisioned with appropriate sizing, high availability (multi-AZ), and backup settings.
        *   Network access is restricted to the Kubernetes cluster/VPC.
        *   Credentials are securely managed (e.g., via Secrets Manager).
        *   Database configuration is managed via IaC.

*   **INFRA-004: Provision Managed Cache (Redis)**
    *   **As an** Ops/Infrastructure Engineer,
    *   **I want to** provision a managed Redis instance (e.g., AWS ElastiCache, Google Memorystore) using IaC,
    *   **so that** services have access to a fast in-memory cache.
    *   **Acceptance Criteria:**
        *   Redis instance is provisioned with appropriate sizing and security settings.
        *   Network access is restricted.
        *   Configuration is managed via IaC.

*   **INFRA-005: Provision Object Storage Bucket & CDN**
    *   **As an** Ops/Infrastructure Engineer,
    *   **I want to** provision an Object Storage bucket (S3/GCS) and configure a CDN (CloudFront/Cloudflare) using IaC,
    *   **so that** media assets can be stored securely and delivered efficiently.
    *   **Acceptance Criteria:**
        *   Storage bucket is created with appropriate access policies, versioning, and lifecycle rules.
        *   Event notifications (for uploads) are configured.
        *   CDN distribution is set up, pointing to the bucket as an origin.
        *   CDN caching rules and security settings (e.g., signed URLs/cookies if needed) are configured.
        *   Configuration is managed via IaC.

*   **INFRA-006: Setup CI/CD Pipeline (Initial)**
    *   **As a** Developer/Ops Engineer,
    *   **I want to** set up an initial CI/CD pipeline (e.g., GitHub Actions, GitLab CI) for a sample microservice,
    *   **so that** code changes can be automatically built, tested, containerized, and deployed to the Kubernetes cluster.
    *   **Acceptance Criteria:**
        *   Pipeline triggers on code push to specific branches (e.g., main, develop).
        *   Pipeline runs linters and unit tests.
        *   Pipeline builds a Docker image.
        *   Pipeline pushes the image to a container registry (e.g., ECR, GCR, Docker Hub).
        *   Pipeline deploys the new image to Kubernetes (e.g., using kubectl apply, Helm, or ArgoCD).

*   **INFRA-007: Setup Basic Monitoring & Logging**
    *   **As an** Ops/Infrastructure Engineer,
    *   **I want to** set up basic monitoring (metrics) and logging collection for the Kubernetes cluster and deployed services,
    *   **so that** we can observe system health and troubleshoot issues.
    *   **Acceptance Criteria:**
        *   Metrics collection agent (e.g., Prometheus node-exporter, kube-state-metrics) is deployed to the cluster.
        *   A monitoring server (e.g., Prometheus) scrapes metrics.
        *   A visualization tool (e.g., Grafana) is set up with basic dashboards for cluster/node/pod metrics.
        *   A log aggregation agent (e.g., Fluentd, Loki promtail) is deployed to collect container logs.
        *   A log storage and query system (e.g., Loki, Elasticsearch) is set up.

*   **INFRA-008: Containerize Microservices**
    *   **As a** Developer,
    *   **I need to** create Dockerfiles for each GoLang microservice,
    *   **so that** they can be built into container images for deployment.
    *   **Acceptance Criteria:**
        *   Dockerfile exists for each service (Auth, Project, Timeline, etc.).
        *   Dockerfiles follow best practices (multi-stage builds, non-root users, minimal image size).
        *   Images build successfully locally.

*   **INFRA-009: Create Kubernetes Deployment Manifests**
    *   **As a** Developer/Ops Engineer,
    *   **I need to** create Kubernetes manifest files (Deployments, Services, ConfigMaps, Secrets) for each microservice,
    *   **so that** they can be deployed and managed within the cluster.
    *   **Acceptance Criteria:**
        *   Manifests define desired replicas, resource requests/limits, environment variables, volume mounts, service exposure.
        *   Manifests are parameterized (e.g., using Kustomize or Helm) for different environments (dev, staging, prod).

---



### EPIC-FRONTEND: Core Frontend Application

**User Stories:**

*   **FE-001: Setup Next.js Project Structure**
    *   **As a** frontend developer,
    *   **I want to** set up the initial Next.js project structure using the provided template (or standard `create-next-app`),
    *   **so that** we have a foundation for building the web application UI.
    *   **Acceptance Criteria:**
        *   Next.js project initialized.
        *   Basic folder structure (pages, components, styles, lib) is in place.
        *   Tailwind CSS and UI component library (e.g., shadcn/ui) are configured.
        *   Version control (Git) initialized.

*   **FE-002: Implement Basic Layout and Navigation**
    *   **As a** frontend developer,
    *   **I want to** implement the main application layout (e.g., sidebar, header) and basic navigation between key pages (Login, Dashboard, Projects, Settings),
    *   **so that** users can move between different sections of the application.
    *   **Acceptance Criteria:**
        *   A consistent layout component is created.
        *   Header includes logo, user menu (login/logout state).
        *   Sidebar (if applicable) includes links to main sections.
        *   Routing between pages is functional using Next.js router.
        *   Layout is responsive.

*   **FE-003: Implement Login Page**
    *   **As a** frontend developer,
    *   **I want to** create the login page UI with fields for email and password,
    *   **so that** users can authenticate.
    *   **Acceptance Criteria:**
        *   Login form includes email input, password input, and submit button.
        *   Form integrates with the API Gateway/Auth Service (AUTH-002) for authentication.
        *   Handles loading states and displays error messages on failed login.
        *   Redirects to the dashboard on successful login.
        *   Includes link to registration and password reset pages.

*   **FE-004: Implement Registration Page**
    *   **As a** frontend developer,
    *   **I want to** create the registration page UI with fields for email, password, and password confirmation,
    *   **so that** new users can sign up.
    *   **Acceptance Criteria:**
        *   Registration form includes necessary fields.
        *   Client-side validation for email format and password matching/complexity.
        *   Form integrates with the API Gateway/Auth Service (AUTH-001).
        *   Handles loading states and displays errors.
        *   Redirects to login or dashboard on success.

*   **FE-005: Implement Project List Page**
    *   **As a** frontend developer,
    *   **I want to** create the page displaying the list of projects the user belongs to,
    *   **so that** users can navigate to their projects.
    *   **Acceptance Criteria:**
        *   Page fetches project list data from the API (PROJ-002).
        *   Displays projects in a list or card format.
        *   Includes a button/link to create a new project (PROJ-001).
        *   Handles loading and empty states.

*   **FE-006: Implement Project Dashboard/Overview Page**
    *   **As a** frontend developer,
    *   **I want to** create the main view for a single project,
    *   **so that** users have a central place to access project assets, timelines, and settings.
    *   **Acceptance Criteria:**
        *   Page fetches project details from the API (PROJ-003).
        *   Displays project name and description.
        *   Provides clear navigation to sub-sections (Assets, Timelines, Branches, Members, Settings).
        *   Potentially displays recent activity feed (requires additional API support).

*   **FE-007: Implement Asset Browser View**
    *   **As a** frontend developer,
    *   **I want to** create the UI for browsing project assets,
    *   **so that** users can view and manage uploaded media.
    *   **Acceptance Criteria:**
        *   Fetches asset list from API (ASSET-003).
        *   Displays assets in a grid or list with thumbnails and basic info.
        *   Includes upload functionality (integrates ASSET-001, ASSET-002).
        *   Allows selecting an asset to view details (ASSET-004).
        *   Includes options for filtering/sorting.

*   **FE-008: Implement Basic Timeline Viewer Integration**
    *   **As a** frontend developer,
    *   **I want to** integrate the read-only timeline viewer component (TL-004) into the project view,
    *   **so that** users can see the structure of a selected timeline branch/version.
    *   **Acceptance Criteria:**
        *   A dedicated "Timeline" or "Edit" section exists within a project.
        *   UI allows selecting a branch (VER-002).
        *   Fetches timeline data for the selected branch head from the API (TL-003).
        *   Passes the data to the timeline viewer component for rendering.

*   **FE-009: Implement Comment Display**
    *   **As a** frontend developer,
    *   **I want to** display comments associated with a timeline/asset,
    *   **so that** users can see feedback.
    *   **Acceptance Criteria:**
        *   Fetches comments from the API (REV-002).
        *   Displays comment markers on the timeline viewer.
        *   Displays comments in a list/panel, including replies (REV-003).
        *   Integrates real-time updates via WebSockets (REV-005).
        *   Allows adding new comments (REV-001).

*   **(Repeat for other key UI sections like Branch List, Commit History, Cut Request List/Details, Settings, etc.)**

---



### EPIC-API: API Gateway & Integrations

**User Stories:**

*   **API-001: Implement GraphQL API Gateway**
    *   **As a** backend developer,
    *   **I want to** set up and configure a GraphQL API Gateway (e.g., using Apollo Server or a cloud provider service like AWS AppSync),
    *   **so that** it serves as the single entry point for all client requests (Web, Plugins).
    *   **Acceptance Criteria:**
        *   GraphQL server is running and accessible.
        *   Gateway integrates with the Auth Service for JWT validation on incoming requests.
        *   Basic GraphQL schema is defined (initially can be simple, expanded by other epics).
        *   Gateway is configured to route requests/resolve queries by communicating with the appropriate downstream microservices (e.g., via gRPC, REST, or direct function calls if using a monolith/lambda approach initially).

*   **API-002: Define Core GraphQL Schema (Queries & Mutations)**
    *   **As a** backend developer team,
    *   **We need to** define the GraphQL schema (types, queries, mutations) corresponding to the core functionalities developed in other epics (Auth, Project, Asset, Timeline, Review, etc.),
    *   **so that** clients can interact with the backend services through the gateway.
    *   **Acceptance Criteria:**
        *   Schema includes types for User, Project, Asset, TimelineVersion, Branch, Comment, CutRequest, etc.
        *   Schema includes queries to fetch data (e.g., `projects`, `project(id)`, `timelineVersion(id)`, `assets(projectId)`, `comments(timelineVersionId)`).
        *   Schema includes mutations to perform actions (e.g., `login`, `register`, `createProject`, `uploadAsset`, `createBranch`, `commitTimeline`, `addComment`, `createCutRequest`, `mergeCutRequest`).
        *   Schema definition is iterative and updated as features are implemented.
        *   Authorization logic is integrated into resolvers (checking user roles/permissions before accessing data or performing mutations).

*   **API-003: Implement Real-time Subscriptions (e.g., Comments)**
    *   **As a** backend developer,
    *   **I want to** implement GraphQL subscriptions for real-time events (starting with new comments),
    *   **so that** clients can receive live updates via WebSockets.
    *   **Acceptance Criteria:**
        *   API Gateway supports WebSocket connections for GraphQL subscriptions.
        *   A subscription query (e.g., `commentAdded(timelineVersionId)`) is defined in the schema.
        *   The resolver for the subscription connects to the Event Bus (or Redis Pub/Sub) to listen for relevant events (e.g., `comment_added`).
        *   When an event occurs, the data is pushed to subscribed clients.
        *   Integrates with REV-005.

*   **API-004: Define External REST/GraphQL API for Integrations (Post-MVP)**
    *   **As a** platform provider,
    *   **I want to** define and document a stable public API (potentially a subset of the internal GraphQL API or a dedicated REST API),
    *   **so that** third-party developers and NLE plugins can integrate with CineGit.
    *   **Acceptance Criteria:**
        *   API endpoints/queries/mutations relevant for external use are identified.
        *   Authentication mechanism for third-party applications is defined (e.g., API keys, OAuth client credentials).
        *   API documentation (e.g., using Swagger/OpenAPI for REST or GraphQL introspection/documentation tools) is generated.
        *   Rate limiting and usage policies for the public API are established.

*   **API-005: Implement API Key Management (Post-MVP)**
    *   **As an** organization administrator or developer user,
    *   **I want to** generate and manage API keys for accessing the public CineGit API,
    *   **so that** I can build integrations or automate workflows.
    *   **Acceptance Criteria:**
        *   UI allows generating API keys with specific scopes/permissions.
        *   API keys can be revoked.
        *   Auth Service or API Gateway validates API keys for requests to the public API.

---



### EPIC-NLE: NLE Plugin Integration (Post-MVP)

**User Stories:**

*   **NLE-001: Develop Core Plugin Framework/SDK**
    *   **As a** developer team,
    *   **We need to** develop a core framework or SDK that abstracts common functionalities needed for NLE plugins (authentication, API communication, basic UI elements),
    *   **so that** developing plugins for different NLEs (Premiere, Resolve, FCPX) is more efficient and consistent.
    *   **Acceptance Criteria:**
        *   SDK provides helper functions for authenticating with CineGit API (using OAuth flow or API keys).
        *   SDK provides wrappers for calling key CineGit API endpoints (fetching projects, branches, timelines, assets; creating cut requests; adding comments).
        *   SDK potentially includes common UI components adaptable to different NLE plugin environments.
        *   SDK is documented for internal use.

*   **NLE-002: Premiere Pro Plugin - Authentication & Project Browsing**
    *   **As a** Premiere Pro editor,
    *   **I want to** log into my CineGit account from within a Premiere Pro panel and browse my projects,
    *   **so that** I can access CineGit without leaving my editing software.
    *   **Acceptance Criteria:**
        *   A Premiere Pro panel extension is created.
        *   Panel provides a login interface (potentially opening a browser for OAuth).
        *   Successfully authenticates with CineGit API using the SDK.
        *   Displays a list of the user's CineGit projects.
        *   Allows selecting a project.

*   **NLE-003: Premiere Pro Plugin - Push Timeline to CineGit Branch**
    *   **As a** Premiere Pro editor,
    *   **I want to** push my current active sequence to a selected CineGit branch as a new commit/timeline version,
    *   **so that** I can save my work-in-progress to CineGit.
    *   **Acceptance Criteria:**
        *   Plugin can access the active sequence data in Premiere Pro (e.g., via ExtendScript or native APIs).
        *   Plugin converts the sequence data into the standardized CineGit timeline JSON format.
        *   Plugin allows selecting a target CineGit project and branch.
        *   Plugin allows entering a commit message.
        *   Plugin calls the CineGit API (via SDK) to commit the new timeline version (VER-003).
        *   Handles potential asset mapping/upload if new local assets are used in the sequence (complex, may require separate stories).

*   **NLE-004: Premiere Pro Plugin - Pull Timeline from CineGit Branch**
    *   **As a** Premiere Pro editor,
    *   **I want to** pull the latest timeline version from a CineGit branch and open it as a new sequence in Premiere Pro,
    *   **so that** I can retrieve work done by others or from different machines.
    *   **Acceptance Criteria:**
        *   Plugin allows selecting a CineGit project and branch.
        *   Plugin fetches the latest timeline JSON data from the CineGit API (TL-003).
        *   Plugin converts the CineGit timeline JSON format into a Premiere Pro sequence format (e.g., FCPXML import or direct sequence creation via APIs).
        *   Plugin handles linking to locally available media assets based on metadata (requires robust asset matching logic).
        *   The new sequence is created/opened in Premiere Pro.

*   **NLE-005: Premiere Pro Plugin - View Comments as Markers**
    *   **As a** Premiere Pro editor,
    *   **I want to** see CineGit comments associated with a timeline version displayed as markers on my Premiere Pro sequence,
    *   **so that** I can review feedback directly on my timeline.
    *   **Acceptance Criteria:**
        *   Plugin fetches comments for the current timeline version from the CineGit API (REV-002).
        *   Plugin creates sequence markers in Premiere Pro at the corresponding timecodes.
        *   Marker information includes comment text and author.
        *   Clicking a marker potentially opens the comment thread in the CineGit panel.

*   **(Repeat NLE-002 to NLE-005 for DaVinci Resolve and FCPX, adapting to their specific plugin APIs and formats)**

---



## Prioritized Delivery Roadmap

This roadmap outlines a potential phasing for delivering CineGit, focusing on an MVP that delivers core value quickly, followed by iterative enhancements.

### Minimum Viable Product (MVP) Scope

The MVP focuses on establishing the core version control workflow for individual users or small teams, enabling basic branching, committing, and visual review, without complex merge workflows or advanced collaboration features.

**Core MVP Epics & Key Stories:**

1.  **EPIC-INFRA (Partial):** Basic K8s cluster, DB, Object Storage, CI/CD setup (INFRA-001, 002, 003, 004, 005, 006, 008, 009).
2.  **EPIC-AUTH (Core):** Email/Password Registration & Login (AUTH-001, 002, 003, 006).
3.  **EPIC-PROJECT (Core):** Create/View Projects (PROJ-001, 002, 003).
4.  **EPIC-ASSET (Core):** Asset Upload (direct-to-cloud), Basic Viewing (ASSET-001, 002, 003, 004).
5.  **EPIC-MEDIA-PROC (Core):** Basic Proxy & Thumbnail Generation (MPROC-001, 002, 003, 005, 006).
6.  **EPIC-TIMELINE (Core):** Standard Format, API to Get/Set, Basic Viewer (TL-001, 002, 003, 004, 005).
7.  **EPIC-VERSIONING (Core):** Create Branch, Commit Changes, View History (VER-001, 002, 003, 004, 005).
8.  **EPIC-FRONTEND (Core):** Basic Layout, Login/Register, Project List/Dashboard, Asset Browser, Basic Timeline Viewer (FE-001 to FE-008).
9.  **EPIC-API (Core):** GraphQL Gateway Setup, Core Schema for MVP features (API-001, API-002 partial).

**Explicitly Excluded from MVP:**

*   Timeline Diff Engine & Viewer (EPIC-DIFF)
*   Cut Request & Merge Workflow (EPIC-CUTREQ)
*   Advanced Review/Commenting (Replies, Resolution, Real-time - EPIC-REVIEW partial)
*   Notifications (EPIC-NOTIFY)
*   Billing & Subscriptions (EPIC-BILLING - Assume free tier initially)
*   Advanced Project Management (Invites, Roles - PROJ-004, 005, 006)
*   NLE Plugins (EPIC-NLE)
*   Advanced Infrastructure (Monitoring, IaC completeness - EPIC-INFRA partial)
*   Public API & Integrations (API-004, 005)
*   Password Reset (AUTH-004 - Can be added soon after MVP)

### Development Phases

**Phase 1: Foundation & Core MVP (Months 1-4)**

*   **Goal:** Deliver the MVP features listed above.
*   **Focus:** Infrastructure setup, core backend services (Auth, Project, Asset, Timeline, Versioning), basic media processing, essential frontend UI for core workflow (upload, branch, commit, view).
*   **Key Epics:** EPIC-INFRA (Partial), EPIC-AUTH (Core), EPIC-PROJECT (Core), EPIC-ASSET (Core), EPIC-MEDIA-PROC (Core), EPIC-TIMELINE (Core), EPIC-VERSIONING (Core), EPIC-FRONTEND (Core), EPIC-API (Core).

**Phase 2: Collaboration & Review Features (Months 5-8)**

*   **Goal:** Introduce core collaboration features like diffing, merging, and commenting.
*   **Focus:** Implementing the Timeline Diff Engine, Cut Request workflow (including merge logic and conflict detection), and the Review/Commenting system with real-time updates.
*   **Key Epics:** EPIC-DIFF, EPIC-CUTREQ, EPIC-REVIEW, EPIC-NOTIFY (Basic), EPIC-PROJECT (Invites/Roles), EPIC-FRONTEND (Integrate Diff/CR/Comments), EPIC-API (Subscriptions).

**Phase 3: Monetization & Enterprise Readiness (Months 9-12)**

*   **Goal:** Introduce billing, SSO, and prepare for larger teams/studios.
*   **Focus:** Implementing the Billing system, adding SSO/SAML support to Auth Service, enhancing RBAC, improving monitoring/ops, potentially starting NLE Plugin Alpha.
*   **Key Epics:** EPIC-BILLING, EPIC-AUTH (SSO), EPIC-PROJECT (Advanced Roles), EPIC-INFRA (Monitoring/Ops hardening), EPIC-NLE (Alpha), EPIC-API (Public API definition).

**Phase 4: NLE Integration & Advanced Features (Year 2+)**

*   **Goal:** Deepen NLE integration and explore future directions.
*   **Focus:** Full development of NLE plugins, advanced timeline analytics, render farm integration, public repositories, API monetization.
*   **Key Epics:** EPIC-NLE (Full), Future Directions (AI, Public Repos, etc.).

### Technical Debt & Research Spikes

*   **Timeline Diff/Merge Algorithm:** Requires significant R&D (Research Spike recommended early in Phase 1 or 2) to achieve performance and accuracy goals. Initial merge implementation might handle only simple cases.
*   **Asset Linking in NLE Plugins:** Reliably mapping assets between CineGit and local NLE projects is complex and needs careful design (Potential Debt/Spike during NLE development).
*   **Real-time Scalability:** WebSocket layer needs stress testing and optimization as user base grows.
*   **Infrastructure Cost Optimization:** Initial infra setup prioritizes functionality; cost optimization can be addressed iteratively.
*   **Comprehensive Testing:** Automated testing (unit, integration, E2E) needs continuous investment throughout all phases.

---

*(End of Backlog Document)*

