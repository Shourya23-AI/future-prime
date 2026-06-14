# Future Prime — API Design

## Conventions

- Base path: `/api/v1/`
- Auth: Bearer JWT token in `Authorization` header
- Active entity: `X-Entity-Id: {uuid}` header on all requests (except auth endpoints)
- All timestamps: ISO 8601 (UTC)
- All amounts: NPR as strings to avoid floating point issues in JSON

### Standard Response Envelope

**Success:**
```json
{
  "success": true,
  "data": { },
  "message": "Operation completed successfully",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Paginated:**
```json
{
  "success": true,
  "data": {
    "content": [ ],
    "page": 0,
    "size": 20,
    "totalElements": 150,
    "totalPages": 8
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Error:**
```json
{
  "success": false,
  "error": "QUOTE_NOT_FOUND",
  "message": "Quote with id 123 not found",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Common Query Parameters
- `?page=0&size=20` — pagination
- `?sort=createdAt,desc` — sorting
- `?search=keyword` — free text search where supported

---

## Auth Endpoints
*No `X-Entity-Id` header required*

| Method | Path | Description |
|---|---|---|
| POST | `/api/v1/auth/login` | Login, returns JWT + refresh token |
| POST | `/api/v1/auth/refresh` | Refresh JWT using refresh token |
| POST | `/api/v1/auth/logout` | Revoke refresh token |
| POST | `/api/v1/auth/change-password` | Change own password |

### Login Request
```json
{
  "email": "user@futureprime.com",
  "password": "secret"
}
```

### Login Response (data field)
```json
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "expiresIn": 86400,
  "user": {
    "id": "uuid",
    "fullName": "Ram Sharma",
    "email": "ram@futureprime.com",
    "accessibleEntities": [
      { "id": "uuid1", "name": "Prime Associate", "shortCode": "PA" },
      { "id": "uuid2", "name": "Parina International", "shortCode": "PI" }
    ],
    "activeEntityId": "uuid1",
    "role": "MANAGER"
  }
}
```

---

## Identity Module

### Business Entities
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/entities` | SUPER_ADMIN | List all business entities |
| GET | `/api/v1/entities/{id}` | SUPER_ADMIN | Get entity details |
| POST | `/api/v1/entities` | SUPER_ADMIN | Create new entity |
| PUT | `/api/v1/entities/{id}` | SUPER_ADMIN | Update entity |

### Users
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/users` | ENTITY_ADMIN | List users for active entity |
| GET | `/api/v1/users/{id}` | ENTITY_ADMIN | Get user details |
| POST | `/api/v1/users` | SUPER_ADMIN | Create user |
| PUT | `/api/v1/users/{id}` | SUPER_ADMIN | Update user |
| POST | `/api/v1/users/{id}/assign-entity` | SUPER_ADMIN | Assign user to entity with role |
| PUT | `/api/v1/users/{id}/deactivate` | SUPER_ADMIN | Deactivate user |
| GET | `/api/v1/users/me` | Any | Get own profile |
| PUT | `/api/v1/users/me/switch-entity` | Any | Switch active entity context |

### Roles & Permissions
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/roles` | SUPER_ADMIN | List all roles |
| GET | `/api/v1/permissions` | SUPER_ADMIN | List all permissions |

---

## Master Data Module

### Customers
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/master/customers` | SALES, ACCOUNTS | List customers for active entity |
| GET | `/api/v1/master/customers/{id}` | SALES, ACCOUNTS | Get customer details |
| POST | `/api/v1/master/customers` | ENTITY_ADMIN | Create customer |
| PUT | `/api/v1/master/customers/{id}` | ENTITY_ADMIN | Update customer |
| PUT | `/api/v1/master/customers/{id}/deactivate` | ENTITY_ADMIN | Deactivate |
| GET | `/api/v1/master/customers/{id}/receivables` | ACCOUNTS | Customer outstanding |

### Suppliers
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/master/suppliers` | Any | List suppliers |
| GET | `/api/v1/master/suppliers/{id}` | Any | Supplier details |
| POST | `/api/v1/master/suppliers` | ENTITY_ADMIN | Create supplier |
| PUT | `/api/v1/master/suppliers/{id}` | ENTITY_ADMIN | Update supplier |

### Products
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/master/products` | Any | List products for active entity |
| GET | `/api/v1/master/products/{id}` | Any | Product details |
| POST | `/api/v1/master/products` | ENTITY_ADMIN | Create product |
| PUT | `/api/v1/master/products/{id}` | ENTITY_ADMIN | Update product |
| GET | `/api/v1/master/products/{id}/spare-parts` | Any | Spare parts for equipment |
| POST | `/api/v1/master/products/{id}/spare-parts` | ENTITY_ADMIN | Map spare part to equipment |

### Product Categories
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/master/categories` | Any | List categories |
| POST | `/api/v1/master/categories` | ENTITY_ADMIN | Create category |
| PUT | `/api/v1/master/categories/{id}` | ENTITY_ADMIN | Update category |

### Units of Measure
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/master/uom` | Any | List units |
| POST | `/api/v1/master/uom` | SUPER_ADMIN | Create unit |

---

## Inventory Module

### Warehouses
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/inventory/warehouses` | WAREHOUSE, Any | List warehouses |
| POST | `/api/v1/inventory/warehouses` | ENTITY_ADMIN | Create warehouse |
| PUT | `/api/v1/inventory/warehouses/{id}` | ENTITY_ADMIN | Update warehouse |
| GET | `/api/v1/inventory/warehouses/{id}/racks` | WAREHOUSE | List rack locations |
| POST | `/api/v1/inventory/warehouses/{id}/racks` | ENTITY_ADMIN | Add rack location |

### Stock
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/inventory/stock` | WAREHOUSE | Current stock — all products |
| GET | `/api/v1/inventory/stock/{productId}` | WAREHOUSE | Stock for one product |
| GET | `/api/v1/inventory/stock/low-stock` | WAREHOUSE | Products below min threshold |
| POST | `/api/v1/inventory/stock/adjust` | WAREHOUSE | Manual stock adjustment with reason |

### Stock Movements
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/inventory/movements` | WAREHOUSE | Movement history with filters |
| GET | `/api/v1/inventory/movements/{id}` | WAREHOUSE | Movement detail |

### Inter-Company Transfers
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/inventory/transfers` | WAREHOUSE, ACCOUNTS | List transfers |
| GET | `/api/v1/inventory/transfers/{id}` | WAREHOUSE | Transfer detail |
| POST | `/api/v1/inventory/transfers` | WAREHOUSE | Initiate transfer |
| PUT | `/api/v1/inventory/transfers/{id}/confirm` | ENTITY_ADMIN | Confirm — triggers invoice |
| PUT | `/api/v1/inventory/transfers/{id}/cancel` | ENTITY_ADMIN | Cancel transfer |

---

## Trade Module

### Quotes
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/trade/quotes` | SALES | List quotes for active entity |
| GET | `/api/v1/trade/quotes/{id}` | SALES | Quote detail |
| POST | `/api/v1/trade/quotes` | SALES | Create quote |
| PUT | `/api/v1/trade/quotes/{id}` | SALES | Update quote (DRAFT only) |
| POST | `/api/v1/trade/quotes/{id}/send` | SALES | Mark as SENT to customer |
| PUT | `/api/v1/trade/quotes/{id}/approve` | ENTITY_ADMIN | Approve quote |
| PUT | `/api/v1/trade/quotes/{id}/reject` | ENTITY_ADMIN | Reject quote |
| POST | `/api/v1/trade/quotes/{id}/convert` | SALES | Convert to Sales Order |
| GET | `/api/v1/trade/quotes/{id}/pdf` | SALES | Download quote PDF |

### Sales Orders
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/trade/orders` | SALES | List orders |
| GET | `/api/v1/trade/orders/{id}` | SALES | Order detail |
| POST | `/api/v1/trade/orders` | SALES | Create direct order (no quote) |
| PUT | `/api/v1/trade/orders/{id}` | SALES | Update order |
| PUT | `/api/v1/trade/orders/{id}/cancel` | ENTITY_ADMIN | Cancel order |
| POST | `/api/v1/trade/orders/{id}/invoice` | SALES | Generate invoice from order |

### Invoices
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/trade/invoices` | SALES, ACCOUNTS | List invoices |
| GET | `/api/v1/trade/invoices/{id}` | SALES, ACCOUNTS | Invoice detail |
| POST | `/api/v1/trade/invoices` | SALES | Create direct invoice |
| PUT | `/api/v1/trade/invoices/{id}/void` | ENTITY_ADMIN | Void invoice |
| GET | `/api/v1/trade/invoices/{id}/pdf` | SALES | Download PDF |
| POST | `/api/v1/trade/invoices/{id}/payments` | ACCOUNTS | Record payment receipt |
| GET | `/api/v1/trade/invoices/{id}/payments` | ACCOUNTS | List payments for invoice |

---

## Imports Module

### Purchase Orders
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/imports/purchase-orders` | Any | List POs |
| GET | `/api/v1/imports/purchase-orders/{id}` | Any | PO detail |
| POST | `/api/v1/imports/purchase-orders` | ENTITY_ADMIN | Create PO |
| PUT | `/api/v1/imports/purchase-orders/{id}` | ENTITY_ADMIN | Update PO |
| PUT | `/api/v1/imports/purchase-orders/{id}/send` | ENTITY_ADMIN | Mark as sent to supplier |

### LC Tracking
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/imports/lc` | ACCOUNTS | List LCs |
| GET | `/api/v1/imports/lc/{id}` | ACCOUNTS | LC detail |
| POST | `/api/v1/imports/lc` | ACCOUNTS | Create LC record |
| PUT | `/api/v1/imports/lc/{id}` | ACCOUNTS | Update LC status |

### Shipments
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/imports/shipments` | Any | List shipments |
| GET | `/api/v1/imports/shipments/{id}` | Any | Shipment detail |
| POST | `/api/v1/imports/shipments` | ENTITY_ADMIN | Create shipment |
| PUT | `/api/v1/imports/shipments/{id}` | ENTITY_ADMIN | Update shipment status/details |
| POST | `/api/v1/imports/shipments/{id}/costs` | ACCOUNTS | Add shipment cost item |
| GET | `/api/v1/imports/shipments/{id}/landed-cost` | ACCOUNTS | View landed cost breakdown |
| POST | `/api/v1/imports/shipments/{id}/receive` | WAREHOUSE | Receive into warehouse — triggers stock movement |

### Customs
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/imports/customs` | Any | List clearance records |
| POST | `/api/v1/imports/customs` | ACCOUNTS | Create customs record |
| PUT | `/api/v1/imports/customs/{id}` | ACCOUNTS | Update customs status |

---

## Service Module

### Equipment Units
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/service/equipment` | Any | List equipment units |
| GET | `/api/v1/service/equipment/{id}` | Any | Unit detail with warranty & service history |
| POST | `/api/v1/service/equipment` | SALES | Register equipment unit (on delivery) |
| PUT | `/api/v1/service/equipment/{id}` | ENTITY_ADMIN | Update unit details |
| GET | `/api/v1/service/equipment/warranty-expiring` | Any | Units with warranty expiring in 30/60/90 days |

### AMC Contracts
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/service/amc` | SALES, ACCOUNTS | List AMC contracts |
| GET | `/api/v1/service/amc/{id}` | Any | AMC detail |
| POST | `/api/v1/service/amc` | SALES | Create AMC contract |
| PUT | `/api/v1/service/amc/{id}` | ENTITY_ADMIN | Update AMC |
| GET | `/api/v1/service/amc/expiring` | Any | AMCs expiring soon |

### Service Jobs
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/service/jobs` | Any | List service jobs |
| GET | `/api/v1/service/jobs/{id}` | Any | Job detail |
| POST | `/api/v1/service/jobs` | SALES | Create service job |
| PUT | `/api/v1/service/jobs/{id}` | Any | Update job |
| POST | `/api/v1/service/jobs/{id}/visits` | TECHNICIAN | Log a service visit |
| GET | `/api/v1/service/jobs/{id}/visits` | Any | List visits for job |
| POST | `/api/v1/service/jobs/{id}/complete` | ENTITY_ADMIN | Mark job complete |
| POST | `/api/v1/service/jobs/{id}/invoice` | SALES | Generate invoice for billable job |

---

## Technician Module

| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/technicians` | Any | List technicians |
| GET | `/api/v1/technicians/{id}` | Any | Technician detail |
| POST | `/api/v1/technicians` | ENTITY_ADMIN | Add technician |
| PUT | `/api/v1/technicians/{id}` | ENTITY_ADMIN | Update technician |
| POST | `/api/v1/technicians/{id}/expenses` | TECHNICIAN | Log expense |
| GET | `/api/v1/technicians/{id}/expenses` | ACCOUNTS | Expense list for technician |
| POST | `/api/v1/technicians/{id}/travel` | TECHNICIAN | Log travel record |
| GET | `/api/v1/service/jobs/{jobId}/expenses` | ACCOUNTS | All expenses for a job |

---

## Finance Module

### Receivables
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/finance/receivables` | ACCOUNTS | List receivables |
| GET | `/api/v1/finance/receivables/overdue` | ACCOUNTS | Overdue receivables |
| GET | `/api/v1/finance/receivables/{id}` | ACCOUNTS | Receivable detail |

### Payables
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/finance/payables` | ACCOUNTS | List payables |
| GET | `/api/v1/finance/payables/overdue` | ACCOUNTS | Overdue payables |
| POST | `/api/v1/finance/payables/{id}/pay` | ACCOUNTS | Record supplier payment |

### Inter-Company Invoices
| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/finance/intercompany` | ACCOUNTS | List inter-company invoices |
| PUT | `/api/v1/finance/intercompany/{id}/settle` | ENTITY_ADMIN | Mark as settled |

### Tally Export
| Method | Path | Permission | Description |
|---|---|---|---|
| POST | `/api/v1/finance/tally/export` | ACCOUNTS | Generate Tally XML for date range |
| GET | `/api/v1/finance/tally/exports` | ACCOUNTS | Export history |
| GET | `/api/v1/finance/tally/exports/{id}/download` | ACCOUNTS | Download XML file |

---

## Reporting Module

| Method | Path | Permission | Description |
|---|---|---|---|
| GET | `/api/v1/reports/inventory-summary` | WAREHOUSE, ENTITY_ADMIN | Stock summary by product/entity |
| GET | `/api/v1/reports/sales-summary` | ENTITY_ADMIN | Sales by period |
| GET | `/api/v1/reports/receivables-aging` | ACCOUNTS | Aging analysis |
| GET | `/api/v1/reports/payables-aging` | ACCOUNTS | Payables aging |
| GET | `/api/v1/reports/shipment-status` | Any | All active shipments status |
| GET | `/api/v1/reports/service-due` | Any | Service/warranty due list |
| GET | `/api/v1/reports/consolidated` | SUPER_ADMIN | Cross-entity summary |
| GET | `/api/v1/reports/margin/{orderId}` | ENTITY_ADMIN | Margin analysis per order |
