# Future Prime — Developer Guide

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Java | 21 (LTS) | Use SDKMAN to manage versions |
| Maven | 3.9+ | Bundled with IntelliJ, or install separately |
| PostgreSQL | 15+ | Local install for development |
| IntelliJ IDEA | Latest | Community edition is fine |
| Git | Any | Already set up |
| Postman | Any | For API testing |
| AWS CLI | v2 | For S3 and deployment later |

---

## Project Setup

### 1. Generate from Spring Initializr
Go to https://start.spring.io with:
- Project: Maven
- Language: Java
- Spring Boot: 3.5.14
- Group: `com.futureprime`
- Artifact: `future-prime`
- Packaging: Jar
- Java: 21

**Dependencies to select:**
- Spring Web
- Spring Data JPA
- Spring Security
- Validation
- PostgreSQL Driver
- Flyway Migration
- Lombok

Unzip into your `future-prime` folder (pom.xml at the root).

### 2. Additional dependencies (add manually to pom.xml)

```xml
<!-- JWT -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>

<!-- MapStruct for DTO mapping -->
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>1.5.5.Final</version>
</dependency>
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct-processor</artifactId>
    <version>1.5.5.Final</version>
    <scope>provided</scope>
</dependency>

<!-- iText 7 for PDF generation -->
<dependency>
    <groupId>com.itextpdf</groupId>
    <artifactId>itext7-core</artifactId>
    <version>7.2.5</version>
    <type>pom</type>
</dependency>

<!-- AWS S3 SDK -->
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>s3</artifactId>
    <version>2.21.0</version>
</dependency>
```

### 3. Create local PostgreSQL database

```sql
CREATE DATABASE futureprime_dev;
CREATE USER futureprime_user WITH PASSWORD 'yourpassword';
GRANT ALL PRIVILEGES ON DATABASE futureprime_dev TO futureprime_user;
```

### 4. application.yml

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/futureprime_dev
    username: futureprime_user
    password: yourpassword
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: validate        # Flyway manages schema, Hibernate only validates
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true

app:
  jwt:
    secret: your-very-long-secret-key-minimum-256-bits-for-hs256
    expiration-ms: 86400000       # 24 hours
    refresh-expiration-ms: 604800000  # 7 days
  
  aws:
    region: ap-south-1
    s3:
      bucket-name: future-prime-documents

  timezone: Asia/Kathmandu
  vat-rate: 0.13
```

---

## Coding Conventions

### 1. Every entity extends BaseEntity

```java
// com.futureprime.core.entity.BaseEntity
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @CreatedBy
    @Column(updatable = false)
    private String createdBy;

    @LastModifiedBy
    private String updatedBy;
}
```

Enable auditing in your main config class with `@EnableJpaAuditing`.

### 2. Standard API response wrapper

```java
// com.futureprime.core.dto.ApiResponse
public class ApiResponse<T> {
    private boolean success;
    private T data;
    private String message;
    private LocalDateTime timestamp;

    public static <T> ApiResponse<T> success(T data) { ... }
    public static <T> ApiResponse<T> success(T data, String message) { ... }
    public static <T> ApiResponse<T> error(String message) { ... }
}
```

All controllers return `ResponseEntity<ApiResponse<T>>`.

### 3. Layer structure per module

Every module follows the same pattern — no exceptions:

```
controller  →  service (interface)  →  service (impl)  →  repository
                                    ↓
                                  mapper (MapStruct)
                                    ↓
                              entity ↔ dto
```

- **Controller:** HTTP only. Validate request, call service, return response. No business logic.
- **Service interface:** Defines the contract. One interface per service.
- **Service impl:** All business logic lives here. `@Transactional` at method level.
- **Repository:** Spring Data JPA. Custom queries in JPQL (not native SQL unless necessary).
- **Entity:** JPA entity. No business logic. No Jackson annotations.
- **DTO:** Data transfer objects. One per use case (RequestDTO, ResponseDTO). Never expose entity directly.
- **Mapper:** MapStruct. Converts entity ↔ DTO. Never do manual mapping.

### 4. Package naming

```
com.futureprime.{module}.entity.{EntityName}
com.futureprime.{module}.repository.{EntityName}Repository
com.futureprime.{module}.service.{EntityName}Service          (interface)
com.futureprime.{module}.service.impl.{EntityName}ServiceImpl
com.futureprime.{module}.dto.{EntityName}RequestDto
com.futureprime.{module}.dto.{EntityName}ResponseDto
com.futureprime.{module}.mapper.{EntityName}Mapper
com.futureprime.{module}.controller.{EntityName}Controller
```

### 5. Entity context in requests

Every service method that touches entity-scoped data must accept `entityId` as a parameter. This comes from the JWT via a method argument resolver — never from a request body.

```java
// Resolved from X-Entity-Id header + JWT validation
@GetMapping("/quotes")
public ResponseEntity<ApiResponse<Page<QuoteResponseDto>>> getQuotes(
        @CurrentEntityId UUID entityId,
        Pageable pageable) {
    return ResponseEntity.ok(ApiResponse.success(quoteService.findAll(entityId, pageable)));
}
```

### 6. Soft delete pattern

Master data is never hard deleted. Use `isActive` flag.

```java
// In repository
List<Customer> findByBusinessEntityIdAndIsActiveTrue(UUID entityId);

// In service — deactivate, never delete
public void deactivateCustomer(UUID id, UUID entityId) {
    Customer customer = findByIdAndEntity(id, entityId);
    customer.setActive(false);
    customerRepository.save(customer);
}
```

### 7. Amount handling

All monetary amounts use `BigDecimal`. Never use `double` or `float` for money.

```java
// In entity
@Column(precision = 15, scale = 2)
private BigDecimal amount;

// In calculations
BigDecimal vatAmount = subtotal.multiply(VAT_RATE).setScale(2, RoundingMode.HALF_UP);
```

### 8. Exception handling

Use a global exception handler. Never return stack traces to the client.

```java
// com.futureprime.core.exception.ResourceNotFoundException
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String resource, UUID id) {
        super(resource + " not found with id: " + id);
    }
}

// com.futureprime.core.exception.GlobalExceptionHandler
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ApiResponse<Void>> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity.status(404)
            .body(ApiResponse.error(ex.getMessage()));
    }
}
```

---

## Flyway Migration Rules

- One file per logical change. Never edit an existing migration file.
- Naming: `V{version}__{description}.sql` (double underscore)
- Order: V1, V2, V3... following the order in data-model.md
- Always include both `CREATE TABLE` and any initial seed data in the same migration if needed
- Test every migration on a clean database before committing

```
src/main/resources/db/migration/
├── V1__create_identity.sql
├── V2__create_master.sql
├── V3__create_inventory.sql
├── V4__create_trade.sql
├── V5__create_imports.sql
├── V6__create_service.sql
├── V7__create_technician.sql
└── V8__create_finance.sql
```

---

## Document Number Generation

Use a `document_sequence` table with a database-level lock to avoid duplicates. Never generate document numbers in application memory.

```java
// Always call this inside a @Transactional method
public String generateDocumentNumber(UUID entityId, String docType) {
    int year = LocalDate.now().getYear();
    // SELECT ... FOR UPDATE to lock the row
    // Increment last_sequence
    // Return formatted string: {entityCode}-{docType}-{year}-{sequence padded to 4}
}
```

---

## Build and Run

```bash
# Build
mvn clean install -DskipTests

# Run locally
mvn spring-boot:run

# Run tests
mvn test

# Build fat JAR for deployment
mvn clean package -DskipTests
# Output: target/future-prime-0.0.1-SNAPSHOT.jar
```

---

## Git Workflow

- `main` — production-ready code only
- `develop` — integration branch
- `feature/{module}-{description}` — feature branches

```bash
# Start a feature
git checkout develop
git pull
git checkout -b feature/identity-user-management

# Commit often, with meaningful messages
git commit -m "feat(identity): add user entity and repository"
git commit -m "feat(identity): implement JWT token generation"
git commit -m "feat(identity): add login endpoint with refresh token"

# When done
git checkout develop
git merge feature/identity-user-management
```

Commit message format: `{type}({module}): {description}`
Types: `feat`, `fix`, `refactor`, `docs`, `test`

---

## Build Order

Build in this order — each module depends on the previous:

1. `core` — base entity, exceptions, response wrapper, config
2. `identity` — users, roles, JWT (everything else depends on auth)
3. `master` — customers, suppliers, products (everything else depends on master data)
4. `inventory` — stock, warehouses (depends on master)
5. `trade` — quotes, orders, invoices (depends on master + inventory)
6. `imports` — purchase orders, shipments (depends on master + inventory)
7. `service` — warranty, service jobs (depends on trade)
8. `technician` — technician, expenses (depends on service)
9. `finance` — receivables, payables, tally export (depends on trade + imports)
10. `reporting` — cross-module queries (depends on all)

---

## Testing Approach

- Write tests for **service layer** (business logic). Controller tests are optional for MVP.
- Use `@DataJpaTest` for repository tests with an in-memory H2 database.
- Use `@SpringBootTest` sparingly — slow, use only for integration tests.
- Every new service method should have at minimum: happy path test + not-found test.

```bash
# Test naming convention
class QuoteServiceTest {
    void createQuote_withValidData_shouldReturnCreatedQuote() { }
    void createQuote_withInvalidCustomer_shouldThrowNotFoundException() { }
    void approveQuote_whenAlreadyApproved_shouldThrowBusinessException() { }
}
```

---

## Where to Start (First Day of Coding)

1. Verify `pom.xml` compiles cleanly — `mvn clean install -DskipTests`
2. Set up `application.yml` with your local database
3. Create `BaseEntity` in `core.entity`
4. Create `ApiResponse` wrapper in `core.dto`
5. Create `GlobalExceptionHandler` in `core.exception`
6. Write `V1__create_identity.sql` Flyway migration
7. Run the app — Flyway should execute the migration
8. Verify tables exist in your local PostgreSQL

That's your first commit. From there, build the `identity` module (User, Role, JWT) before touching anything else.
