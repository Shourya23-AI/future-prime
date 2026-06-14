-- ============================================================
-- V3: Inventory Module
-- Tables: warehouse, rack_location, stock_item,
--         stock_movement, inter_company_transfer
-- ============================================================

CREATE TABLE warehouse (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID         NOT NULL REFERENCES business_entity(id),
    name                VARCHAR(100) NOT NULL,
    address             TEXT,
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP    NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE rack_location (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_id  UUID        NOT NULL REFERENCES warehouse(id),
    code          VARCHAR(30) NOT NULL,
    description   VARCHAR(100),
    is_active     BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP   NOT NULL DEFAULT now(),
    created_by    VARCHAR(255),
    updated_by    VARCHAR(255),
    UNIQUE (warehouse_id, code)
);

CREATE TABLE stock_item (
    id                    UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id            UUID          NOT NULL REFERENCES product(id),
    business_entity_id    UUID          NOT NULL REFERENCES business_entity(id),
    warehouse_id          UUID          NOT NULL REFERENCES warehouse(id),
    rack_location_id      UUID          REFERENCES rack_location(id),
    quantity_on_hand      NUMERIC(10,2) NOT NULL DEFAULT 0,
    quantity_reserved     NUMERIC(10,2) NOT NULL DEFAULT 0,
    quantity_available    NUMERIC(10,2) NOT NULL DEFAULT 0,
    average_landed_cost   NUMERIC(15,2) NOT NULL DEFAULT 0,
    last_movement_at      TIMESTAMP,
    created_at            TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at            TIMESTAMP     NOT NULL DEFAULT now(),
    created_by            VARCHAR(255),
    updated_by            VARCHAR(255),
    UNIQUE (product_id, business_entity_id, warehouse_id)
);

CREATE TABLE stock_movement (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    stock_item_id       UUID          NOT NULL REFERENCES stock_item(id),
    business_entity_id  UUID          NOT NULL REFERENCES business_entity(id),
    movement_type       VARCHAR(30)   NOT NULL,
    quantity            NUMERIC(10,2) NOT NULL,
    unit_cost           NUMERIC(15,2),
    reference_type      VARCHAR(30),
    reference_id        UUID,
    notes               TEXT,
    movement_date       DATE          NOT NULL,
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE inter_company_transfer (
    id                          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    from_entity_id              UUID          NOT NULL REFERENCES business_entity(id),
    to_entity_id                UUID          NOT NULL REFERENCES business_entity(id),
    product_id                  UUID          NOT NULL REFERENCES product(id),
    quantity                    NUMERIC(10,2) NOT NULL,
    transfer_price              NUMERIC(15,2) NOT NULL,
    transfer_date               DATE          NOT NULL,
    status                      VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    from_stock_movement_id      UUID          REFERENCES stock_movement(id),
    to_stock_movement_id        UUID          REFERENCES stock_movement(id),
    inter_company_invoice_id    UUID,         -- FK added in V8 after finance tables exist
    notes                       TEXT,
    created_at                  TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at                  TIMESTAMP     NOT NULL DEFAULT now(),
    created_by                  VARCHAR(255),
    updated_by                  VARCHAR(255)
);

-- Indexes
CREATE INDEX idx_stock_item_product        ON stock_item(product_id);
CREATE INDEX idx_stock_item_entity         ON stock_item(business_entity_id);
CREATE INDEX idx_stock_movement_stock_item ON stock_movement(stock_item_id);
CREATE INDEX idx_stock_movement_date       ON stock_movement(movement_date);
CREATE INDEX idx_stock_movement_reference  ON stock_movement(reference_id);
CREATE INDEX idx_transfer_from_entity      ON inter_company_transfer(from_entity_id);
CREATE INDEX idx_transfer_to_entity        ON inter_company_transfer(to_entity_id);
