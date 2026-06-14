-- ============================================================
-- V2: Master Data Module
-- Tables: product_category, unit_of_measure, supplier,
--         customer, customer_entity, product, spare_part_mapping
-- ============================================================

CREATE TABLE product_category (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name              VARCHAR(100) NOT NULL,
    parent_id         UUID         REFERENCES product_category(id),
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP    NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

CREATE TABLE unit_of_measure (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name              VARCHAR(50) NOT NULL UNIQUE,
    abbreviation      VARCHAR(10) NOT NULL UNIQUE,
    created_at        TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP   NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

CREATE TABLE supplier (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name              VARCHAR(150) NOT NULL,
    country           VARCHAR(50)  NOT NULL,
    is_mother_company BOOLEAN      NOT NULL DEFAULT FALSE,
    contact_person    VARCHAR(100),
    phone             VARCHAR(20),
    email             VARCHAR(100),
    address           TEXT,
    payment_terms     VARCHAR(100),
    currency          VARCHAR(10)  NOT NULL,
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP    NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

CREATE TABLE customer (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    primary_entity_id   UUID         NOT NULL REFERENCES business_entity(id),
    name                VARCHAR(150) NOT NULL,
    type                VARCHAR(30)  NOT NULL,
    pan_number          VARCHAR(20),
    vat_number          VARCHAR(20),
    billing_address     TEXT,
    shipping_address    TEXT,
    phone               VARCHAR(20),
    email               VARCHAR(100),
    credit_limit        NUMERIC(15,2),
    credit_days         INTEGER,
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP    NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

-- Join table: composite PK, no audit columns
CREATE TABLE customer_entity (
    customer_id         UUID  NOT NULL REFERENCES customer(id),
    business_entity_id  UUID  NOT NULL REFERENCES business_entity(id),
    PRIMARY KEY (customer_id, business_entity_id)
);

CREATE TABLE product (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID         NOT NULL REFERENCES business_entity(id),
    category_id         UUID         REFERENCES product_category(id),
    supplier_id         UUID         REFERENCES supplier(id),
    name                VARCHAR(200) NOT NULL,
    model_number        VARCHAR(100),
    description         TEXT,
    uom_id              UUID         REFERENCES unit_of_measure(id),
    product_type        VARCHAR(30)  NOT NULL,
    business_model      VARCHAR(30)  NOT NULL,
    has_warranty        BOOLEAN      NOT NULL DEFAULT FALSE,
    warranty_months     INTEGER,
    has_free_service    BOOLEAN      NOT NULL DEFAULT FALSE,
    free_service_count  INTEGER,
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP    NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE spare_part_mapping (
    id                      UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    equipment_product_id    UUID          NOT NULL REFERENCES product(id),
    spare_part_product_id   UUID          NOT NULL REFERENCES product(id),
    is_critical             BOOLEAN       NOT NULL DEFAULT FALSE,
    min_stock_quantity      NUMERIC(10,2),
    created_at              TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at              TIMESTAMP     NOT NULL DEFAULT now(),
    created_by              VARCHAR(255),
    updated_by              VARCHAR(255)
);

-- Indexes
CREATE INDEX idx_product_business_entity  ON product(business_entity_id);
CREATE INDEX idx_product_category         ON product(category_id);
CREATE INDEX idx_product_supplier         ON product(supplier_id);
CREATE INDEX idx_customer_primary_entity  ON customer(primary_entity_id);
CREATE INDEX idx_spare_part_equipment     ON spare_part_mapping(equipment_product_id);
