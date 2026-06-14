-- ============================================================
-- V8: Finance Module
-- Tables: receivable, payable, supplier_payment,
--         inter_company_invoice, tally_export_log,
--         document_sequence
-- Also: adds FK from inter_company_transfer to inter_company_invoice
-- ============================================================

CREATE TABLE receivable (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID          NOT NULL REFERENCES business_entity(id),
    customer_id         UUID          NOT NULL REFERENCES customer(id),
    invoice_id          UUID          NOT NULL REFERENCES invoice(id),
    original_amount     NUMERIC(15,2) NOT NULL,
    paid_amount         NUMERIC(15,2) NOT NULL DEFAULT 0,
    balance             NUMERIC(15,2) NOT NULL,
    due_date            DATE,
    status              VARCHAR(20)   NOT NULL DEFAULT 'OPEN',
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE payable (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID          NOT NULL REFERENCES business_entity(id),
    supplier_id         UUID          NOT NULL REFERENCES supplier(id),
    purchase_order_id   UUID          NOT NULL REFERENCES purchase_order(id),
    original_amount     NUMERIC(15,2) NOT NULL,
    paid_amount         NUMERIC(15,2) NOT NULL DEFAULT 0,
    balance             NUMERIC(15,2) NOT NULL,
    due_date            DATE,
    status              VARCHAR(20)   NOT NULL DEFAULT 'OPEN',
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE supplier_payment (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID          NOT NULL REFERENCES business_entity(id),
    payable_id          UUID          NOT NULL REFERENCES payable(id),
    supplier_id         UUID          NOT NULL REFERENCES supplier(id),
    payment_date        DATE          NOT NULL,
    amount              NUMERIC(15,2) NOT NULL,
    payment_mode        VARCHAR(30)   NOT NULL,
    reference_number    VARCHAR(100),
    notes               TEXT,
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE inter_company_invoice (
    id                          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    from_entity_id              UUID          NOT NULL REFERENCES business_entity(id),
    to_entity_id                UUID          NOT NULL REFERENCES business_entity(id),
    invoice_number              VARCHAR(30)   NOT NULL UNIQUE,
    invoice_date                DATE          NOT NULL,
    amount                      NUMERIC(15,2) NOT NULL,
    status                      VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    inter_company_transfer_id   UUID          NOT NULL REFERENCES inter_company_transfer(id),
    created_at                  TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at                  TIMESTAMP     NOT NULL DEFAULT now(),
    created_by                  VARCHAR(255),
    updated_by                  VARCHAR(255)
);

-- Now that inter_company_invoice exists, add the FK on inter_company_transfer
ALTER TABLE inter_company_transfer
    ADD CONSTRAINT fk_transfer_inter_company_invoice
    FOREIGN KEY (inter_company_invoice_id) REFERENCES inter_company_invoice(id);

CREATE TABLE tally_export_log (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID        NOT NULL REFERENCES business_entity(id),
    export_type         VARCHAR(30) NOT NULL,
    from_date           DATE        NOT NULL,
    to_date             DATE        NOT NULL,
    exported_at         TIMESTAMP   NOT NULL DEFAULT now(),
    exported_by         UUID        NOT NULL REFERENCES app_user(id),
    file_s3_key         VARCHAR(255),
    record_count        INTEGER,
    created_at          TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP   NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE document_sequence (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID        NOT NULL REFERENCES business_entity(id),
    document_type       VARCHAR(20) NOT NULL,
    year                INTEGER     NOT NULL,
    last_sequence       INTEGER     NOT NULL DEFAULT 0,
    created_at          TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP   NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255),
    UNIQUE (business_entity_id, document_type, year)
);

-- Indexes
CREATE INDEX idx_receivable_entity    ON receivable(business_entity_id);
CREATE INDEX idx_receivable_customer  ON receivable(customer_id);
CREATE INDEX idx_receivable_status    ON receivable(status);
CREATE INDEX idx_receivable_due       ON receivable(due_date);
CREATE INDEX idx_payable_entity       ON payable(business_entity_id);
CREATE INDEX idx_payable_supplier     ON payable(supplier_id);
CREATE INDEX idx_payable_status       ON payable(status);
CREATE INDEX idx_payable_due          ON payable(due_date);
CREATE INDEX idx_supplier_payment     ON supplier_payment(payable_id);
CREATE INDEX idx_ic_invoice_from      ON inter_company_invoice(from_entity_id);
CREATE INDEX idx_ic_invoice_to        ON inter_company_invoice(to_entity_id);
CREATE INDEX idx_tally_export_entity  ON tally_export_log(business_entity_id);
CREATE INDEX idx_doc_seq_lookup       ON document_sequence(business_entity_id, document_type, year);
