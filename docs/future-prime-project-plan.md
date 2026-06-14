# Future Prime Project Plan

## 1) Overall goal
Build a centralized, mobile-first application for:
- quote generation
- inventory and spare parts management
- order/import tracking
- service/warranty management
- technician expense tracking
- multi-role remote access

---

## 2) Proposed product modules

### Module A — Master data
- Companies / business units: `Prime Associates`, `Parina International`, `Prime Motors`
- Customers / contractors / suppliers
- Products / spare parts catalog
- Rack/location master
- User roles and permissions

### Module B — Sales & quotes
- Create and edit quotations
- Store quote price vs purchase cost
- Approve/reject quote workflow
- Convert quote to order
- Export quote as PDF

### Module C — Inventory management
- Receive stock into inventory
- Rack location assignment
- Track purchase cost, extra expenses, sales price
- Stock balances: available, sold, reserved
- Low-stock alerts
- Inventory audit history

### Module D — Order & import tracking
- Purchase order / LC status
- Supplier order details
- Transport / shipment tracking
- Customs clearance stages
- Delivery to Nepal site

### Module E — Service & warranty
- Track free service duration or number of services
- Product service history
- Service due reminders
- Warranty expiry and service limits

### Module F — Technician management
- Technician assignments
- Attendance tracking
- TA/DA, stay, travel expenses
- Expense approval workflow

### Module G — Reporting & notifications
- Inventory running out
- Sales margin and profit
- Order status
- Service due lists
- Technician expense summary

---

## 3) MVP plan and timeline

### Phase 1 — MVP (4–6 weeks)
Focus on the most critical automation:
- User login + roles
- Customer and product master
- Quote creation and storage
- Inventory receipt + stock view
- Mobile-first UI
- Basic reporting: stock and quotes

### Phase 2 — Core operations (4–6 weeks)
Add operational workflows:
- Quote approval and order conversion
- LC / shipment / customs tracking
- Rack location management
- Warranty/service tracking
- Technician expense logging

### Phase 3 — Automation and polish (3–4 weeks)
Complete with automation and quality:
- Low-stock alerts
- Service due notifications
- Mobile app quality improvements
- Data import helpers for Excel/Word
- AWS deployment hardening and monitoring

---

## 4) Key data model outline

### Main entities
- `Company`
- `User`
- `Role`
- `Customer`
- `Product`
- `InventoryItem`
- `RackLocation`
- `Quote`
- `QuoteLineItem`
- `Order`
- `Shipment`
- `CustomClearance`
- `ServiceContract`
- `ServiceEvent`
- `Technician`
- `Expense`

### Important relationships
- `Quote` → `Customer`
- `Quote` → `QuoteLineItem`
- `Order` ← `Quote`
- `InventoryItem` ↔ `RackLocation`
- `ServiceContract` → `Customer` + `Product`
- `Expense` → `Technician`

---

## 5) Recommended technology architecture

### Frontend
- `React Native`
- Optional reuse for web via `React Native Web`
- Mobile-first design
- Offline-friendly lookups for inventory/quotes if needed later

### Backend
- `Java` + `Spring Boot`
- REST API
- `Spring Security` for authentication and RBAC

### Database
- `Amazon RDS PostgreSQL`

### Storage
- `Amazon S3` for attachments and PDFs

### Deployment
- `AWS Fargate` or `AWS Elastic Beanstalk` for backend
- `Amazon RDS` for database
- `Amazon S3` for files
- `Amazon Cognito` for managed authentication (optional)

---

## 6) AWS deployment plan

### Recommended stack
- Backend service: `AWS Fargate` or `Elastic Beanstalk`
- Database: `Amazon RDS PostgreSQL`
- File storage: `Amazon S3`
- Authentication: `Amazon Cognito` or secure JWT
- Monitoring: `CloudWatch`
- Optional web acceleration: `CloudFront`

### Why AWS
- Remote access from anywhere
- Scalable performance
- Managed backup and recovery
- Secure access control

---

## 7) Next steps for implementation

### For the technical engineer
1. Define exact user roles and permissions
2. Capture sample quote template and inventory Excel structure
3. Finalize data model and API design
4. Build MVP screens for quote + inventory
5. Deploy first version on AWS

### For the non-technical owner
1. Review and approve the refined requirements
2. Confirm priority workflows:
   - quote creation
   - inventory tracking
   - order/shipment status
3. Decide which features must be live in the first version
4. Share sample documents and Excel files

---

## 8) What I can provide next
- Detailed module-by-module requirements
- Full entity relationship diagram
- API contract outline
- Exact MVP delivery plan with tasks
- AWS deployment architecture diagram

If you want, I can prepare the next version as:
- `Project Requirements Document`
- `MVP Feature List`
- `Implementation Roadmap`
