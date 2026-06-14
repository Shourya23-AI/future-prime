-- ============================================================
-- V5: Imports Module
-- Tables: purchase_order, purchase_order_line_item,
--         lc_tracking, shipment, shipment_purchase_order,
--         customs_clearance, shipment_cost, landed_cost_allocation
-- ============================================================

CREATE TABLE purchase_order (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID          NOT NULL REFERENCES business_entity(id),
    supplier_id         UUID          NOT NULL REFERENCES supplier(id),
    sales_order_id      UUID          REFERENCES sales_order(id),
    po_number           VARCHAR(30)   NOT NULL UNIQUE,
    po_date             DATE          NOT NULL,
    supplier_currency   VARCHAR(10)   NOT NULL,
    exchange_rate       NUMERIC(10,4) NOT NULL,
    status              VARCHAR(20)   NOT NULL DEFAULT 'DRAFT',
    payment_terms       VARCHAR(100),
    lc_required         BOOLEAN       NOT NULL DEFAULT FALSE,
    notes               TEXT,
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE purchase_order_line_item (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_order_id   UUID          NOT NULL REFERENCES purchase_order(id),
    product_id          UUID          NOT NULL REFERENCES product(id),
    quantity            NUMERIC(10,2) NOT NULL,
    unit_price          NUMERIC(15,2) NOT NULL,
    line_total          NUMERIC(15,2) NOT NULL,
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE lc_tracking (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID          NOT NULL REFERENCES business_entity(id),
    purchase_order_id   UUID          NOT NULL REFERENCES purchase_order(id),
    lc_number           VARCHAR(50)   NOT NULL,
    bank_name           VARCHAR(100),
    lc_amount           NUMERIC(15,2) NOT NULL,
    lc_currency         VARCHAR(10)   NOT NULL,
    issue_date          DATE,
    expiry_date         DATE,
    status              VARCHAR(20)   NOT NULL DEFAULT 'APPLIED',
    notes               TEXT,
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE shipment (
    id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id      UUID        NOT NULL REFERENCES business_entity(id),
    shipment_number         VARCHAR(50) NOT NULL UNIQUE,
    origin_country          VARCHAR(50) NOT NULL,
    shipment_mode           VARCHAR(20) NOT NULL,
    carrier_name            VARCHAR(100),
    bl_number               VARCHAR(50),
    departure_date          DATE,
    estimated_arrival_date  DATE,
    actual_arrival_date     DATE,
    status                  VARCHAR(30) NOT NULL DEFAULT 'IN_TRANSIT',
    notes                   TEXT,
    created_at              TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at              TIMESTAMP   NOT NULL DEFAULT now(),
    created_by              VARCHAR(255),
    updated_by              VARCHAR(255)
);

-- Join table: composite PK, no audit columns
CREATE TABLE shipment_purchase_order (
    shipment_id         UUID  NOT NULL REFERENCES shipment(id),
    purchase_order_id   UUID  NOT NULL REFERENCES purchase_order(id),
    PRIMARY KEY (shipment_id, purchase_order_id)
);

CREATE TABLE customs_clearance (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id         UUID          NOT NULL REFERENCES shipment(id),
    customs_agent       VARCHAR(100),
    entry_number        VARCHAR(50),
    entry_date          DATE,
    customs_duty        NUMERIC(15,2) NOT NULL DEFAULT 0,
    vat_on_import       NUMERIC(15,2) NOT NULL DEFAULT 0,
    other_charges       NUMERIC(15,2) NOT NULL DEFAULT 0,
    total_customs_cost  NUMERIC(15,2) NOT NULL DEFAULT 0,
    clearance_date      DATE,
    status              VARCHAR(20)   NOT NULL DEFAULT 'SUBMITTED',
    notes               TEXT,
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE shipment_cost (
    id           UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id  UUID          NOT NULL REFERENCES shipment(id),
    cost_type    VARCHAR(50)   NOT NULL,
    amount       NUMERIC(15,2) NOT NULL,
    description  VARCHAR(255),
    created_at   TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP     NOT NULL DEFAULT now(),
    created_by   VARCHAR(255),
    updated_by   VARCHAR(255)
);

CREATE TABLE landed_cost_allocation (
    id                          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id                 UUID          NOT NULL REFERENCES shipment(id),
    purchase_order_line_item_id UUID          NOT NULL REFERENCES purchase_order_line_item(id),
    product_id                  UUID          NOT NULL REFERENCES product(id),
    quantity                    NUMERIC(10,2) NOT NULL,
    supplier_cost_npr           NUMERIC(15,2) NOT NULL,
    allocated_shipment_cost     NUMERIC(15,2) NOT NULL DEFAULT 0,
    landed_cost_per_unit        NUMERIC(15,2) NOT NULL,
    created_at                  TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at                  TIMESTAMP     NOT NULL DEFAULT now(),
    created_by                  VARCHAR(255),
    updated_by                  VARCHAR(255)
);

-- Indexes
CREATE INDEX idx_po_entity          ON purchase_order(business_entity_id);
CREATE INDEX idx_po_supplier        ON purchase_order(supplier_id);
CREATE INDEX idx_po_sales_order     ON purchase_order(sales_order_id);
CREATE INDEX idx_po_line_po         ON purchase_order_line_item(purchase_order_id);
CREATE INDEX idx_shipment_entity    ON shipment(business_entity_id);
CREATE INDEX idx_shipment_status    ON shipment(status);
CREATE INDEX idx_shipment_cost      ON shipment_cost(shipment_id);
CREATE INDEX idx_landed_cost        ON landed_cost_allocation(shipment_id);
CREATE INDEX idx_customs_shipment   ON customs_clearance(shipment_id);
