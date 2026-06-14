# Future Prime — Complete Data Model

All tables inherit `id` (UUID), `created_at`, `updated_at`, `created_by`, `updated_by` from a base entity unless noted.
Flyway migration scripts must be created in the order sections appear in this document.

---

## Migration Order

```
V1__create_identity.sql
V2__create_master.sql
V3__create_inventory.sql
V4__create_trade.sql
V5__create_imports.sql
V6__create_service.sql
V7__create_technician.sql
V8__create_finance.sql
```

---

## 1. Identity Module

### business_entity
Represents Prime Associate, Parina International, Future Prime EV.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | VARCHAR(100) | e.g. "Prime Associate" |
| short_code | VARCHAR(10) | e.g. "PA", "PI", "EV" |
| address | TEXT | |
| pan_number | VARCHAR(20) | Nepal PAN |
| vat_number | VARCHAR(20) | Nepal VAT registration |
| phone | VARCHAR(20) | |
| email | VARCHAR(100) | |
| logo_s3_key | VARCHAR(255) | S3 key for logo |
| is_active | BOOLEAN | default true |

### app_user
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| full_name | VARCHAR(100) | |
| email | VARCHAR(100) | UNIQUE, used as username |
| password_hash | VARCHAR(255) | BCrypt |
| phone | VARCHAR(20) | |
| is_active | BOOLEAN | default true |
| last_login_at | TIMESTAMP | |

### role
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | VARCHAR(50) | SUPER_ADMIN, ENTITY_ADMIN, SALES, WAREHOUSE, ACCOUNTS, TECHNICIAN, VIEWER |
| description | VARCHAR(255) | |

### permission
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| code | VARCHAR(100) | e.g. QUOTE_CREATE, INVENTORY_ADJUST |
| description | VARCHAR(255) | |
| module | VARCHAR(50) | e.g. TRADE, INVENTORY |

### role_permission (join)
| Column | Type |
|---|---|
| role_id | UUID FK → role |
| permission_id | UUID FK → permission |

### user_entity_role
Maps a user to a business entity with a specific role. A user can have different roles in different entities.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK → app_user | |
| business_entity_id | UUID FK → business_entity | |
| role_id | UUID FK → role | |
| is_active | BOOLEAN | default true |

### refresh_token
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK → app_user | |
| token | VARCHAR(512) | UNIQUE |
| expires_at | TIMESTAMP | |
| is_revoked | BOOLEAN | default false |

---

## 2. Master Data Module

### customer
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| primary_entity_id | UUID FK → business_entity | Which entity primarily owns this customer |
| name | VARCHAR(150) | |
| type | VARCHAR(30) | INDIVIDUAL, COMPANY |
| pan_number | VARCHAR(20) | |
| vat_number | VARCHAR(20) | |
| billing_address | TEXT | |
| shipping_address | TEXT | |
| phone | VARCHAR(20) | |
| email | VARCHAR(100) | |
| credit_limit | NUMERIC(15,2) | NPR |
| credit_days | INTEGER | Payment terms in days |
| is_active | BOOLEAN | |

### customer_entity (join)
Allows a customer to be accessible by multiple entities.

| Column | Type |
|---|---|
| customer_id | UUID FK → customer |
| business_entity_id | UUID FK → business_entity |

### supplier
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | VARCHAR(150) | |
| country | VARCHAR(50) | INDIA, CHINA, OTHER |
| is_mother_company | BOOLEAN | True if they also send technicians |
| contact_person | VARCHAR(100) | |
| phone | VARCHAR(20) | |
| email | VARCHAR(100) | |
| address | TEXT | |
| payment_terms | VARCHAR(100) | e.g. "30 days", "LC at sight" |
| currency | VARCHAR(10) | INR, CNY, USD |
| is_active | BOOLEAN | |

### product_category
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | VARCHAR(100) | e.g. "Construction Equipment", "Electric Vehicles" |
| parent_id | UUID FK → product_category | For subcategories, nullable |
| is_active | BOOLEAN | |

### unit_of_measure
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | VARCHAR(50) | e.g. "Pieces", "Sets", "Kg" |
| abbreviation | VARCHAR(10) | e.g. "PCS", "KG" |

### product
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | Which entity this product belongs to |
| category_id | UUID FK → product_category | |
| supplier_id | UUID FK → supplier | Primary supplier |
| name | VARCHAR(200) | |
| model_number | VARCHAR(100) | |
| description | TEXT | |
| uom_id | UUID FK → unit_of_measure | |
| product_type | VARCHAR(30) | EQUIPMENT, EV, SPARE_PART, CONSUMABLE |
| business_model | VARCHAR(30) | PROJECT_BASED, BATCH_IMPORT |
| has_warranty | BOOLEAN | |
| warranty_months | INTEGER | |
| has_free_service | BOOLEAN | |
| free_service_count | INTEGER | |
| is_active | BOOLEAN | |

### spare_part_mapping
Maps spare parts to parent equipment products.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| equipment_product_id | UUID FK → product | Parent equipment |
| spare_part_product_id | UUID FK → product | The spare part |
| is_critical | BOOLEAN | Critical parts need min stock |
| min_stock_quantity | NUMERIC(10,2) | Alert threshold |

---

## 3. Inventory Module

### warehouse
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | Which entity operates this warehouse |
| name | VARCHAR(100) | |
| address | TEXT | |
| is_active | BOOLEAN | |

### rack_location
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| warehouse_id | UUID FK → warehouse | |
| code | VARCHAR(30) | e.g. "A-01-03" (Aisle-Row-Shelf) |
| description | VARCHAR(100) | |
| is_active | BOOLEAN | |

### stock_item
Current stock level per product per entity per warehouse. One record per (product, business_entity, warehouse).

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| product_id | UUID FK → product | |
| business_entity_id | UUID FK → business_entity | Who owns this stock |
| warehouse_id | UUID FK → warehouse | Where it physically is |
| rack_location_id | UUID FK → rack_location | Nullable |
| quantity_on_hand | NUMERIC(10,2) | |
| quantity_reserved | NUMERIC(10,2) | Reserved for open orders |
| quantity_available | NUMERIC(10,2) | on_hand - reserved (computed) |
| average_landed_cost | NUMERIC(15,2) | NPR — weighted average, updated on each receipt |
| last_movement_at | TIMESTAMP | |

### stock_movement
Every change to stock is recorded here. Full audit trail.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| stock_item_id | UUID FK → stock_item | |
| business_entity_id | UUID FK → business_entity | |
| movement_type | VARCHAR(30) | RECEIPT, SALE, TRANSFER_OUT, TRANSFER_IN, ADJUSTMENT, RETURN |
| quantity | NUMERIC(10,2) | Always positive; direction determined by type |
| unit_cost | NUMERIC(15,2) | NPR at time of movement |
| reference_type | VARCHAR(30) | PURCHASE_ORDER, SALES_ORDER, TRANSFER, ADJUSTMENT |
| reference_id | UUID | FK to the triggering document |
| notes | TEXT | |
| movement_date | DATE | |

### inter_company_transfer
When one entity's stock is transferred to another.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| from_entity_id | UUID FK → business_entity | |
| to_entity_id | UUID FK → business_entity | |
| product_id | UUID FK → product | |
| quantity | NUMERIC(10,2) | |
| transfer_price | NUMERIC(15,2) | NPR — agreed transfer price |
| transfer_date | DATE | |
| status | VARCHAR(20) | PENDING, CONFIRMED, CANCELLED |
| from_stock_movement_id | UUID FK → stock_movement | |
| to_stock_movement_id | UUID FK → stock_movement | |
| inter_company_invoice_id | UUID FK → inter_company_invoice | Created on confirmation |
| notes | TEXT | |

---

## 4. Trade Module

### quote
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| customer_id | UUID FK → customer | |
| quote_number | VARCHAR(30) | Auto-generated, e.g. "PA-QT-2024-0001" |
| quote_date | DATE | |
| valid_until | DATE | |
| business_model | VARCHAR(30) | PROJECT_BASED or BATCH_IMPORT |
| status | VARCHAR(20) | DRAFT, SENT, APPROVED, REJECTED, CONVERTED, EXPIRED |
| subtotal | NUMERIC(15,2) | NPR before VAT |
| vat_amount | NUMERIC(15,2) | 13% of taxable items |
| total_amount | NUMERIC(15,2) | NPR |
| terms_and_conditions | TEXT | |
| notes | TEXT | |
| approved_by | UUID FK → app_user | Nullable |
| approved_at | TIMESTAMP | Nullable |

### quote_line_item
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| quote_id | UUID FK → quote | |
| product_id | UUID FK → product | |
| description | VARCHAR(500) | Can override product name for custom items |
| quantity | NUMERIC(10,2) | |
| unit_price | NUMERIC(15,2) | NPR |
| discount_percent | NUMERIC(5,2) | |
| vat_applicable | BOOLEAN | |
| line_total | NUMERIC(15,2) | After discount, before VAT |
| sort_order | INTEGER | Display order on quote |

### sales_order
Created when a quote is approved and converted.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| quote_id | UUID FK → quote | Nullable for direct orders |
| customer_id | UUID FK → customer | |
| order_number | VARCHAR(30) | e.g. "PA-SO-2024-0001" |
| order_date | DATE | |
| expected_delivery_date | DATE | |
| delivery_address | TEXT | |
| status | VARCHAR(20) | CONFIRMED, IN_PROGRESS, PARTIALLY_DELIVERED, DELIVERED, CANCELLED |
| business_model | VARCHAR(30) | PROJECT_BASED or BATCH_IMPORT |
| notes | TEXT | |

### sales_order_line_item
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| sales_order_id | UUID FK → sales_order | |
| product_id | UUID FK → product | |
| quantity_ordered | NUMERIC(10,2) | |
| quantity_delivered | NUMERIC(10,2) | Updated on delivery |
| unit_price | NUMERIC(15,2) | NPR |
| discount_percent | NUMERIC(5,2) | |
| vat_applicable | BOOLEAN | |

### invoice
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| sales_order_id | UUID FK → sales_order | Nullable for direct invoices |
| customer_id | UUID FK → customer | |
| invoice_number | VARCHAR(30) | e.g. "PA-INV-2024-0001" |
| invoice_date | DATE | |
| due_date | DATE | Based on credit_days |
| status | VARCHAR(20) | DRAFT, ISSUED, PARTIALLY_PAID, PAID, OVERDUE, VOID |
| subtotal | NUMERIC(15,2) | |
| vat_amount | NUMERIC(15,2) | |
| total_amount | NUMERIC(15,2) | |
| paid_amount | NUMERIC(15,2) | Updated as payments come in |
| balance_due | NUMERIC(15,2) | total - paid |
| pdf_s3_key | VARCHAR(255) | S3 key for generated PDF |
| notes | TEXT | |

### invoice_line_item
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| invoice_id | UUID FK → invoice | |
| product_id | UUID FK → product | |
| description | VARCHAR(500) | |
| quantity | NUMERIC(10,2) | |
| unit_price | NUMERIC(15,2) | |
| discount_percent | NUMERIC(5,2) | |
| vat_applicable | BOOLEAN | |
| line_total | NUMERIC(15,2) | |

### payment_receipt
Customer payments against invoices.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| invoice_id | UUID FK → invoice | |
| customer_id | UUID FK → customer | |
| receipt_number | VARCHAR(30) | |
| payment_date | DATE | |
| amount | NUMERIC(15,2) | NPR |
| payment_mode | VARCHAR(30) | CASH, BANK_TRANSFER, CHEQUE, OTHER |
| reference_number | VARCHAR(100) | Cheque/transaction number |
| notes | TEXT | |

---

## 5. Imports Module

### purchase_order
Order placed with an Indian or Chinese supplier.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| supplier_id | UUID FK → supplier | |
| sales_order_id | UUID FK → sales_order | Nullable — set for PROJECT_BASED model |
| po_number | VARCHAR(30) | e.g. "PA-PO-2024-0001" |
| po_date | DATE | |
| supplier_currency | VARCHAR(10) | INR or CNY |
| exchange_rate | NUMERIC(10,4) | Rate to NPR at PO date |
| status | VARCHAR(20) | DRAFT, SENT, ACKNOWLEDGED, SHIPPED, RECEIVED, CANCELLED |
| payment_terms | VARCHAR(100) | |
| lc_required | BOOLEAN | Whether LC (Letter of Credit) needed |
| notes | TEXT | |

### purchase_order_line_item
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| purchase_order_id | UUID FK → purchase_order | |
| product_id | UUID FK → product | |
| quantity | NUMERIC(10,2) | |
| unit_price | NUMERIC(15,2) | In supplier currency |
| line_total | NUMERIC(15,2) | In supplier currency |

### lc_tracking
Letter of Credit management for high-value imports.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| purchase_order_id | UUID FK → purchase_order | |
| lc_number | VARCHAR(50) | |
| bank_name | VARCHAR(100) | |
| lc_amount | NUMERIC(15,2) | |
| lc_currency | VARCHAR(10) | |
| issue_date | DATE | |
| expiry_date | DATE | |
| status | VARCHAR(20) | APPLIED, ISSUED, AMENDED, UTILIZED, EXPIRED |
| notes | TEXT | |

### shipment
One shipment can cover one or more purchase orders.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| shipment_number | VARCHAR(50) | Internal reference |
| origin_country | VARCHAR(50) | INDIA or CHINA |
| shipment_mode | VARCHAR(20) | ROAD, AIR, SEA |
| carrier_name | VARCHAR(100) | |
| bl_number | VARCHAR(50) | Bill of Lading / Airway Bill |
| departure_date | DATE | |
| estimated_arrival_date | DATE | |
| actual_arrival_date | DATE | |
| status | VARCHAR(30) | IN_TRANSIT, ARRIVED, CUSTOMS_HOLD, CUSTOMS_CLEARED, DELIVERED_TO_WAREHOUSE |
| notes | TEXT | |

### shipment_purchase_order (join)
| Column | Type |
|---|---|
| shipment_id | UUID FK → shipment |
| purchase_order_id | UUID FK → purchase_order |

### customs_clearance
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| shipment_id | UUID FK → shipment | |
| customs_agent | VARCHAR(100) | |
| entry_number | VARCHAR(50) | Customs entry/bill of entry number |
| entry_date | DATE | |
| customs_duty | NUMERIC(15,2) | NPR |
| vat_on_import | NUMERIC(15,2) | NPR |
| other_charges | NUMERIC(15,2) | NPR |
| total_customs_cost | NUMERIC(15,2) | NPR |
| clearance_date | DATE | |
| status | VARCHAR(20) | SUBMITTED, UNDER_REVIEW, CLEARED, HELD |
| notes | TEXT | |

### shipment_cost
All costs associated with a shipment, used to calculate landed cost.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| shipment_id | UUID FK → shipment | |
| cost_type | VARCHAR(50) | FREIGHT, CUSTOMS_DUTY, VAT_ON_IMPORT, INSURANCE, LOCAL_TRANSPORT, AGENT_FEE, OTHER |
| amount | NUMERIC(15,2) | NPR |
| description | VARCHAR(255) | |

### landed_cost_allocation
How shipment costs are distributed per product in the shipment.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| shipment_id | UUID FK → shipment | |
| purchase_order_line_item_id | UUID FK → purchase_order_line_item | |
| product_id | UUID FK → product | |
| quantity | NUMERIC(10,2) | |
| supplier_cost_npr | NUMERIC(15,2) | Converted to NPR |
| allocated_shipment_cost | NUMERIC(15,2) | Proportional share of shipment costs |
| landed_cost_per_unit | NUMERIC(15,2) | Total cost / quantity |

---

## 6. Service Module (After-Sales)

### equipment_unit
Every sold unit of equipment/EV that needs after-sales tracking gets a unique record.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| product_id | UUID FK → product | |
| customer_id | UUID FK → customer | |
| invoice_id | UUID FK → invoice | The sale that created this unit |
| serial_number | VARCHAR(100) | Manufacturer serial or internal |
| delivery_date | DATE | |
| commissioning_date | DATE | |
| installation_address | TEXT | Where the equipment is located |
| status | VARCHAR(20) | ACTIVE, DECOMMISSIONED, RETURNED |

### warranty_record
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| equipment_unit_id | UUID FK → equipment_unit | |
| warranty_type | VARCHAR(30) | PARTS, LABOUR, COMPREHENSIVE |
| start_date | DATE | Usually commissioning date |
| end_date | DATE | |
| terms | TEXT | What is covered |
| is_active | BOOLEAN | |

### free_service_entitlement
Tracks free periodic services included in the sale.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| equipment_unit_id | UUID FK → equipment_unit | |
| total_free_services | INTEGER | From product definition |
| used_free_services | INTEGER | Incremented on each free visit |
| remaining_free_services | INTEGER | Computed |

### amc_contract
Annual Maintenance Contract.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| equipment_unit_id | UUID FK → equipment_unit | |
| customer_id | UUID FK → customer | |
| contract_number | VARCHAR(30) | |
| start_date | DATE | |
| end_date | DATE | |
| amount | NUMERIC(15,2) | NPR — contract value |
| payment_status | VARCHAR(20) | UNPAID, PAID, PARTIAL |
| visits_included | INTEGER | Number of service visits in contract |
| visits_used | INTEGER | |
| status | VARCHAR(20) | ACTIVE, EXPIRED, CANCELLED |

### service_job
A service request/job for an equipment unit.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| equipment_unit_id | UUID FK → equipment_unit | |
| customer_id | UUID FK → customer | |
| job_number | VARCHAR(30) | |
| job_type | VARCHAR(30) | WARRANTY, FREE_PERIODIC, PAID_PERIODIC, PAID_ON_DEMAND, AMC, COMMISSIONING |
| amc_contract_id | UUID FK → amc_contract | Nullable |
| reported_issue | TEXT | |
| diagnosis | TEXT | |
| resolution | TEXT | |
| status | VARCHAR(20) | OPEN, ASSIGNED, IN_PROGRESS, COMPLETED, CANCELLED |
| scheduled_date | DATE | |
| completed_date | DATE | |
| is_billable | BOOLEAN | False for warranty/free service |
| invoice_id | UUID FK → invoice | Nullable — for billable jobs |

### service_visit
Each visit by a technician to a job site.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| service_job_id | UUID FK → service_job | |
| technician_id | UUID FK → technician | |
| visit_date | DATE | |
| time_in | TIME | |
| time_out | TIME | |
| work_done | TEXT | |
| parts_used | TEXT | Summary, detailed in service_part_usage |
| follow_up_required | BOOLEAN | |

### service_part_usage
Parts consumed during a service visit.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| service_visit_id | UUID FK → service_visit | |
| product_id | UUID FK → product | The spare part |
| quantity | NUMERIC(10,2) | |
| unit_cost | NUMERIC(15,2) | NPR — from stock |
| is_billable | BOOLEAN | |
| charge_to | VARCHAR(20) | CUSTOMER, SUPPLIER (warranty claim), COMPANY |

---

## 7. Technician Module

### technician
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | VARCHAR(100) | |
| technician_type | VARCHAR(20) | SUPPLIER (mother company), LOCAL |
| supplier_id | UUID FK → supplier | Nullable — set for SUPPLIER type |
| phone | VARCHAR(20) | |
| email | VARCHAR(100) | |
| country | VARCHAR(50) | NEPAL, INDIA, CHINA |
| specialization | VARCHAR(100) | e.g. "Concrete Equipment", "EV" |
| is_active | BOOLEAN | |

### technician_expense
All expenses for a technician on a job.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| service_job_id | UUID FK → service_job | |
| technician_id | UUID FK → technician | |
| business_entity_id | UUID FK → business_entity | Who is bearing this cost |
| expense_type | VARCHAR(30) | FLIGHT, ROAD_TRANSPORT, HOTEL, PER_DIEM, VISA, OTHER |
| amount | NUMERIC(15,2) | NPR |
| expense_date | DATE | |
| charge_to | VARCHAR(20) | CUSTOMER, SUPPLIER, COMPANY |
| reference | VARCHAR(100) | Receipt/ticket number |
| notes | TEXT | |

### travel_record
Outstation travel details for a technician.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| service_job_id | UUID FK → service_job | |
| technician_id | UUID FK → technician | |
| from_location | VARCHAR(100) | |
| to_location | VARCHAR(100) | |
| departure_date | DATE | |
| return_date | DATE | |
| mode | VARCHAR(20) | FLIGHT, ROAD, OTHER |
| nights_stay | INTEGER | |

---

## 8. Finance Module

### receivable
Tracks outstanding amounts owed by customers. Created from invoices.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| customer_id | UUID FK → customer | |
| invoice_id | UUID FK → invoice | |
| original_amount | NUMERIC(15,2) | NPR |
| paid_amount | NUMERIC(15,2) | NPR |
| balance | NUMERIC(15,2) | NPR |
| due_date | DATE | |
| status | VARCHAR(20) | OPEN, PARTIAL, PAID, OVERDUE |

### payable
Tracks outstanding amounts owed to suppliers. Created from purchase orders/bills.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| supplier_id | UUID FK → supplier | |
| purchase_order_id | UUID FK → purchase_order | |
| original_amount | NUMERIC(15,2) | NPR |
| paid_amount | NUMERIC(15,2) | |
| balance | NUMERIC(15,2) | |
| due_date | DATE | |
| status | VARCHAR(20) | OPEN, PARTIAL, PAID, OVERDUE |

### supplier_payment
Payments made to suppliers.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| payable_id | UUID FK → payable | |
| supplier_id | UUID FK → supplier | |
| payment_date | DATE | |
| amount | NUMERIC(15,2) | NPR |
| payment_mode | VARCHAR(30) | BANK_TRANSFER, LC, CHEQUE, CASH |
| reference_number | VARCHAR(100) | |
| notes | TEXT | |

### inter_company_invoice
Generated when stock is transferred between entities.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| from_entity_id | UUID FK → business_entity | Supplier entity |
| to_entity_id | UUID FK → business_entity | Buyer entity |
| invoice_number | VARCHAR(30) | |
| invoice_date | DATE | |
| amount | NUMERIC(15,2) | NPR |
| status | VARCHAR(20) | PENDING, SETTLED, CANCELLED |
| inter_company_transfer_id | UUID FK → inter_company_transfer | |

### tally_export_log
Tracks what has been exported to Tally XML.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| export_type | VARCHAR(30) | SALES_VOUCHER, PURCHASE_VOUCHER, JOURNAL |
| from_date | DATE | |
| to_date | DATE | |
| exported_at | TIMESTAMP | |
| exported_by | UUID FK → app_user | |
| file_s3_key | VARCHAR(255) | S3 key of the generated XML |
| record_count | INTEGER | Number of vouchers exported |

---

## Key Relationships Summary

```
business_entity ──< user_entity_role >── app_user
business_entity ──< product
business_entity ──< customer (via customer_entity)
business_entity ──< purchase_order ──< purchase_order_line_item
purchase_order ──< shipment (via join)
shipment ──< shipment_cost
shipment ──< landed_cost_allocation
customer ──< quote ──< quote_line_item
quote ──> sales_order ──< sales_order_line_item
sales_order ──> invoice ──< invoice_line_item
invoice ──< payment_receipt
invoice ──> equipment_unit ──> warranty_record
equipment_unit ──< service_job ──< service_visit ──< service_part_usage
service_job ──< technician_expense
inter_company_transfer ──> inter_company_invoice
```

---

## Number Generation Pattern

All document numbers are auto-generated using this pattern:
`{ENTITY_CODE}-{DOC_TYPE}-{YEAR}-{SEQUENCE}`

Examples:
- `PA-QT-2024-0001` — Prime Associate Quote 1
- `PI-INV-2024-0023` — Parina International Invoice 23
- `EV-PO-2024-0005` — EV Company Purchase Order 5

Sequence resets per year per entity per document type. Implement as a `document_sequence` table with a database-level lock to avoid duplicates under concurrent access.

### document_sequence
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_entity_id | UUID FK → business_entity | |
| document_type | VARCHAR(20) | QT, SO, INV, PO, SJ, etc. |
| year | INTEGER | |
| last_sequence | INTEGER | Incremented atomically |
