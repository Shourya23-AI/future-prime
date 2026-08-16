-- ============================================================
-- V9: Default Seed Data
-- Creates: 3 business entities, 7 roles, 1 super admin user,
--          and links the admin to all 3 entities
-- Default credentials: admin@futureprime.com / Admin@1234
-- ============================================================

-- Business Entities
INSERT INTO business_entity (id, name, short_code, address, is_active, created_at, updated_at, created_by, updated_by)
VALUES
    ('a1000000-0000-0000-0000-000000000001', 'Prime Associate',    'PA', 'Kathmandu, Nepal', true, now(), now(), 'system', 'system'),
    ('a1000000-0000-0000-0000-000000000002', 'Parina International','PI', 'Kathmandu, Nepal', true, now(), now(), 'system', 'system'),
    ('a1000000-0000-0000-0000-000000000003', 'Future Prime EV',    'EV', 'Kathmandu, Nepal', true, now(), now(), 'system', 'system');

-- Roles
INSERT INTO role (id, name, description, created_at, updated_at, created_by, updated_by)
VALUES
    ('b1000000-0000-0000-0000-000000000001', 'SUPER_ADMIN',   'Full access across all entities',           now(), now(), 'system', 'system'),
    ('b1000000-0000-0000-0000-000000000002', 'ENTITY_ADMIN',  'Full access within assigned entity',        now(), now(), 'system', 'system'),
    ('b1000000-0000-0000-0000-000000000003', 'SALES',         'Create and manage quotes and invoices',     now(), now(), 'system', 'system'),
    ('b1000000-0000-0000-0000-000000000004', 'WAREHOUSE',     'Manage inventory and stock',                now(), now(), 'system', 'system'),
    ('b1000000-0000-0000-0000-000000000005', 'ACCOUNTS',      'Access finance and payment modules',        now(), now(), 'system', 'system'),
    ('b1000000-0000-0000-0000-000000000006', 'TECHNICIAN',    'Log service visits and expenses',           now(), now(), 'system', 'system'),
    ('b1000000-0000-0000-0000-000000000007', 'VIEWER',        'Read-only access across assigned modules',  now(), now(), 'system', 'system');

-- Super Admin User
-- Password: Admin@1234 (BCrypt hashed)
INSERT INTO app_user (id, full_name, email, password_hash, is_active, created_at, updated_at, created_by, updated_by)
VALUES (
           'c1000000-0000-0000-0000-000000000001',
           'System Admin',
           'admin@futureprime.com',
           '$2a$10$/USa/fuDvdhA1BVOpVCu6.yyZnvC6tTkoE06z9e6DjmL0arZQxov.',
           true,
           now(), now(), 'system', 'system'
       );

-- Link admin to all 3 entities with SUPER_ADMIN role
INSERT INTO user_entity_role (id, user_id, business_entity_id, role_id, is_active, created_at, updated_at, created_by, updated_by)
VALUES
    ('d1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', true, now(), now(), 'system', 'system'),
    ('d1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', true, now(), now(), 'system', 'system'),
    ('d1000000-0000-0000-0000-000000000003', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000001', true, now(), now(), 'system', 'system');