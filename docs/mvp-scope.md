# Future Prime — MVP Scope

## Guiding Principle

Deliver value to the business fast. The MVP is not a stripped-down version — it is the **core operational loop** that replaces manual work immediately. Everything else is Phase 2 or Phase 3.

The three business-critical flows that justify the entire system:
1. **Quote → Invoice** (sales operations)
2. **Inventory & Stock** (warehouse operations)
3. **Import Shipment Tracking** (inbound operations)

---

## Phase 1 — MVP (Target: 8–10 weeks)

### What we build

#### Foundation (Week 1–2)
- Spring Boot project setup with all dependencies
- Database schema via Flyway (all tables from data-model.md — design upfront, build incrementally)
- Base entity classes, exception handling, API response wrapper
- JWT authentication — login, refresh, logout
- Business entity management (3 entities)
- User management with entity-role assignment
- Entity context switching in JWT

**Deliverable:** Secure login, user can switch between Prime Associate / Parina / EV entity.

---

#### Master Data (Week 2–3)
- Customer CRUD (with entity mapping for shared customers)
- Supplier CRUD
- Product CRUD (with product type: EQUIPMENT, EV, SPARE_PART, CONSUMABLE)
- Product categories
- Units of measure
- Warehouse and rack location setup

**Deliverable:** Owner/admin can set up all master data. System is ready for transactions.

---

#### Quote to Invoice (Week 3–5)
- Quote creation with line items
- Quote number auto-generation (PA-QT-2024-0001)
- Quote status workflow: DRAFT → SENT → APPROVED → CONVERTED
- Quote approval (by ENTITY_ADMIN)
- Convert quote to Sales Order
- Generate Invoice from Sales Order
- Invoice PDF generation (iText 7) — company letterhead, VAT breakdown, NPR amounts
- Record payment receipt against invoice
- Receivables tracking (what customers owe)

**Deliverable:** Sales team can create quotes on system, get them approved, issue invoices, record payments. Replaces manual quote books immediately.

---

#### Inventory (Week 5–7)
- Stock receipt (goods received into warehouse — from purchase, triggers stock movement)
- Stock view — current stock by product, by warehouse, by entity
- Stock movement history (full audit trail)
- Manual stock adjustment with reason
- Low stock alerts (products below minimum threshold)
- Spare parts stock (same module, flagged as spare part type)

**Deliverable:** Warehouse team knows exactly what stock they have at any point. No more manual registers.

---

#### Import Shipment Tracking (Week 7–9)
- Purchase order creation (linked to supplier, optionally to sales order for PROJECT_BASED)
- Shipment creation and status tracking (IN_TRANSIT → ARRIVED → CUSTOMS_CLEARED → DELIVERED)
- Shipment cost recording (freight, customs duty, VAT on import, agent fee)
- Landed cost calculation per unit (auto-allocated across products in shipment)
- Goods receipt — shipment received into warehouse (triggers stock movement with correct landed cost)
- Basic customs clearance record

**Deliverable:** Management can see status of every inbound shipment. Landed cost is calculated automatically. Stock is updated on receipt.

---

#### Tally Export — Basic (Week 9–10)
- Export sales vouchers (invoices) to Tally XML
- Export date range selection per entity
- Download XML file (stored on S3)
- Export history log

**Deliverable:** Accountant can export and import into Tally monthly. No double entry for sales.

---

### What the MVP does NOT include (deferred)

| Feature | Deferred to | Reason |
|---|---|---|
| Inter-company stock transfer with invoice | Phase 2 | Needs both entities live first |
| LC (Letter of Credit) tracking | Phase 2 | Complex, handle manually for now |
| Service & warranty module | Phase 2 | After sales team is on the system |
| AMC contracts | Phase 2 | |
| Equipment unit registration | Phase 2 | |
| Technician expense tracking | Phase 2 | |
| Payables (supplier payment tracking) | Phase 2 | Tally handles this during transition |
| Inter-company invoices | Phase 2 | |
| Consolidated cross-entity reporting | Phase 2 | |
| Tally export for purchase vouchers | Phase 2 | |
| P&L reporting | Phase 3 | |
| Bank reconciliation | Out of scope | CA handles in Tally |
| GST / TDS | Out of scope | Not applicable (Nepal business) |

---

## Phase 2 — Core Operations (Target: Weeks 11–20)

- Inter-company stock transfers with auto-generated inter-company invoice
- LC tracking (Letter of Credit management)
- Equipment unit registration on delivery
- Warranty records and free service entitlement
- Service job creation and management
- Service visit logging (technician, parts used, time)
- AMC contract management
- Technician management (supplier + local)
- Technician expense logging per job
- Travel records for outstation jobs
- Payables — supplier bill entry and payment tracking
- Tally export for purchase vouchers and journals
- Receivables aging report
- Shipment status dashboard

---

## Phase 3 — Full ERP (Target: Weeks 21–30)

- Full reporting suite — P&L per entity, consolidated
- Margin analysis per order/project
- Service billing — invoices for paid service jobs
- AMC renewal alerts
- Warranty expiry alerts
- Low-stock alerts with suggested reorder
- Data import helpers (bulk upload products/customers from Excel)
- Role and permission fine-tuning based on real usage
- Tally export sunset — full onboarding complete
- AWS deployment hardening (backups, monitoring alerts, cost review)

---

## Definition of Done for MVP

The MVP is complete when:

- [ ] Owner can log in and switch between all 3 entities
- [ ] Sales team can create a quote, get it approved, convert to invoice, record payment
- [ ] Invoice PDF can be downloaded with correct NPR amounts and VAT
- [ ] Warehouse team can see current stock for all products
- [ ] Stock is updated automatically when a shipment is received
- [ ] Landed cost per unit is calculated and stored on shipment receipt
- [ ] Accountant can export invoices to Tally XML for a date range
- [ ] All data is isolated by business entity
- [ ] Deployed on AWS (Elastic Beanstalk + RDS) and accessible remotely

---

## MVP Success Metric

Within 4 weeks of go-live, the sales team stops using paper quote books and the warehouse stops using manual stock registers. If those two things happen, the MVP has succeeded.
