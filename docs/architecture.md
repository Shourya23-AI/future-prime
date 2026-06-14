# Future Prime — Architecture Document

## 1. Business Context

Future Prime is a Nepal-based trading and distribution business operating under three legal entities:

- **Prime Associate** — capital equipment trading (e.g. Concrete Batching Plants, industrial machinery)
- **Parina International** — general import/distribution
- **Future Prime EV** — electric vehicles and EV spare parts imported from China

### Key Business Characteristics
- Imports from India and China; sells in Nepal (NPR)
- Two distinct business models coexist (see Section 4)
- Employees are shared across all three entities
- Inventory is mixed — some stock is shared between entities
- After-sales service and warranty are critical revenue streams
- Nepal VAT (13%) applies to sales; no GST complexity
- Tally XML export required during transition period; system is self-contained long term

---

## 2. Architecture Decision: Modular Monolith

**Decision:** Single deployable Spring Boot application with well-defined internal module boundaries.

**Rationale:**
- Small team, MVP-first approach
- Modules share master data (products, customers, suppliers)
- No need for network overhead of microservices at this scale
- Can be split later if needed without rewriting business logic

**Not chosen:** Microservices — premature for this stage.

---

## 3. Technology Stack

| Layer | Technology | Version | Rationale |
|---|---|---|---|
| Language | Java | 21 (LTS) | Developer expertise, long-term support |
| Framework | Spring Boot | 3.5.14 | Production stable, Java 21 compatible |
| API | Spring MVC REST | — | Standard, well understood |
| ORM | Spring Data JPA + Hibernate | — | Industry standard for Java |
| DB Migrations | Flyway | — | Version-controlled schema changes |
| Security | Spring Security + JWT | — | Full control, no vendor lock-in |
| Database | PostgreSQL | 15+ | Strong relational integrity, JSON support |
| File Storage | Amazon S3 | — | Documents, PDFs, attachments |
| PDF Generation | iText 7 | — | Quote and invoice PDF export |
| Tally Export | Custom XML Writer | — | TDL-compatible XML generation |
| Build Tool | Maven | — | Developer familiarity |
| Deployment | AWS Elastic Beanstalk (single instance) | — | Free tier compatible |
| DB Hosting | Amazon RDS PostgreSQL (db.t3.micro) | — | Free tier compatible |
| Monitoring | AWS CloudWatch + Spring Actuator | — | AWS-native |
| IDE | IntelliJ IDEA | — | Best-in-class for Java |

---

## 4. Two Business Models

### Model 1 — Project / Order Based (Prime Associate)
- Customer order exists **before** purchase from supplier
- Example: Concrete Batching Plant
- One supplier → one customer (direct or via warehouse)
- Landed cost 100% attributable to that single order
- Involves commissioning, warranty, periodic service
- Flow: `Customer Enquiry → Quote → Order → Purchase → Import → Delivery → Commissioning → After-Sales`

### Model 2 — Batch Import / Stock and Sell (EV Company, Parina)
- Goods imported speculatively in batches
- Example: Electric Vehicles from China
- Stock held in warehouse, sold to multiple customers over time
- Landed cost split equally across batch units
- Flow: `Import Decision → Purchase → Shipment → Customs → Warehouse → Quote → Invoice → Delivery`

Both models share the same master data, inventory, and financial modules. The difference is in how purchase orders are triggered and how landed cost is allocated.

---

## 5. Multi-Entity Architecture

### Soft Multi-Tenancy with Entity Context Switching

All three business entities share one database. Every transactional record carries a `business_entity_id`.

**Users are shared** — an employee has one login but can be assigned to one or more entities. Their JWT token carries the currently active entity. They can switch context in the app.

**JWT Payload:**
```json
{
  "sub": "user@futureprime.com",
  "user_id": 101,
  "active_entity_id": 2,
  "accessible_entities": [1, 2, 3],
  "role": "MANAGER",
  "permissions": ["QUOTE_CREATE", "INVENTORY_VIEW"],
  "iat": 1700000000,
  "exp": 1700086400
}
```

### Inter-Company Transactions
When Entity A uses stock owned by Entity B:
1. A **stock transfer record** is created (inventory moves from B to A)
2. An **inter-company invoice** is generated (B charges A at agreed transfer price)
3. A **payable** is recorded on A, a **receivable** on B

Industry standard transfer pricing applies. The owner can override the transfer price per transaction.

### Reporting
- **Per-entity reports** — filter by `business_entity_id`
- **Consolidated reports** — no entity filter, aggregate across all three

---

## 6. Package Structure

```
com.futureprime/
├── core/
│   ├── config/          # Spring Security, JWT, CORS, S3, app config
│   ├── entity/          # Base JPA entity (id, createdAt, updatedAt, createdBy)
│   ├── exception/       # Global exception handler, custom exceptions
│   ├── dto/             # Shared DTOs, ApiResponse wrapper
│   └── util/            # Date utils, NPR formatting, PDF helpers
│
├── identity/
│   ├── entity/          # BusinessEntity, User, Role, Permission
│   ├── repository/
│   ├── service/         # Auth, JWT, user management
│   ├── dto/
│   └── controller/      # /api/v1/auth/**, /api/v1/users/**
│
├── master/
│   ├── entity/          # Customer, Supplier, Product, ProductCategory, UnitOfMeasure
│   ├── repository/
│   ├── service/
│   ├── dto/
│   └── controller/      # /api/v1/master/**
│
├── inventory/
│   ├── entity/          # Warehouse, StockItem, StockMovement, StockTransfer, SparePartStock
│   ├── repository/
│   ├── service/
│   ├── dto/
│   └── controller/      # /api/v1/inventory/**
│
├── trade/
│   ├── entity/          # Quote, QuoteLineItem, SalesOrder, Invoice, InvoiceLineItem, Payment
│   ├── repository/
│   ├── service/
│   ├── dto/
│   └── controller/      # /api/v1/trade/**
│
├── imports/
│   ├── entity/          # PurchaseOrder, Shipment, ShipmentCost, LandedCost, CustomsClearance, LCTracking
│   ├── repository/
│   ├── service/
│   ├── dto/
│   └── controller/      # /api/v1/imports/**
│
├── service/             # (after-sales module, not Spring "service" layer)
│   ├── entity/          # EquipmentUnit, WarrantyRecord, ServiceJob, ServiceVisit, AMCContract
│   ├── repository/
│   ├── service/
│   ├── dto/
│   └── controller/      # /api/v1/service/**
│
├── technician/
│   ├── entity/          # Technician, TechnicianType, ServiceExpense, TravelRecord
│   ├── repository/
│   ├── service/
│   ├── dto/
│   └── controller/      # /api/v1/technicians/**
│
├── finance/
│   ├── entity/          # Receivable, Payable, InterCompanyInvoice, TallyExportLog
│   ├── repository/
│   ├── service/
│   ├── dto/
│   └── controller/      # /api/v1/finance/**
│
└── reporting/
    ├── service/          # Cross-module aggregation queries
    ├── dto/
    └── controller/       # /api/v1/reports/**
```

---

## 7. API Design Conventions

- Base path: `/api/v1/`
- All responses wrapped in standard envelope:
```json
{
  "success": true,
  "data": { },
  "message": "Quote created successfully",
  "timestamp": "2024-01-15T10:30:00Z"
}
```
- Error responses:
```json
{
  "success": false,
  "error": "QUOTE_NOT_FOUND",
  "message": "Quote with id 123 not found",
  "timestamp": "2024-01-15T10:30:00Z"
}
```
- Pagination: `?page=0&size=20&sort=createdAt,desc`
- Entity context header: `X-Entity-Id: 2` (active business entity)

---

## 8. Security Model

### Roles
| Role | Description |
|---|---|
| `SUPER_ADMIN` | Owner — full access across all entities |
| `ENTITY_ADMIN` | Entity manager — full access within their entity |
| `SALES` | Create/view quotes and invoices |
| `WAREHOUSE` | Inventory management |
| `ACCOUNTS` | Finance module access |
| `TECHNICIAN` | Service jobs and expense logging |
| `VIEWER` | Read-only across assigned modules |

### Permissions
Fine-grained permissions per action: `QUOTE_CREATE`, `QUOTE_APPROVE`, `INVENTORY_ADJUST`, `INVOICE_VOID`, etc. Roles are bundles of permissions. The `SUPER_ADMIN` bypasses permission checks.

---

## 9. Deployment Architecture (Free Tier MVP)

```
Internet
    │
    ▼
AWS Elastic Beanstalk (Single Instance — t2.micro)
    │  Spring Boot JAR
    │
    ├──► Amazon RDS PostgreSQL (db.t3.micro, 20GB)
    │
    ├──► Amazon S3 (documents, PDFs, attachments)
    │
    └──► Amazon CloudWatch (logs, metrics)
```

**Important:** Configure Elastic Beanstalk as **single-instance** (no load balancer) to stay within free tier. Load balancer is not free.

**Estimated free tier duration:** 12 months from account creation date.

---

## 10. Non-Functional Decisions

| Concern | Decision |
|---|---|
| Audit trail | All entities extend `BaseEntity` with `createdAt`, `updatedAt`, `createdBy`, `updatedBy` |
| Soft delete | All master data uses `isActive` flag, never hard deleted |
| Currency | All amounts stored in NPR (Nepali Rupee) as `BigDecimal`. Exchange rate recorded at time of import for CNY/INR conversions |
| Timezone | Asia/Kathmandu (NPT, UTC+5:45) |
| Date format | ISO 8601 in API (yyyy-MM-dd), display format handled on frontend |
| VAT | Nepal VAT at 13% on applicable sales. Stored as a field, not hardcoded |
| Tally Export | XML format compatible with Tally TDL voucher import |
