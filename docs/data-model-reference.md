# Future Prime — Data Model Reference

Complete reference for all database tables, columns, relationships, and their business purpose.

---

## ER Diagram

```mermaid
erDiagram

    %% ─── IDENTITY ───────────────────────────────────────────────
    business_entity {
        UUID id PK
        string name
        string short_code
        string address
        string pan_number
        string vat_number
        string phone
        string email
        string logo_s3_key
        boolean is_active
    }

    app_user {
        UUID id PK
        string full_name
        string email
        string password_hash
        string phone
        boolean is_active
        timestamp last_login_at
    }

    role {
        UUID id PK
        string name
        string description
    }

    permission {
        UUID id PK
        string code
        string description
        string module
    }

    role_permission {
        UUID role_id FK
        UUID permission_id FK
    }

    user_entity_role {
        UUID id PK
        UUID user_id FK
        UUID business_entity_id FK
        UUID role_id FK
        boolean is_active
    }

    refresh_token {
        UUID id PK
        UUID user_id FK
        string token
        timestamp expires_at
        boolean is_revoked
    }

    %% ─── MASTER ─────────────────────────────────────────────────
    customer {
        UUID id PK
        UUID primary_entity_id FK
        string name
        string type
        string pan_number
        string vat_number
        string billing_address
        string shipping_address
        string phone
        string email
        decimal credit_limit
        int credit_days
        boolean is_active
    }

    customer_entity {
        UUID customer_id FK
        UUID business_entity_id FK
    }

    supplier {
        UUID id PK
        string name
        string country
        boolean is_mother_company
        string contact_person
        string phone
        string email
        string address
        string payment_terms
        string currency
        boolean is_active
    }

    product_category {
        UUID id PK
        string name
        UUID parent_id FK
        boolean is_active
    }

    unit_of_measure {
        UUID id PK
        string name
        string abbreviation
    }

    product {
        UUID id PK
        UUID business_entity_id FK
        UUID category_id FK
        UUID supplier_id FK
        string name
        string model_number
        string description
        UUID uom_id FK
        string product_type
        string business_model
        boolean has_warranty
        int warranty_months
        boolean has_free_service
        int free_service_count
        boolean is_active
    }

    spare_part_mapping {
        UUID id PK
        UUID equipment_product_id FK
        UUID spare_part_product_id FK
        boolean is_critical
        decimal min_stock_quantity
    }

    %% ─── INVENTORY ──────────────────────────────────────────────
    warehouse {
        UUID id PK
        UUID business_entity_id FK
        string name
        string address
        boolean is_active
    }

    rack_location {
        UUID id PK
        UUID warehouse_id FK
        string code
        string description
        boolean is_active
    }

    stock_item {
        UUID id PK
        UUID product_id FK
        UUID business_entity_id FK
        UUID warehouse_id FK
        UUID rack_location_id FK
        decimal quantity_on_hand
        decimal quantity_reserved
        decimal quantity_available
        decimal average_landed_cost
        timestamp last_movement_at
    }

    stock_movement {
        UUID id PK
        UUID stock_item_id FK
        UUID business_entity_id FK
        string movement_type
        decimal quantity
        decimal unit_cost
        string reference_type
        UUID reference_id
        text notes
        date movement_date
    }

    inter_company_transfer {
        UUID id PK
        UUID from_entity_id FK
        UUID to_entity_id FK
        UUID product_id FK
        decimal quantity
        decimal transfer_price
        date transfer_date
        string status
        UUID from_stock_movement_id FK
        UUID to_stock_movement_id FK
        UUID inter_company_invoice_id FK
        text notes
    }

    %% ─── TRADE ──────────────────────────────────────────────────
    quote {
        UUID id PK
        UUID business_entity_id FK
        UUID customer_id FK
        string quote_number
        date quote_date
        date valid_until
        string business_model
        string status
        decimal subtotal
        decimal vat_amount
        decimal total_amount
        text terms_and_conditions
        text notes
        UUID approved_by FK
        timestamp approved_at
    }

    quote_line_item {
        UUID id PK
        UUID quote_id FK
        UUID product_id FK
        string description
        decimal quantity
        decimal unit_price
        decimal discount_percent
        boolean vat_applicable
        decimal line_total
        int sort_order
    }

    sales_order {
        UUID id PK
        UUID business_entity_id FK
        UUID quote_id FK
        UUID customer_id FK
        string order_number
        date order_date
        date expected_delivery_date
        text delivery_address
        string status
        string business_model
        text notes
    }

    sales_order_line_item {
        UUID id PK
        UUID sales_order_id FK
        UUID product_id FK
        decimal quantity_ordered
        decimal quantity_delivered
        decimal unit_price
        decimal discount_percent
        boolean vat_applicable
    }

    invoice {
        UUID id PK
        UUID business_entity_id FK
        UUID sales_order_id FK
        UUID customer_id FK
        string invoice_number
        date invoice_date
        date due_date
        string status
        decimal subtotal
        decimal vat_amount
        decimal total_amount
        decimal paid_amount
        decimal balance_due
        string pdf_s3_key
        text notes
    }

    invoice_line_item {
        UUID id PK
        UUID invoice_id FK
        UUID product_id FK
        string description
        decimal quantity
        decimal unit_price
        decimal discount_percent
        boolean vat_applicable
        decimal line_total
    }

    payment_receipt {
        UUID id PK
        UUID business_entity_id FK
        UUID invoice_id FK
        UUID customer_id FK
        string receipt_number
        date payment_date
        decimal amount
        string payment_mode
        string reference_number
        text notes
    }

    %% ─── IMPORTS ────────────────────────────────────────────────
    purchase_order {
        UUID id PK
        UUID business_entity_id FK
        UUID supplier_id FK
        UUID sales_order_id FK
        string po_number
        date po_date
        string supplier_currency
        decimal exchange_rate
        string status
        string payment_terms
        boolean lc_required
        text notes
    }

    purchase_order_line_item {
        UUID id PK
        UUID purchase_order_id FK
        UUID product_id FK
        decimal quantity
        decimal unit_price
        decimal line_total
    }

    lc_tracking {
        UUID id PK
        UUID business_entity_id FK
        UUID purchase_order_id FK
        string lc_number
        string bank_name
        decimal lc_amount
        string lc_currency
        date issue_date
        date expiry_date
        string status
        text notes
    }

    shipment {
        UUID id PK
        UUID business_entity_id FK
        string shipment_number
        string origin_country
        string shipment_mode
        string carrier_name
        string bl_number
        date departure_date
        date estimated_arrival_date
        date actual_arrival_date
        string status
        text notes
    }

    shipment_purchase_order {
        UUID shipment_id FK
        UUID purchase_order_id FK
    }

    customs_clearance {
        UUID id PK
        UUID shipment_id FK
        string customs_agent
        string entry_number
        date entry_date
        decimal customs_duty
        decimal vat_on_import
        decimal other_charges
        decimal total_customs_cost
        date clearance_date
        string status
        text notes
    }

    shipment_cost {
        UUID id PK
        UUID shipment_id FK
        string cost_type
        decimal amount
        string description
    }

    landed_cost_allocation {
        UUID id PK
        UUID shipment_id FK
        UUID purchase_order_line_item_id FK
        UUID product_id FK
        decimal quantity
        decimal supplier_cost_npr
        decimal allocated_shipment_cost
        decimal landed_cost_per_unit
    }

    %% ─── SERVICE ────────────────────────────────────────────────
    equipment_unit {
        UUID id PK
        UUID business_entity_id FK
        UUID product_id FK
        UUID customer_id FK
        UUID invoice_id FK
        string serial_number
        date delivery_date
        date commissioning_date
        text installation_address
        string status
    }

    warranty_record {
        UUID id PK
        UUID equipment_unit_id FK
        string warranty_type
        date start_date
        date end_date
        text terms
        boolean is_active
    }

    free_service_entitlement {
        UUID id PK
        UUID equipment_unit_id FK
        int total_free_services
        int used_free_services
        int remaining_free_services
    }

    amc_contract {
        UUID id PK
        UUID business_entity_id FK
        UUID equipment_unit_id FK
        UUID customer_id FK
        string contract_number
        date start_date
        date end_date
        decimal amount
        string payment_status
        int visits_included
        int visits_used
        string status
    }

    service_job {
        UUID id PK
        UUID business_entity_id FK
        UUID equipment_unit_id FK
        UUID customer_id FK
        string job_number
        string job_type
        UUID amc_contract_id FK
        text reported_issue
        text diagnosis
        text resolution
        string status
        date scheduled_date
        date completed_date
        boolean is_billable
        UUID invoice_id FK
    }

    service_visit {
        UUID id PK
        UUID service_job_id FK
        UUID technician_id FK
        date visit_date
        time time_in
        time time_out
        text work_done
        text parts_used
        boolean follow_up_required
    }

    service_part_usage {
        UUID id PK
        UUID service_visit_id FK
        UUID product_id FK
        decimal quantity
        decimal unit_cost
        boolean is_billable
        string charge_to
    }

    %% ─── TECHNICIAN ─────────────────────────────────────────────
    technician {
        UUID id PK
        string name
        string technician_type
        UUID supplier_id FK
        string phone
        string email
        string country
        string specialization
        boolean is_active
    }

    technician_expense {
        UUID id PK
        UUID service_job_id FK
        UUID technician_id FK
        UUID business_entity_id FK
        string expense_type
        decimal amount
        date expense_date
        string charge_to
        string reference
        text notes
    }

    travel_record {
        UUID id PK
        UUID service_job_id FK
        UUID technician_id FK
        string from_location
        string to_location
        date departure_date
        date return_date
        string mode
        int nights_stay
    }

    %% ─── FINANCE ────────────────────────────────────────────────
    receivable {
        UUID id PK
        UUID business_entity_id FK
        UUID customer_id FK
        UUID invoice_id FK
        decimal original_amount
        decimal paid_amount
        decimal balance
        date due_date
        string status
    }

    payable {
        UUID id PK
        UUID business_entity_id FK
        UUID supplier_id FK
        UUID purchase_order_id FK
        decimal original_amount
        decimal paid_amount
        decimal balance
        date due_date
        string status
    }

    supplier_payment {
        UUID id PK
        UUID business_entity_id FK
        UUID payable_id FK
        UUID supplier_id FK
        date payment_date
        decimal amount
        string payment_mode
        string reference_number
        text notes
    }

    inter_company_invoice {
        UUID id PK
        UUID from_entity_id FK
        UUID to_entity_id FK
        string invoice_number
        date invoice_date
        decimal amount
        string status
        UUID inter_company_transfer_id FK
    }

    tally_export_log {
        UUID id PK
        UUID business_entity_id FK
        string export_type
        date from_date
        date to_date
        timestamp exported_at
        UUID exported_by FK
        string file_s3_key
        int record_count
    }

    document_sequence {
        UUID id PK
        UUID business_entity_id FK
        string document_type
        int year
        int last_sequence
    }

    %% ─── RELATIONSHIPS ───────────────────────────────────────────

    business_entity ||--o{ user_entity_role : "has"
    app_user ||--o{ user_entity_role : "assigned via"
    role ||--o{ user_entity_role : "defines"
    role ||--o{ role_permission : "has"
    permission ||--o{ role_permission : "belongs to"
    app_user ||--o{ refresh_token : "owns"

    business_entity ||--o{ customer : "primary owner"
    customer ||--o{ customer_entity : "accessible by"
    business_entity ||--o{ customer_entity : "accesses"

    business_entity ||--o{ product : "owns"
    product_category ||--o{ product : "categorises"
    product_category ||--o{ product_category : "parent of"
    supplier ||--o{ product : "supplies"
    unit_of_measure ||--o{ product : "measures"
    product ||--o{ spare_part_mapping : "has parts"
    product ||--o{ spare_part_mapping : "is part of"

    business_entity ||--o{ warehouse : "operates"
    warehouse ||--o{ rack_location : "contains"
    product ||--o{ stock_item : "tracked in"
    business_entity ||--o{ stock_item : "owns"
    warehouse ||--o{ stock_item : "holds"
    stock_item ||--o{ stock_movement : "records"

    business_entity ||--o{ inter_company_transfer : "sends"
    business_entity ||--o{ inter_company_transfer : "receives"

    customer ||--o{ quote : "receives"
    business_entity ||--o{ quote : "issues"
    quote ||--o{ quote_line_item : "contains"
    product ||--o{ quote_line_item : "appears in"

    quote ||--o| sales_order : "converts to"
    customer ||--o{ sales_order : "placed by"
    sales_order ||--o{ sales_order_line_item : "contains"

    sales_order ||--o{ invoice : "billed via"
    customer ||--o{ invoice : "billed to"
    invoice ||--o{ invoice_line_item : "contains"
    invoice ||--o{ payment_receipt : "paid via"

    supplier ||--o{ purchase_order : "receives"
    business_entity ||--o{ purchase_order : "raises"
    sales_order ||--o| purchase_order : "triggers"
    purchase_order ||--o{ purchase_order_line_item : "contains"
    purchase_order ||--o| lc_tracking : "covered by"

    shipment ||--o{ shipment_purchase_order : "includes"
    purchase_order ||--o{ shipment_purchase_order : "shipped via"
    shipment ||--o| customs_clearance : "cleared by"
    shipment ||--o{ shipment_cost : "incurs"
    shipment ||--o{ landed_cost_allocation : "allocates to"

    invoice ||--o| equipment_unit : "registers"
    product ||--o{ equipment_unit : "instance of"
    customer ||--o{ equipment_unit : "owned by"
    equipment_unit ||--o| warranty_record : "has"
    equipment_unit ||--o| free_service_entitlement : "has"
    equipment_unit ||--o{ amc_contract : "covered by"
    equipment_unit ||--o{ service_job : "serviced via"

    service_job ||--o{ service_visit : "has"
    service_visit ||--o{ service_part_usage : "uses"
    service_job ||--o{ technician_expense : "incurs"
    service_job ||--o{ travel_record : "involves"
    technician ||--o{ service_visit : "performs"
    technician ||--o{ technician_expense : "incurs"
    technician ||--o{ travel_record : "travels"
    supplier ||--o{ technician : "sends"

    invoice ||--o| receivable : "creates"
    customer ||--o{ receivable : "owes"
    purchase_order ||--o| payable : "creates"
    supplier ||--o{ payable : "owed by"
    payable ||--o{ supplier_payment : "settled via"
    inter_company_transfer ||--o| inter_company_invoice : "generates"
```

---

## Module 1 — Identity

### `business_entity`
The anchor of the entire system. Every transaction belongs to one of the three rows in this table — Prime Associate, Parina International, or Future Prime EV. Without this table you cannot separate financials, inventory, or operations between the three companies.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| name | VARCHAR(100) | Full legal entity name e.g. "Prime Associate" |
| short_code | VARCHAR(10) | Used in document number generation e.g. "PA", "PI", "EV" |
| address | TEXT | Registered address — printed on invoices |
| pan_number | VARCHAR(20) | Nepal PAN — required for tax compliance |
| vat_number | VARCHAR(20) | Nepal VAT registration — printed on tax invoices |
| phone | VARCHAR(20) | Contact number for this entity |
| email | VARCHAR(100) | Contact email for this entity |
| logo_s3_key | VARCHAR(255) | S3 key for company logo — pulled when generating invoice PDFs |
| is_active | BOOLEAN | Soft delete — deactivate without losing history |

---

### `app_user`
Your employees. One record per person regardless of how many entities they work for. Email is the login username — unique constraint enforces no duplicate accounts.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| full_name | VARCHAR(100) | Display name throughout the app |
| email | VARCHAR(100) | Login username — must be unique |
| password_hash | VARCHAR(255) | BCrypt hash — plain passwords are never stored |
| phone | VARCHAR(20) | Contact number |
| is_active | BOOLEAN | Deactivate without deleting — preserves audit trail |
| last_login_at | TIMESTAMP | Security auditing, identify inactive accounts |

---

### `role`
Bundles of permissions. You assign a role to a user, not individual permissions. Changing a role's permissions automatically affects all users with that role.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| name | VARCHAR(50) | SUPER_ADMIN, ENTITY_ADMIN, SALES, WAREHOUSE, ACCOUNTS, TECHNICIAN, VIEWER |
| description | VARCHAR(255) | Human-readable description of what this role can do |

---

### `permission`
Fine-grained actions like `QUOTE_CREATE`, `INVENTORY_ADJUST`, `INVOICE_VOID`. Each maps to a specific operation in the system.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| code | VARCHAR(100) | Machine-readable permission code e.g. QUOTE_CREATE |
| description | VARCHAR(255) | Human-readable explanation |
| module | VARCHAR(50) | Which module this permission belongs to — for admin UI grouping |

---

### `role_permission`
Join table — many-to-many between role and permission. A role has many permissions; a permission can belong to many roles.

| Column | Type | Purpose |
|---|---|---|
| role_id | UUID FK | The role |
| permission_id | UUID FK | The permission granted to that role |

---

### `user_entity_role`
The most important identity table. Answers: which entities can this user access, and what role do they have in each? A single employee can be MANAGER in Prime Associate but VIEWER in Parina International.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| user_id | UUID FK | The employee |
| business_entity_id | UUID FK | Which entity this assignment applies to |
| role_id | UUID FK | What role they have in that entity |
| is_active | BOOLEAN | Revoke access without deleting the record |

---

### `refresh_token`
JWT access tokens are short-lived (24 hours). Refresh tokens are long-lived (7 days) and stored here. When the access token expires, the frontend sends the refresh token to get a new one without forcing re-login.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| user_id | UUID FK | Which user owns this token |
| token | VARCHAR(512) | The token value — unique |
| expires_at | TIMESTAMP | When this token can no longer be used |
| is_revoked | BOOLEAN | Logout revokes the token without deleting it — prevents replay attacks |

---

## Module 2 — Master Data

### `customer`
The businesses or individuals you sell to.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| primary_entity_id | UUID FK | Which entity primarily owns this customer relationship |
| name | VARCHAR(150) | Customer name |
| type | VARCHAR(30) | INDIVIDUAL or COMPANY — affects invoice formatting |
| pan_number | VARCHAR(20) | Customer PAN — required on invoices |
| vat_number | VARCHAR(20) | Customer VAT number — for VAT-registered buyers |
| billing_address | TEXT | Where invoices are addressed |
| shipping_address | TEXT | Where goods are delivered — may differ from billing |
| phone | VARCHAR(20) | Contact number |
| email | VARCHAR(100) | Contact email |
| credit_limit | NUMERIC(15,2) | Maximum outstanding amount allowed in NPR before payment required |
| credit_days | INTEGER | Payment terms — invoice due this many days after issue date |
| is_active | BOOLEAN | Soft delete |

---

### `customer_entity`
Handles shared customers. If a customer buys from both Prime Associate and Parina International, one customer record exists with two rows here. No duplicate customer data.

| Column | Type | Purpose |
|---|---|---|
| customer_id | UUID FK | The customer |
| business_entity_id | UUID FK | The entity that can access this customer |

---

### `supplier`
The Indian and Chinese companies you buy from.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| name | VARCHAR(150) | Supplier company name |
| country | VARCHAR(50) | INDIA, CHINA, or OTHER — determines currency and shipment flow |
| is_mother_company | BOOLEAN | True if this supplier also sends technicians for service/commissioning |
| contact_person | VARCHAR(100) | Primary point of contact |
| phone | VARCHAR(20) | Contact number |
| email | VARCHAR(100) | Contact email |
| address | TEXT | Supplier address |
| payment_terms | VARCHAR(100) | e.g. "LC at sight", "30 days after BL" |
| currency | VARCHAR(10) | INR for India, CNY for China — used in purchase orders |
| is_active | BOOLEAN | Soft delete |

---

### `product_category`
Hierarchical categorization of products. The `parent_id` is self-referencing — a category can have a parent. Example: "Equipment" → "Construction Equipment" → "Batching Plants".

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| name | VARCHAR(100) | Category name |
| parent_id | UUID FK | Parent category — nullable for top-level categories |
| is_active | BOOLEAN | Soft delete |

---

### `unit_of_measure`
Normalizes units across all products. Without this you'd have free-text UOM strings like "pcs", "Pcs", "pieces" causing reporting inconsistencies.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| name | VARCHAR(50) | Full name e.g. "Pieces", "Kilograms" |
| abbreviation | VARCHAR(10) | Short form e.g. "PCS", "KG" — used in documents |

---

### `product`
The central master data entity. Everything bought and sold is a product.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity this product belongs to |
| category_id | UUID FK | Product category |
| supplier_id | UUID FK | Primary supplier for this product |
| name | VARCHAR(200) | Product name |
| model_number | VARCHAR(100) | Manufacturer model number |
| description | TEXT | Detailed description |
| uom_id | UUID FK | Unit of measure |
| product_type | VARCHAR(30) | EQUIPMENT, EV, SPARE_PART, or CONSUMABLE — drives different behavior |
| business_model | VARCHAR(30) | PROJECT_BASED or BATCH_IMPORT — determines the entire order flow |
| has_warranty | BOOLEAN | Whether this product comes with warranty |
| warranty_months | INTEGER | Default warranty period — applied when registering a sold unit |
| has_free_service | BOOLEAN | Whether free periodic service is included in sale |
| free_service_count | INTEGER | Default number of free service visits included |
| is_active | BOOLEAN | Soft delete |

---

### `spare_part_mapping`
Links spare parts to the equipment they belong to. Drives relevant parts suggestion during service jobs and minimum stock alerts for critical parts.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| equipment_product_id | UUID FK | The parent equipment (e.g. Concrete Batching Plant) |
| spare_part_product_id | UUID FK | The spare part product |
| is_critical | BOOLEAN | Critical parts must always be in stock |
| min_stock_quantity | NUMERIC(10,2) | Alert threshold — system warns when stock falls below this |

---

## Module 3 — Inventory

### `warehouse`
Physical locations where stock is held. Owned by a specific entity.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity operates this warehouse |
| name | VARCHAR(100) | Warehouse name |
| address | TEXT | Physical location |
| is_active | BOOLEAN | Soft delete |

---

### `rack_location`
Specific position within a warehouse. Optional — assign when warehouse is large enough to need precise location tracking.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| warehouse_id | UUID FK | Which warehouse this rack is in |
| code | VARCHAR(30) | Location code e.g. "A-01-03" (Aisle-Row-Shelf) |
| description | VARCHAR(100) | Human-readable description |
| is_active | BOOLEAN | Soft delete |

---

### `stock_item`
Current stock levels. One record per (product, business_entity, warehouse) combination. This is your real-time stock position.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| product_id | UUID FK | Which product |
| business_entity_id | UUID FK | Who owns this stock |
| warehouse_id | UUID FK | Where it physically is |
| rack_location_id | UUID FK | Precise location within warehouse — nullable |
| quantity_on_hand | NUMERIC(10,2) | Physically present in warehouse |
| quantity_reserved | NUMERIC(10,2) | Committed to open orders but not yet delivered |
| quantity_available | NUMERIC(10,2) | on_hand minus reserved — what you can actually sell |
| average_landed_cost | NUMERIC(15,2) | Weighted average cost per unit in NPR — basis for margin calculation |
| last_movement_at | TIMESTAMP | When stock last changed — useful for slow-moving stock reports |

---

### `stock_movement`
Every single change to stock is recorded here. Never update stock_item without a movement record. Full audit trail — you can reconstruct the complete history of any product.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| stock_item_id | UUID FK | Which stock item changed |
| business_entity_id | UUID FK | Which entity owns this movement |
| movement_type | VARCHAR(30) | RECEIPT, SALE, TRANSFER_OUT, TRANSFER_IN, ADJUSTMENT, RETURN |
| quantity | NUMERIC(10,2) | Always positive — direction determined by movement_type |
| unit_cost | NUMERIC(15,2) | NPR cost per unit at time of movement |
| reference_type | VARCHAR(30) | What triggered this — PURCHASE_ORDER, SALES_ORDER, TRANSFER, ADJUSTMENT |
| reference_id | UUID | ID of the triggering document — generic FK pattern |
| notes | TEXT | Reason for adjustment or other notes |
| movement_date | DATE | Date of the movement |

---

### `inter_company_transfer`
When Entity A needs stock owned by Entity B. Records both sides of the transfer and links to the financial settlement.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| from_entity_id | UUID FK | Entity giving the stock |
| to_entity_id | UUID FK | Entity receiving the stock |
| product_id | UUID FK | What product is being transferred |
| quantity | NUMERIC(10,2) | How many units |
| transfer_price | NUMERIC(15,2) | Agreed NPR value — industry standard is landed cost |
| transfer_date | DATE | When the transfer happened |
| status | VARCHAR(20) | PENDING, CONFIRMED, CANCELLED |
| from_stock_movement_id | UUID FK | Stock deduction record on the giving entity |
| to_stock_movement_id | UUID FK | Stock addition record on the receiving entity |
| inter_company_invoice_id | UUID FK | Financial settlement document — created on confirmation |
| notes | TEXT | Notes |

---

## Module 4 — Trade

### `quote`
The starting point of every sale. A formal price offer to a customer.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity is making this offer |
| customer_id | UUID FK | Who the quote is for |
| quote_number | VARCHAR(30) | Auto-generated e.g. "PA-QT-2024-0001" |
| quote_date | DATE | When the quote was prepared |
| valid_until | DATE | Quote expiry — protects against price changes |
| business_model | VARCHAR(30) | PROJECT_BASED or BATCH_IMPORT — carried from the product |
| status | VARCHAR(20) | DRAFT → SENT → APPROVED → CONVERTED or REJECTED/EXPIRED |
| subtotal | NUMERIC(15,2) | NPR before VAT |
| vat_amount | NUMERIC(15,2) | 13% Nepal VAT on applicable items |
| total_amount | NUMERIC(15,2) | Final NPR amount including VAT |
| terms_and_conditions | TEXT | Payment and delivery terms |
| notes | TEXT | Internal notes |
| approved_by | UUID FK | Who approved this quote internally before sending |
| approved_at | TIMESTAMP | When internal approval was given |

---

### `quote_line_item`
Individual products on the quote.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| quote_id | UUID FK | Parent quote |
| product_id | UUID FK | Product being quoted |
| description | VARCHAR(500) | Can override product name for custom configurations |
| quantity | NUMERIC(10,2) | Quantity quoted |
| unit_price | NUMERIC(15,2) | NPR price per unit |
| discount_percent | NUMERIC(5,2) | Per-line discount — common in B2B trading |
| vat_applicable | BOOLEAN | Not all products attract VAT — per line control |
| line_total | NUMERIC(15,2) | After discount, before VAT |
| sort_order | INTEGER | Controls display order on the printed quote PDF |

---

### `sales_order`
The internal commitment to fulfill the sale. Created when a quote is approved and converted.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity owns this order |
| quote_id | UUID FK | Source quote — nullable for direct orders without a quote |
| customer_id | UUID FK | Who ordered |
| order_number | VARCHAR(30) | Auto-generated e.g. "PA-SO-2024-0001" |
| order_date | DATE | When the order was confirmed |
| expected_delivery_date | DATE | Committed delivery date to customer |
| delivery_address | TEXT | Where to deliver |
| status | VARCHAR(20) | CONFIRMED → IN_PROGRESS → PARTIALLY_DELIVERED → DELIVERED |
| business_model | VARCHAR(30) | Carried from quote — determines purchase trigger |
| notes | TEXT | Notes |

---

### `sales_order_line_item`
Individual line items on the sales order.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| sales_order_id | UUID FK | Parent order |
| product_id | UUID FK | Product ordered |
| quantity_ordered | NUMERIC(10,2) | Original ordered quantity |
| quantity_delivered | NUMERIC(10,2) | Updated progressively as deliveries happen — enables partial delivery |
| unit_price | NUMERIC(15,2) | Confirmed price in NPR |
| discount_percent | NUMERIC(5,2) | Agreed discount |
| vat_applicable | BOOLEAN | VAT applicability |

---

### `invoice`
The financial document sent to the customer demanding payment.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Issuing entity |
| sales_order_id | UUID FK | Source order — nullable for direct invoices |
| customer_id | UUID FK | Who is being billed |
| invoice_number | VARCHAR(30) | Auto-generated e.g. "PA-INV-2024-0001" |
| invoice_date | DATE | Issue date |
| due_date | DATE | Calculated from invoice_date plus customer credit_days |
| status | VARCHAR(20) | DRAFT, ISSUED, PARTIALLY_PAID, PAID, OVERDUE, VOID |
| subtotal | NUMERIC(15,2) | Before VAT |
| vat_amount | NUMERIC(15,2) | 13% Nepal VAT |
| total_amount | NUMERIC(15,2) | Final amount due |
| paid_amount | NUMERIC(15,2) | Updated as payment receipts are recorded |
| balance_due | NUMERIC(15,2) | total_amount minus paid_amount |
| pdf_s3_key | VARCHAR(255) | S3 location of generated PDF — stored once, served repeatedly |
| notes | TEXT | Notes |

---

### `invoice_line_item`
Individual products on the invoice.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| invoice_id | UUID FK | Parent invoice |
| product_id | UUID FK | Product billed |
| description | VARCHAR(500) | Line description |
| quantity | NUMERIC(10,2) | Quantity billed |
| unit_price | NUMERIC(15,2) | NPR price |
| discount_percent | NUMERIC(5,2) | Discount applied |
| vat_applicable | BOOLEAN | VAT applicability |
| line_total | NUMERIC(15,2) | After discount before VAT |

---

### `payment_receipt`
Records money received from customers against invoices.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Receiving entity |
| invoice_id | UUID FK | Invoice being paid |
| customer_id | UUID FK | Who paid |
| receipt_number | VARCHAR(30) | Auto-generated receipt number |
| payment_date | DATE | When payment was received |
| amount | NUMERIC(15,2) | NPR amount received |
| payment_mode | VARCHAR(30) | CASH, BANK_TRANSFER, CHEQUE, OTHER |
| reference_number | VARCHAR(100) | Cheque number or bank transaction reference — for dispute resolution |
| notes | TEXT | Notes |

---

## Module 5 — Imports

### `purchase_order`
Order placed with an Indian or Chinese supplier.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity is purchasing |
| supplier_id | UUID FK | Who you are ordering from |
| sales_order_id | UUID FK | Linked customer order — set for PROJECT_BASED, null for BATCH_IMPORT |
| po_number | VARCHAR(30) | Auto-generated e.g. "PA-PO-2024-0001" |
| po_date | DATE | Date of order |
| supplier_currency | VARCHAR(10) | INR or CNY |
| exchange_rate | NUMERIC(10,4) | Rate to NPR at PO date — for cost estimation |
| status | VARCHAR(20) | DRAFT → SENT → ACKNOWLEDGED → SHIPPED → RECEIVED |
| payment_terms | VARCHAR(100) | Agreed payment terms with supplier |
| lc_required | BOOLEAN | Triggers LC tracking workflow when true |
| notes | TEXT | Notes |

---

### `purchase_order_line_item`
Individual products in the purchase order.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| purchase_order_id | UUID FK | Parent PO |
| product_id | UUID FK | Product being ordered |
| quantity | NUMERIC(10,2) | Quantity ordered |
| unit_price | NUMERIC(15,2) | Price in supplier currency (INR or CNY) |
| line_total | NUMERIC(15,2) | quantity × unit_price in supplier currency |

---

### `lc_tracking`
Letter of Credit — a bank instrument guaranteeing supplier payment for high-value imports.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity opened this LC |
| purchase_order_id | UUID FK | The PO this LC covers |
| lc_number | VARCHAR(50) | Bank-issued LC number |
| bank_name | VARCHAR(100) | Issuing bank |
| lc_amount | NUMERIC(15,2) | LC value |
| lc_currency | VARCHAR(10) | Currency of the LC |
| issue_date | DATE | When bank issued the LC |
| expiry_date | DATE | LC expires — must be amended if shipment is delayed |
| status | VARCHAR(20) | APPLIED → ISSUED → AMENDED → UTILIZED → EXPIRED |
| notes | TEXT | Notes |

---

### `shipment`
The physical movement of goods from supplier to Nepal.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity owns this shipment |
| shipment_number | VARCHAR(50) | Internal reference number |
| origin_country | VARCHAR(50) | INDIA or CHINA |
| shipment_mode | VARCHAR(20) | ROAD, AIR, or SEA |
| carrier_name | VARCHAR(100) | Shipping company or transporter |
| bl_number | VARCHAR(50) | Bill of Lading or Airway Bill — primary customs document |
| departure_date | DATE | When goods left supplier |
| estimated_arrival_date | DATE | Expected arrival in Nepal |
| actual_arrival_date | DATE | When goods actually arrived |
| status | VARCHAR(30) | IN_TRANSIT → ARRIVED → CUSTOMS_HOLD → CUSTOMS_CLEARED → DELIVERED_TO_WAREHOUSE |
| notes | TEXT | Notes |

---

### `shipment_purchase_order`
Join table — one shipment can contain goods from multiple purchase orders (consolidated shipments save freight cost).

| Column | Type | Purpose |
|---|---|---|
| shipment_id | UUID FK | The shipment |
| purchase_order_id | UUID FK | A PO included in this shipment |

---

### `customs_clearance`
Nepal customs documentation for each shipment.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| shipment_id | UUID FK | Which shipment is being cleared |
| customs_agent | VARCHAR(100) | Agent handling clearance |
| entry_number | VARCHAR(50) | Government customs bill of entry number |
| entry_date | DATE | Date of customs entry |
| customs_duty | NUMERIC(15,2) | Duty paid in NPR — becomes part of landed cost |
| vat_on_import | NUMERIC(15,2) | Import VAT in NPR — becomes part of landed cost |
| other_charges | NUMERIC(15,2) | Any other customs charges |
| total_customs_cost | NUMERIC(15,2) | Sum of all customs costs |
| clearance_date | DATE | When goods were released |
| status | VARCHAR(20) | SUBMITTED, UNDER_REVIEW, CLEARED, HELD |
| notes | TEXT | Notes |

---

### `shipment_cost`
Every cost component of bringing goods to your warehouse. Each stored as a separate line for full transparency.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| shipment_id | UUID FK | Which shipment |
| cost_type | VARCHAR(50) | FREIGHT, CUSTOMS_DUTY, VAT_ON_IMPORT, INSURANCE, LOCAL_TRANSPORT, AGENT_FEE, OTHER |
| amount | NUMERIC(15,2) | NPR amount |
| description | VARCHAR(255) | Details of this cost item |

---

### `landed_cost_allocation`
The most critical table in the imports module. Distributes all shipment costs across individual products proportionally. The result — `landed_cost_per_unit` — is the true cost of each unit and the basis for all margin calculations.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| shipment_id | UUID FK | Which shipment |
| purchase_order_line_item_id | UUID FK | Which PO line this allocation is for |
| product_id | UUID FK | Which product |
| quantity | NUMERIC(10,2) | Units received |
| supplier_cost_npr | NUMERIC(15,2) | Supplier price converted to NPR at actual rate |
| allocated_shipment_cost | NUMERIC(15,2) | Proportional share of total shipment costs |
| landed_cost_per_unit | NUMERIC(15,2) | (supplier_cost_npr + allocated_shipment_cost) ÷ quantity |

---

## Module 6 — Service (After-Sales)

### `equipment_unit`
Every sold equipment unit or EV gets a unique record here at delivery. The anchor for all after-sales activity — warranty, service, AMC all hang off this.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity sold this unit |
| product_id | UUID FK | What product this is an instance of |
| customer_id | UUID FK | Who owns this equipment |
| invoice_id | UUID FK | The sale that created this unit |
| serial_number | VARCHAR(100) | Manufacturer serial or internal number — uniquely identifies the physical machine |
| delivery_date | DATE | When delivered to customer |
| commissioning_date | DATE | When installed and tested — warranty starts from here |
| installation_address | TEXT | Where the equipment is physically located — technicians need this |
| status | VARCHAR(20) | ACTIVE, DECOMMISSIONED, RETURNED |

---

### `warranty_record`
What warranty was provided with this specific unit.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| equipment_unit_id | UUID FK | Which unit has this warranty |
| warranty_type | VARCHAR(30) | PARTS (parts free, labour charged), LABOUR (labour free), COMPREHENSIVE (both free) |
| start_date | DATE | Usually commissioning date |
| end_date | DATE | When warranty expires |
| terms | TEXT | What is and isn't covered |
| is_active | BOOLEAN | Mark inactive when expired or replaced |

---

### `free_service_entitlement`
Tracks free periodic services included in the sale. Increments on each free visit until exhausted.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| equipment_unit_id | UUID FK | Which unit has this entitlement |
| total_free_services | INTEGER | Total free visits included in the sale |
| used_free_services | INTEGER | How many have been consumed |
| remaining_free_services | INTEGER | total minus used — computed and stored for query simplicity |

---

### `amc_contract`
Annual Maintenance Contract — customer pays upfront for guaranteed service coverage.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity manages this AMC |
| equipment_unit_id | UUID FK | Which equipment is covered |
| customer_id | UUID FK | The customer |
| contract_number | VARCHAR(30) | Auto-generated contract reference |
| start_date | DATE | AMC coverage start |
| end_date | DATE | AMC coverage end |
| amount | NUMERIC(15,2) | Contract value in NPR |
| payment_status | VARCHAR(20) | UNPAID, PAID, PARTIAL — don't service unpaid contracts |
| visits_included | INTEGER | Total service visits in this contract |
| visits_used | INTEGER | Consumed visits |
| status | VARCHAR(20) | ACTIVE, EXPIRED, CANCELLED |

---

### `service_job`
A service request for an equipment unit.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity handles this job |
| equipment_unit_id | UUID FK | Which machine needs service |
| customer_id | UUID FK | The customer |
| job_number | VARCHAR(30) | Auto-generated e.g. "PA-SJ-2024-0001" |
| job_type | VARCHAR(30) | WARRANTY, FREE_PERIODIC, PAID_PERIODIC, PAID_ON_DEMAND, AMC, COMMISSIONING |
| amc_contract_id | UUID FK | Set when job_type is AMC |
| reported_issue | TEXT | What the customer reported |
| diagnosis | TEXT | What was found on inspection |
| resolution | TEXT | What was done to fix it |
| status | VARCHAR(20) | OPEN → ASSIGNED → IN_PROGRESS → COMPLETED |
| scheduled_date | DATE | When the visit is planned |
| completed_date | DATE | When job was closed |
| is_billable | BOOLEAN | False for warranty and free service. True for paid jobs |
| invoice_id | UUID FK | Set when service invoice is generated for billable jobs |

---

### `service_visit`
Each physical visit to the customer site. A job may require multiple visits — technician diagnoses, orders a part, returns to install.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| service_job_id | UUID FK | Which job this visit belongs to |
| technician_id | UUID FK | Who visited |
| visit_date | DATE | Date of visit |
| time_in | TIME | Arrival time — for labour hour calculation |
| time_out | TIME | Departure time |
| work_done | TEXT | What was done during this visit |
| parts_used | TEXT | Summary — detailed breakdown in service_part_usage |
| follow_up_required | BOOLEAN | Flag if another visit is needed |

---

### `service_part_usage`
Parts consumed during a visit with cost attribution.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| service_visit_id | UUID FK | Which visit used this part |
| product_id | UUID FK | The spare part used |
| quantity | NUMERIC(10,2) | How many units used |
| unit_cost | NUMERIC(15,2) | NPR cost pulled from stock at time of use |
| is_billable | BOOLEAN | Whether to charge the customer for this part |
| charge_to | VARCHAR(20) | CUSTOMER (add to invoice), SUPPLIER (warranty claim back), COMPANY (absorb internally) |

---

## Module 7 — Technician

### `technician`
People who perform field service work — either sent by the Indian supplier or hired locally.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| name | VARCHAR(100) | Technician name |
| technician_type | VARCHAR(20) | SUPPLIER (from mother company) or LOCAL (hired in Nepal) |
| supplier_id | UUID FK | For SUPPLIER type — which company sent them |
| phone | VARCHAR(20) | Contact number |
| email | VARCHAR(100) | Contact email |
| country | VARCHAR(50) | NEPAL, INDIA, or CHINA |
| specialization | VARCHAR(100) | e.g. "Concrete Equipment", "EV Systems" |
| is_active | BOOLEAN | Soft delete |

---

### `technician_expense`
Every expense incurred for a technician on a job — flights, hotel, per diem, visa.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| service_job_id | UUID FK | Which job this expense relates to |
| technician_id | UUID FK | Whose expense this is |
| business_entity_id | UUID FK | Which entity is bearing this cost |
| expense_type | VARCHAR(30) | FLIGHT, ROAD_TRANSPORT, HOTEL, PER_DIEM, VISA, OTHER |
| amount | NUMERIC(15,2) | NPR amount |
| expense_date | DATE | When incurred |
| charge_to | VARCHAR(20) | CUSTOMER (bill the customer), SUPPLIER (claim from supplier), COMPANY (absorb) |
| reference | VARCHAR(100) | Receipt or ticket number |
| notes | TEXT | Notes |

---

### `travel_record`
The logistics of outstation travel — separate from expenses because you need to track the journey itself, not just the cost.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| service_job_id | UUID FK | Which job requires this travel |
| technician_id | UUID FK | Who is traveling |
| from_location | VARCHAR(100) | Origin |
| to_location | VARCHAR(100) | Destination — customer site |
| departure_date | DATE | When they left |
| return_date | DATE | When they returned |
| mode | VARCHAR(20) | FLIGHT, ROAD, OTHER |
| nights_stay | INTEGER | Directly drives hotel expense calculation |

---

## Module 8 — Finance

### `receivable`
Tracks what customers owe you. Created automatically when an invoice is issued. The finance team works from receivables — they track aging, send reminders, and record settlements here.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity is owed this money |
| customer_id | UUID FK | Who owes it |
| invoice_id | UUID FK | Which invoice created this receivable |
| original_amount | NUMERIC(15,2) | Full invoice amount in NPR |
| paid_amount | NUMERIC(15,2) | Amount received so far |
| balance | NUMERIC(15,2) | original minus paid |
| due_date | DATE | Payment deadline |
| status | VARCHAR(20) | OPEN, PARTIAL, PAID, OVERDUE |

---

### `payable`
Tracks what you owe suppliers. Created when goods are received against a purchase order.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity owes this money |
| supplier_id | UUID FK | Who is owed |
| purchase_order_id | UUID FK | Which PO created this payable |
| original_amount | NUMERIC(15,2) | Total amount owed in NPR |
| paid_amount | NUMERIC(15,2) | Amount paid so far |
| balance | NUMERIC(15,2) | Remaining amount |
| due_date | DATE | Payment deadline per agreed terms |
| status | VARCHAR(20) | OPEN, PARTIAL, PAID, OVERDUE |

---

### `supplier_payment`
Records money paid out to suppliers against payables.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity made the payment |
| payable_id | UUID FK | Which payable is being settled |
| supplier_id | UUID FK | Who was paid |
| payment_date | DATE | When payment was made |
| amount | NUMERIC(15,2) | NPR amount paid |
| payment_mode | VARCHAR(30) | BANK_TRANSFER, LC, CHEQUE, CASH |
| reference_number | VARCHAR(100) | Transaction reference for reconciliation |
| notes | TEXT | Notes |

---

### `inter_company_invoice`
The formal financial document generated when stock moves between entities. Entity B charges Entity A for transferred stock.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| from_entity_id | UUID FK | Entity supplying the stock — the creditor |
| to_entity_id | UUID FK | Entity receiving the stock — the debtor |
| invoice_number | VARCHAR(30) | Auto-generated inter-company invoice number |
| invoice_date | DATE | Date of transfer/invoice |
| amount | NUMERIC(15,2) | Settlement amount in NPR |
| status | VARCHAR(20) | PENDING (outstanding) or SETTLED (Entity A has paid Entity B) |
| inter_company_transfer_id | UUID FK | The stock transfer that triggered this invoice |

---

### `tally_export_log`
Audit trail for every Tally XML export. Prevents duplicates and allows re-download.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity's data was exported |
| export_type | VARCHAR(30) | SALES_VOUCHER, PURCHASE_VOUCHER, JOURNAL |
| from_date | DATE | Export date range start |
| to_date | DATE | Export date range end |
| exported_at | TIMESTAMP | When the export was generated |
| exported_by | UUID FK | Which user ran the export |
| file_s3_key | VARCHAR(255) | S3 location of the XML file — for re-download |
| record_count | INTEGER | Number of vouchers exported — sanity check for accountant |

---

### `document_sequence`
Generates sequential document numbers per entity per document type per year. Uses a database-level lock (`SELECT FOR UPDATE`) to prevent duplicate numbers under concurrent access.

| Column | Type | Purpose |
|---|---|---|
| id | UUID | Primary key |
| business_entity_id | UUID FK | Which entity's sequence |
| document_type | VARCHAR(20) | QT (quote), SO (sales order), INV (invoice), PO (purchase order), SJ (service job) |
| year | INTEGER | Sequence resets each year |
| last_sequence | INTEGER | Incremented atomically on each document creation |
