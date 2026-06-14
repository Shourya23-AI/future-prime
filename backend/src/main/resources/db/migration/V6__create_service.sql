-- ============================================================
-- V6: Service (After-Sales) Module
-- Tables: equipment_unit, warranty_record,
--         free_service_entitlement, amc_contract,
--         service_job, service_visit, service_part_usage
-- ============================================================

CREATE TABLE equipment_unit (
    id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id      UUID        NOT NULL REFERENCES business_entity(id),
    product_id              UUID        NOT NULL REFERENCES product(id),
    customer_id             UUID        NOT NULL REFERENCES customer(id),
    invoice_id              UUID        REFERENCES invoice(id),
    serial_number           VARCHAR(100),
    delivery_date           DATE,
    commissioning_date      DATE,
    installation_address    TEXT,
    status                  VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at              TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at              TIMESTAMP   NOT NULL DEFAULT now(),
    created_by              VARCHAR(255),
    updated_by              VARCHAR(255)
);

CREATE TABLE warranty_record (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    equipment_unit_id   UUID        NOT NULL REFERENCES equipment_unit(id),
    warranty_type       VARCHAR(30) NOT NULL,
    start_date          DATE,
    end_date            DATE,
    terms               TEXT,
    is_active           BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP   NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE free_service_entitlement (
    id                      UUID     PRIMARY KEY DEFAULT gen_random_uuid(),
    equipment_unit_id       UUID     NOT NULL UNIQUE REFERENCES equipment_unit(id),
    total_free_services     INTEGER  NOT NULL DEFAULT 0,
    used_free_services      INTEGER  NOT NULL DEFAULT 0,
    remaining_free_services INTEGER  NOT NULL DEFAULT 0,
    created_at              TIMESTAMP NOT NULL DEFAULT now(),
    updated_at              TIMESTAMP NOT NULL DEFAULT now(),
    created_by              VARCHAR(255),
    updated_by              VARCHAR(255)
);

CREATE TABLE amc_contract (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID          NOT NULL REFERENCES business_entity(id),
    equipment_unit_id   UUID          NOT NULL REFERENCES equipment_unit(id),
    customer_id         UUID          NOT NULL REFERENCES customer(id),
    contract_number     VARCHAR(30)   NOT NULL UNIQUE,
    start_date          DATE          NOT NULL,
    end_date            DATE          NOT NULL,
    amount              NUMERIC(15,2) NOT NULL,
    payment_status      VARCHAR(20)   NOT NULL DEFAULT 'UNPAID',
    visits_included     INTEGER       NOT NULL DEFAULT 0,
    visits_used         INTEGER       NOT NULL DEFAULT 0,
    status              VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE service_job (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID        NOT NULL REFERENCES business_entity(id),
    equipment_unit_id   UUID        NOT NULL REFERENCES equipment_unit(id),
    customer_id         UUID        NOT NULL REFERENCES customer(id),
    job_number          VARCHAR(30) NOT NULL UNIQUE,
    job_type            VARCHAR(30) NOT NULL,
    amc_contract_id     UUID        REFERENCES amc_contract(id),
    reported_issue      TEXT,
    diagnosis           TEXT,
    resolution          TEXT,
    status              VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    scheduled_date      DATE,
    completed_date      DATE,
    is_billable         BOOLEAN     NOT NULL DEFAULT FALSE,
    invoice_id          UUID        REFERENCES invoice(id),
    created_at          TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP   NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE service_visit (
    id                  UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    service_job_id      UUID      NOT NULL REFERENCES service_job(id),
    technician_id       UUID      NOT NULL, -- FK to technician added in V7
    visit_date          DATE      NOT NULL,
    time_in             TIME,
    time_out            TIME,
    work_done           TEXT,
    parts_used          TEXT,
    follow_up_required  BOOLEAN   NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMP NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE service_part_usage (
    id                UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    service_visit_id  UUID          NOT NULL REFERENCES service_visit(id),
    product_id        UUID          NOT NULL REFERENCES product(id),
    quantity          NUMERIC(10,2) NOT NULL,
    unit_cost         NUMERIC(15,2) NOT NULL,
    is_billable       BOOLEAN       NOT NULL DEFAULT FALSE,
    charge_to         VARCHAR(20)   NOT NULL,
    created_at        TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP     NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

-- Indexes
CREATE INDEX idx_equipment_unit_entity    ON equipment_unit(business_entity_id);
CREATE INDEX idx_equipment_unit_customer  ON equipment_unit(customer_id);
CREATE INDEX idx_equipment_unit_product   ON equipment_unit(product_id);
CREATE INDEX idx_warranty_unit            ON warranty_record(equipment_unit_id);
CREATE INDEX idx_amc_unit                 ON amc_contract(equipment_unit_id);
CREATE INDEX idx_amc_customer             ON amc_contract(customer_id);
CREATE INDEX idx_service_job_unit         ON service_job(equipment_unit_id);
CREATE INDEX idx_service_job_customer     ON service_job(customer_id);
CREATE INDEX idx_service_job_status       ON service_job(status);
CREATE INDEX idx_service_visit_job        ON service_visit(service_job_id);
CREATE INDEX idx_service_part_visit       ON service_part_usage(service_visit_id);
