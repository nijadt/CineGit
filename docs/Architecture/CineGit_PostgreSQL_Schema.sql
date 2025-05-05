
-- CineGit Database Schema
-- PostgreSQL DDL with constraints, indexing, and relationships

-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    role TEXT CHECK (role IN ('owner', 'editor', 'reviewer', 'viewer')) NOT NULL,
    auth_provider TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Projects
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    visibility TEXT CHECK (visibility IN ('public', 'private')) DEFAULT 'private',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Branches
CREATE TABLE branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    parent_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (project_id, name)
);

-- Assets
CREATE TABLE assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    file_path TEXT NOT NULL,
    thumbnail_path TEXT,
    proxy_path TEXT,
    file_hash TEXT UNIQUE NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Timelines
CREATE TABLE timelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE CASCADE,
    timeline_json JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (branch_id)
);

-- Cut Requests
CREATE TABLE cut_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_branch_id UUID REFERENCES branches(id) ON DELETE CASCADE,
    to_branch_id UUID REFERENCES branches(id) ON DELETE CASCADE,
    status TEXT CHECK (status IN ('pending', 'approved', 'rejected')) NOT NULL,
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Comments
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    timestamp FLOAT NOT NULL,
    comment_text TEXT NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexing for performance
CREATE INDEX idx_assets_project ON assets(project_id);
CREATE INDEX idx_timeline_branch ON timelines(branch_id);
CREATE INDEX idx_comments_asset ON comments(asset_id);
