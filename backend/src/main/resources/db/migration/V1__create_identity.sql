-- ============================================================
-- V1: Identity Module
-- Tables: business_entity, app_user, role, permission,
--         role_permission, user_entity_role, refresh_token
-- ============================================================

CREATE TABLE business_entity (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name              VARCHAR(100) NOT NULL,
    short_code        VARCHAR(10)  NOT NULL UNIQUE,
    address           TEXT,
    pan_number        VARCHAR(20),
    vat_number        VARCHAR(20),
    phone             VARCHAR(20),
    email             VARCHAR(100),
    logo_s3_key       VARCHAR(255),
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP    NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

CREATE TABLE app_user (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name         VARCHAR(100) NOT NULL,
    email             VARCHAR(100) NOT NULL UNIQUE,
    password_hash     VARCHAR(255) NOT NULL,
    phone             VARCHAR(20),
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    last_login_at     TIMESTAMP,
    created_at        TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP    NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

CREATE TABLE role (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name              VARCHAR(50)  NOT NULL UNIQUE,
    description       TEXT,
    created_at        TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP    NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

CREATE TABLE permission (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    code              VARCHAR(100) NOT NULL UNIQUE,
    description       TEXT,
    module            VARCHAR(50),
    created_at        TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP    NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

-- Join table: composite PK, no UUID id, no audit columns
CREATE TABLE role_permission (
    role_id           UUID         NOT NULL REFERENCES role(id),
    permission_id     UUID         NOT NULL REFERENCES permission(id),
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE user_entity_role (
    id                    UUID     PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id               UUID     NOT NULL REFERENCES app_user(id),
    business_entity_id    UUID     NOT NULL REFERENCES business_entity(id),
    role_id               UUID     NOT NULL REFERENCES role(id),
    is_active             BOOLEAN  NOT NULL DEFAULT TRUE,
    created_at            TIMESTAMP NOT NULL DEFAULT now(),
    updated_at            TIMESTAMP NOT NULL DEFAULT now(),
    created_by            VARCHAR(255),
    updated_by            VARCHAR(255)
);

CREATE TABLE refresh_token (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID         NOT NULL REFERENCES app_user(id),
    token             VARCHAR(512) NOT NULL UNIQUE,
    expires_at        TIMESTAMP    NOT NULL,
    is_revoked        BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at        TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP    NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

-- Indexes for frequent lookups
CREATE INDEX idx_user_entity_role_user       ON user_entity_role(user_id);
CREATE INDEX idx_user_entity_role_entity     ON user_entity_role(business_entity_id);
CREATE INDEX idx_refresh_token_user          ON refresh_token(user_id);
CREATE INDEX idx_refresh_token_token         ON refresh_token(token);
