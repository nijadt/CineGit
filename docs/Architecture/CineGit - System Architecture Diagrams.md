
# CineGit – Architecture Diagrams

Below are the refreshed Mermaid diagrams covering **all** core functionalities:

---

## 1. Class Diagrams

### 1.1 Domain Model

```mermaid
classDiagram
    %% Domain entities and relationships
    class Organization {
        +UUID id
        +String name
        +String subscriptionPlan
        +DateTime createdAt
        +DateTime updatedAt
    }
    class User {
        +UUID id
        +String email
        +String name
        +String role
        +DateTime createdAt
        +DateTime updatedAt
    }
    class Project {
        +UUID id
        +String title
        +String description
        +String visibility
        +DateTime createdAt
        +DateTime updatedAt
    }
    class Branch {
        +UUID id
        +String name
        +UUID parentBranchId
        +DateTime createdAt
        +DateTime updatedAt
    }
    class TimelineVersion {
        +UUID id
        +JSONB timelineJson
        +DateTime createdAt
        +DateTime updatedAt
    }
    class Asset {
        +UUID id
        +String filePath
        +String thumbnailPath
        +String proxyPath
        +JSONB metadata
        +DateTime createdAt
        +DateTime updatedAt
    }
    class CutRequest {
        +UUID id
        +String status
        +String message
        +DateTime createdAt
        +DateTime updatedAt
    }
    class Comment {
        +UUID id
        +Float timestamp
        +String text
        +UUID parentCommentId
        +DateTime createdAt
        +DateTime updatedAt
    }
    class Notification {
        +UUID id
        +String type
        +String message
        +Boolean read
        +DateTime createdAt
    }
    class BillingInfo {
        +UUID organizationId
        +String stripeCustomerId
        +String subscriptionId
        +DateTime periodEnd
    }

    %% Relationships
    Organization "1" -- "0..*" Project         : owns
    Organization "1" -- "0..*" User            : contains
    Organization "1" -- "1" BillingInfo       : billedBy
    User         "1" -- "0..*" ProjectMember  : participates
    Project      "1" -- "0..*" Branch          : has
    Branch       "1" -- "0..*" TimelineVersion : head
    TimelineVersion "1" -- "0..*" Asset        : uses
    TimelineVersion "1" -- "0..*" Comment       : receives
    Asset        "1" -- "0..*" Comment         : annotatedBy
    Branch       "1" -- "0..*" CutRequest      : source,target
    User         "1" -- "0..*" Comment         : author
    User         "1" -- "0..*" Notification    : receives
````

### 1.2 Service Interaction Classes

```mermaid
classDiagram
    %% Core microservices and their methods
    class APIGateway {
        +handleGraphQL(req)
        +handleREST(req)
    }
    class AuthService {
        +login(credentials)
        +register(details)
        +validateToken(token)
    }
    class ProjectService {
        +createProject(input)
        +listProjects(userId)
    }
    class TimelineService {
        +createBranch(input)
        +commitTimeline(input)
        +requestDiff(input)
        +createCutRequest(input)
        +mergeCutRequest(input)
    }
    class AssetService {
        +generateUploadUrl(assetMeta)
        +notifyUploadComplete(assetId)
    }
    class MediaProcessor {
        +processProxy(assetId)
        +generateThumbnail(assetId)
        +extractMetadata(assetId)
    }
    class DiffEngineService {
        +computeDiff(versionA, versionB)
        +computeMerge(ancestor, A, B)
    }
    class ReviewService {
        +addComment(input)
        +listComments(context)
    }
    class NotificationService {
        +sendEmail(event)
        +createInApp(event)
    }
    class BillingService {
        +createSubscription(input)
        +handleWebhook(event)
    }
    class WebSocketService {
        +pushUpdate(channel, payload)
    }

    %% Dependencies
    APIGateway ..> AuthService
    APIGateway ..> ProjectService
    APIGateway ..> TimelineService
    APIGateway ..> AssetService
    APIGateway ..> ReviewService
    APIGateway ..> BillingService

    AssetService ..> MediaProcessor        : triggers
    MediaProcessor --> AssetService        : callbacks
    TimelineService ..> DiffEngineService  : invokes
    DiffEngineService --> TimelineService  : callbacks

    ReviewService --> NotificationService : publishes
    NotificationService --> WebSocketService : pushes
```

---

## 2. Sequence Diagrams

### 2.1 User Registration & Login

```mermaid
sequenceDiagram
    participant Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant DB as PostgreSQL

    Client->>API: POST /auth/register {email, pw}
    API->>Auth: register(details)
    Auth->>DB: INSERT users
    DB-->>Auth: success
    Auth-->>API: userId
    API-->>Client: 201 Created

    Client->>API: POST /auth/login {email, pw}
    API->>Auth: login(credentials)
    Auth->>DB: SELECT user
    Auth-->>Auth: verifyPassword
    Auth->>Auth: issueJWT(userId)
    Auth-->>API: {token}
    API-->>Client: 200 OK
```

### 2.2 Project Creation Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant Project as Project Service
    participant DB as PostgreSQL

    Client->>API: POST /projects {title, desc}
    API->>Auth: validateToken()
    API->>Project: createProject(input)
    Project->>DB: INSERT projects
    DB-->>Project: projectId
    Project-->>API: projectId
    API-->>Client: 201 Created
```

### 2.3 Branch Creation Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant Project as Project Service
    participant Timeline as Timeline Service
    participant DB as PostgreSQL

    Client->>API: mutation createBranch(projectId, sourceBranch, name)
    API->>Auth: validateToken()
    API->>Project: checkBranchPerms()
    API->>Timeline: createBranch(input)
    Timeline->>DB: INSERT branches
    Timeline->>DB: INSERT timeline_versions (initial)
    DB-->>Timeline: branchId, versionId
    Timeline-->>API: branchId
    API-->>Client: response
```

### 2.4 Timeline Commit Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant Timeline as Timeline Service
    participant DB as PostgreSQL

    Client->>API: mutation commitTimeline(branchId, timelineJson, msg)
    API->>Auth: validateToken()
    API->>Timeline: commitTimeline(input)
    Timeline->>DB: INSERT timeline_versions
    DB-->>Timeline: versionId
    Timeline-->>API: versionId
    API-->>Client: 200 OK
```

### 2.5 Diff Calculation Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant Timeline as Timeline Service
    participant Diff as DiffEngineService

    Client->>API: query requestDiff(versionA, versionB)
    API->>Auth: validateToken()
    API->>Timeline: requestDiff(input)
    Timeline->>Diff: computeDiff(A, B)
    Diff-->>Timeline: diffResult
    Timeline-->>API: diffResult
    API-->>Client: diff JSON
```

### 2.6 Add Comment Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant Review as Review Service
    participant DB as PostgreSQL
    participant Bus as Event Bus
    participant Notif as Notification Service
    participant WS as WebSocketService

    Client->>API: mutation addComment(input)
    API->>Auth: validateToken()
    API->>Review: addComment(input)
    Review->>DB: INSERT comments
    DB-->>Review: commentId
    Review->>Bus: publish comment_added
    Bus->>Notif: notifyParticipants
    Notif->>DB: INSERT notifications
    Notif->>WS: pushUpdate(channel, payload)
    WS-->>Client: real-time comment
    Review-->>API: commentId
    API-->>Client: response
```

### 2.7 Cut Request Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant Timeline as Timeline Service
    participant DB as PostgreSQL
    participant Bus as Event Bus
    participant Notif as Notification Service

    Client->>API: mutation createCutRequest(input)
    API->>Auth: validateToken()
    API->>Timeline: createCutRequest(input)
    Timeline->>DB: INSERT cut_requests
    DB-->>Timeline: cutRequestId
    Timeline->>Bus: publish cut_request_created
    Bus->>Notif: notifyReviewers
    Notif-->>Client: notifications
    Timeline-->>API: cutRequestId
    API-->>Client: response
```

### 2.8 Merge Cut Request Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant Timeline as Timeline Service
    participant DB as PostgreSQL
    participant Diff as DiffEngineService
    participant Bus as Event Bus
    participant Notif as Notification Service

    Client->>API: mutation mergeCutRequest(id)
    API->>Auth: validateToken()
    API->>Timeline: startMerge(id)
    Timeline->>DB: SELECT branches, versions
    Timeline->>Diff: computeMerge(ancestor, A, B)
    Diff-->>Timeline: mergeResult
    alt success
      Timeline->>DB: INSERT new timeline_version
      Timeline->>DB: UPDATE cut_requests status=merged
      Timeline->>Bus: publish cut_request_merged
    else conflict
      Timeline->>DB: UPDATE cut_requests status=conflicted
      Timeline->>Bus: publish cut_request_conflicted
    end
    Bus->>Notif: notifyMergeOutcome
    Notif-->>Client: in-app/email
    Timeline-->>API: mergeResult
    API-->>Client: response
```

### 2.9 Billing Subscription Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant Billing as BillingService
    participant Stripe
    participant DB as PostgreSQL

    Client->>API: POST /billing/subscribe {plan, paymentInfo}
    API->>Auth: validateToken()
    API->>Billing: createSubscription(input)
    Billing->>Stripe: createCustomer + subscribe
    Stripe-->>Billing: webhook event
    Billing->>DB: INSERT/UPDATE billing_info
    Billing-->>API: subscriptionStatus
    API-->>Client: 200 OK
```

All diagrams above cover:

* **Authentication** (registration/login)
* **Project** lifecycle (create/list)
* **Branch** creation & **Timeline** commits
* **Diff** requests & **Merge** handling
* **Asset** upload & **Media Processing**
* **Review** comments & **Real-time** updates
* **Cut Requests** & **Merge** flows
* **Billing** subscription integration
