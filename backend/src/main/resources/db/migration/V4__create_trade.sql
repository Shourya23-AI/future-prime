-- ============================================================
-- V4: Trade Module
-- Tables: quote, quote_line_item, sales_order,
--         sales_order_line_item, invoice, invoice_line_item,
--         payment_receipt
-- ============================================================

CREATE TABLE quote (
    id                      UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id      UUID          NOT NULL REFERENCES business_entity(id),
    customer_id             UUID          NOT NULL REFERENCES customer(id),
    quote_number            VARCHAR(30)   NOT NULL UNIQUE,
    quote_date              DATE          NOT NULL,
    valid_until             DATE,
    business_model          VARCHAR(30)   NOT NULL,
    status                  VARCHAR(20)   NOT NULL DEFAULT 'DRAFT',
    subtotal                NUMERIC(15,2) NOT NULL DEFAULT 0,
    vat_amount              NUMERIC(15,2) NOT NULL DEFAULT 0,
    total_amount            NUMERIC(15,2) NOT NULL DEFAULT 0,
    terms_and_conditions    TEXT,
    notes                   TEXT,
    approved_by             UUID          REFERENCES app_user(id),
    approved_at             TIMESTAMP,
    created_at              TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at              TIMESTAMP     NOT NULL DEFAULT now(),
    created_by              VARCHAR(255),
    updated_by              VARCHAR(255)
);

CREATE TABLE quote_line_item (
    id                UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    quote_id          UUID          NOT NULL REFERENCES quote(id),
    product_id        UUID          NOT NULL REFERENCES product(id),
    description       VARCHAR(500),
    quantity          NUMERIC(10,2) NOT NULL,
    unit_price        NUMERIC(15,2) NOT NULL,
    discount_percent  NUMERIC(5,2)  NOT NULL DEFAULT 0,
    vat_applicable    BOOLEAN       NOT NULL DEFAULT TRUE,
    line_total        NUMERIC(15,2) NOT NULL,
    sort_order        INTEGER       NOT NULL DEFAULT 0,
    created_at        TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP     NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

CREATE TABLE sales_order (
    id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id      UUID        NOT NULL REFERENCES business_entity(id),
    quote_id                UUID        REFERENCES quote(id),
    customer_id             UUID        NOT NULL REFERENCES customer(id),
    order_number            VARCHAR(30) NOT NULL UNIQUE,
    order_date              DATE        NOT NULL,
    expected_delivery_date  DATE,
    delivery_address        TEXT,
    status                  VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
    business_model          VARCHAR(30) NOT NULL,
    notes                   TEXT,
    created_at              TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at              TIMESTAMP   NOT NULL DEFAULT now(),
    created_by              VARCHAR(255),
    updated_by              VARCHAR(255)
);

CREATE TABLE sales_order_line_item (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    sales_order_id      UUID          NOT NULL REFERENCES sales_order(id),
    product_id          UUID          NOT NULL REFERENCES product(id),
    quantity_ordered    NUMERIC(10,2) NOT NULL,
    quantity_delivered  NUMERIC(10,2) NOT NULL DEFAULT 0,
    unit_price          NUMERIC(15,2) NOT NULL,
    discount_percent    NUMERIC(5,2)  NOT NULL DEFAULT 0,
    vat_applicable      BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE invoice (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID          NOT NULL REFERENCES business_entity(id),
    sales_order_id      UUID          REFERENCES sales_order(id),
    customer_id         UUID          NOT NULL REFERENCES customer(id),
    invoice_number      VARCHAR(30)   NOT NULL UNIQUE,
    invoice_date        DATE          NOT NULL,
    due_date            DATE,
    status              VARCHAR(20)   NOT NULL DEFAULT 'DRAFT',
    subtotal            NUMERIC(15,2) NOT NULL DEFAULT 0,
    vat_amount          NUMERIC(15,2) NOT NULL DEFAULT 0,
    total_amount        NUMERIC(15,2) NOT NULL DEFAULT 0,
    paid_amount         NUMERIC(15,2) NOT NULL DEFAULT 0,
    balance_due         NUMERIC(15,2) NOT NULL DEFAULT 0,
    pdf_s3_key          VARCHAR(255),
    notes               TEXT,
    created_at          TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP     NOT NULL DEFAULT now(),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE TABLE invoice_line_item (
    id                UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id        UUID          NOT NULL REFERENCES invoice(id),
    product_id        UUID          NOT NULL REFERENCES product(id),
    description       VARCHAR(500),
    quantity          NUMERIC(10,2) NOT NULL,
    unit_price        NUMERIC(15,2) NOT NULL,
    discount_percent  NUMERIC(5,2)  NOT NULL DEFAULT 0,
    vat_applicable    BOOLEAN       NOT NULL DEFAULT TRUE,
    line_total        NUMERIC(15,2) NOT NULL,
    created_at        TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP     NOT NULL DEFAULT now(),
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

CREATE TABLE payment_receipt (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    business_entity_id  UUID          NOT NULL REFERENCES business_entity(id),
    invoice_id          UUID          NOT NULL REFERENCES invoice(id),
    customer_id         UUID          NOT NULL REFERENCES customer(id),
    receipt_number      VARCHAR(30)   NOT NULL UNIQUE,
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

-- Indexes
CREATE INDEX idx_quote_entity          ON quote(business_entity_id);
CREATE INDEX idx_quote_customer        ON quote(customer_id);
CREATE INDEX idx_quote_status          ON quote(status);
CREATE INDEX idx_quote_line_quote      ON quote_line_item(quote_id);
CREATE INDEX idx_sales_order_entity    ON sales_order(business_entity_id);
CREATE INDEX idx_sales_order_customer  ON sales_order(customer_id);
CREATE INDEX idx_sales_order_quote     ON sales_order(quote_id);
CREATE INDEX idx_sales_order_line      ON sales_order_line_item(sales_order_id);
CREATE INDEX idx_invoice_entity        ON invoice(business_entity_id);
CREATE INDEX idx_invoice_customer      ON invoice(customer_id);
CREATE INDEX idx_invoice_status        ON invoice(status);
CREATE INDEX idx_invoice_due_date      ON invoice(due_date);
CREATE INDEX idx_invoice_line_invoice  ON invoice_line_item(invoice_id);
CREATE INDEX idx_payment_invoice       ON payment_receipt(invoice_id);
