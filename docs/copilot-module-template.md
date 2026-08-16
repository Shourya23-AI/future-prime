Generate a complete Spring Boot module for the {EntityName} entity following these exact conventions:

ENTITY DETAILS:
- Entity class: {EntityName} in package com.futureprime.{module}.entity
- Table name: {table_name}
- Fields: {list the fields and types}

GENERATE THESE FILES:

1. {EntityName}Repository in com.futureprime.{module}.repository
    - Extends JpaRepository<{EntityName}, UUID>
    - Method: findByBusinessEntityIdAndIsActive(UUID businessEntityId, boolean isActive, Pageable pageable) returns Page<{EntityName}>
    - Method: findByIdAndBusinessEntityId(UUID id, UUID businessEntityId) returns Optional<{EntityName}>

2. {EntityName}RequestDto in com.futureprime.{module}.dto
    - All creatable/updatable fields
    - @NotBlank on required String fields
    - @NotNull on required object fields
    - Use @Getter @Setter

3. {EntityName}ResponseDto in com.futureprime.{module}.dto
    - All fields including id, createdAt, updatedAt
    - Use @Getter @Setter

4. {EntityName}Service interface in com.futureprime.{module}.service
    - Page<{EntityName}ResponseDto> findAll(UUID entityId, Pageable pageable)
    - {EntityName}ResponseDto findById(UUID id, UUID entityId)
    - {EntityName}ResponseDto create({EntityName}RequestDto request, UUID entityId)
    - {EntityName}ResponseDto update(UUID id, {EntityName}RequestDto request, UUID entityId)
    - void deactivate(UUID id, UUID entityId)

5. {EntityName}ServiceImpl in com.futureprime.{module}.service.impl
    - Annotate with @Service
    - Constructor inject: {EntityName}Repository, BusinessEntityRepository
    - Implement all 5 methods
    - findAll: call repository with entityId and isActive=true, map to ResponseDto
    - findById: call findByIdAndBusinessEntityId, throw ResourceNotFoundException if empty
    - create: find BusinessEntity by entityId (throw if not found), map RequestDto to entity, set businessEntity, save, map to ResponseDto
    - update: find existing, update fields, save, map to ResponseDto
    - deactivate: find existing, set isActive=false, save
    - All methods annotated with @Transactional
    - Use ResourceNotFoundException from com.futureprime.core.exception
    - Use BusinessException from com.futureprime.core.exception

6. {EntityName}Controller in com.futureprime.{module}.controller
    - @RestController
    - @RequestMapping("/api/v1/{module}/{entities}")
    - Constructor inject {EntityName}Service
    - All fields final
    - Extract entityId from request header "X-Entity-Id" using @RequestHeader("X-Entity-Id") UUID entityId
    - GET / → findAll with Pageable, return ResponseEntity<ApiResponse<Page<{EntityName}ResponseDto>>>
    - GET /{id} → findById
    - POST / → create with @Valid @RequestBody
    - PUT /{id} → update with @Valid @RequestBody
    - PUT /{id}/deactivate → deactivate
    - All return ResponseEntity<ApiResponse<T>> using ApiResponse.success(result)

STRICT RULES:
- All @ManyToOne relationships use FetchType.LAZY
- All boolean fields use primitive boolean not Boolean
- Never use @Autowired — constructor injection only
- All fields in classes are private
- Never expose entity directly — always map to DTO
- Use BigDecimal for all monetary amounts with @Column(precision=15, scale=2)
- Soft delete only — never hard delete
- All controllers return ApiResponse wrapper
- Import ResourceNotFoundException from com.futureprime.core.exception
- Import BusinessException from com.futureprime.core.exception
- Import ApiResponse from com.futureprime.core.dto