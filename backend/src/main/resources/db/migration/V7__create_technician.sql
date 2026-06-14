-- ============================================================
-- V7: Technician Module
-- Tables: technician, technician_expense, travel_record
-- Also: adds FK from service_visit to technician
-- ============================================================

CREATE TABLE technician (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL,
    technician_type VARCHAR(20)  NOT NULL,
    supplier_id     UUID         REFERENCES supplier(id),
    phone           VARCHAR(20),
    email           VARCHAR(100),
    country         VARCHAR(50),
    specialization  VARCHAR(100),
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT now(),
    created_by      VARCHAR(255),
    updated_by      VARCHAR(255)
);

-- Now that technician table exists, add the FK on service_visit
ALTER TABLE service_visit
    ADD CONSTRAINT fk_service_visit_technician
    FOREIGN KEY (technician_id) REFERENCES technician(id);

CREATE TABLE technician_expense (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    service_job_id      UUID          NOT NULL REFERENCES service_job(id),
    technician_id       UUID          NOT NULL REFERENCES technician(id),
    business_entity_id  UUID          NOT NULL REFERENCES business_entity(id),
    expense_type        VARCHAR(30)   NOT NULL,
    amount              NUMERIC(15,2) NOT NULL,
    expense_date        DATE          NOT NULL,
    charge_to           VARCHAR(20)   NOT NULL,
    reference           VARCHAR(100),
    notes               TEXT,
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE travel_record (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    service_job_id  UUID        NOT NULL REFERENCES service_job(id),
    technician_id   UUID        NOT NULL REFERENCES technician(id),
    from_location   VARCHAR(100),
    to_location     VARCHAR(100),
    departure_date  DATE,
    return_date     DATE,
    mode            VARCHAR(20),
    nights_stay     INTEGER,
    created_at      TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP   NOT NULL DEFAULT now(),
    created_by      VARCHAR(255),
    updated_by      VARCHAR(255)
);

-- Indexes
CREATE INDEX idx_technician_supplier      ON technician(supplier_id);
CREATE INDEX idx_tech_expense_job         ON technician_expense(service_job_id);
CREATE INDEX idx_tech_expense_technician  ON technician_expense(technician_id);
CREATE INDEX idx_travel_job               ON travel_record(service_job_id);
CREATE INDEX idx_travel_technician        ON travel_record(technician_id);
