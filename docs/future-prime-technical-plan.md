# Future Prime Technical Plan

## Purpose
Provide the technical implementation plan for building a centralized, mobile-first application that supports:
- quote generation
- inventory and spare parts management
- order/import tracking
- service and warranty management
- technician expense tracking
- remote access for multiple roles

## Recommended technology stack
- Frontend: `React Native`
- Backend: `Java` + `Spring Boot`
- Database: `Amazon RDS PostgreSQL`
- Storage: `Amazon S3`
- Deployment: `AWS Fargate` or `AWS Elastic Beanstalk`
- Authentication: `Spring Security` or `Amazon Cognito`

## Architecture
1. `React Native` mobile-first app
2. `Spring Boot` REST API backend
3. `PostgreSQL` database
4. `S3` for documents and attachments
5. Optional web portal using `React Native Web`

## Key modules
- Master data: companies, customers, products, racks, users, roles
- Quotes: create, edit, approve, convert to order, export PDF
- Inventory: stock receipt, rack location, stock balance, low-stock alerts
- Orders & shipments: inbound import shipment tracking, warehouse receipt, outbound local delivery tracking, LC status, customs clearance, delivery status
- Service & warranty: service tracking, service history, due reminders
- Technician: assignments, attendance, TA/DA, stay, expenses
- Reporting: inventory alerts, margin, order status, service due lists

## MVP phases
### Phase 1 — MVP
- Authentication and user roles
- Customer and product master data
- Quote creation and storage
- Inventory receipt and stock view
- Mobile-first UI
- Basic reporting

### Phase 2 — Core operations
- Quote approval and order conversion
- LC/shipment/customs tracking
- Rack management
- Warranty/service tracking
- Technician expense logging

### Phase 3 — Automation and polish
- Low-stock notifications
- Service due reminders
- Data import helpers for Word/Excel
- AWS deployment hardening and monitoring

## AWS deployment plan
- Backend: `AWS Fargate` or `Elastic Beanstalk`
- Database: `Amazon RDS PostgreSQL`
- Storage: `Amazon S3`
- Authentication: `Amazon Cognito` or JWT
- Monitoring: `Amazon CloudWatch`

## Next steps for the technical engineer
1. Define roles and permissions
2. Capture sample quote and inventory formats
3. Finalize data model and APIs
4. Build MVP screens for quote and inventory
5. Deploy the first version on AWS
