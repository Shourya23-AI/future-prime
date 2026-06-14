from pathlib import Path
import re

BASE_DIR = Path('src/main/java/com/futureprime')

fk_map_general = {
    'businessEntityId': ('BusinessEntity', 'business_entity_id', False, 'businessEntity'),
    'primaryEntityId': ('BusinessEntity', 'primary_entity_id', False, 'primaryEntity'),
    'categoryId': ('ProductCategory', 'category_id', False, 'category'),
    'supplierId': ('Supplier', 'supplier_id', False, 'supplier'),
    'uomId': ('UnitOfMeasure', 'uom_id', False, 'unitOfMeasure'),
    'customerId': ('Customer', 'customer_id', False, 'customer'),
    'quoteId': ('Quote', 'quote_id', False, 'quote'),
    'salesOrderId': ('SalesOrder', 'sales_order_id', False, 'salesOrder'),
    'invoiceId': ('Invoice', 'invoice_id', False, 'invoice'),
    'purchaseOrderId': ('PurchaseOrder', 'purchase_order_id', False, 'purchaseOrder'),
    'shipmentId': ('Shipment', 'shipment_id', False, 'shipment'),
    'stockItemId': ('StockItem', 'stock_item_id', False, 'stockItem'),
    'fromEntityId': ('BusinessEntity', 'from_entity_id', False, 'fromEntity'),
    'toEntityId': ('BusinessEntity', 'to_entity_id', False, 'toEntity'),
    'productId': ('Product', 'product_id', False, 'product'),
    'equipmentUnitId': ('EquipmentUnit', 'equipment_unit_id', False, 'equipmentUnit'),
    'technicianId': ('Technician', 'technician_id', False, 'technician'),
    'serviceJobId': ('ServiceJob', 'service_job_id', False, 'serviceJob'),
    'serviceVisitId': ('ServiceVisit', 'service_visit_id', False, 'serviceVisit'),
    'purchaseOrderLineItemId': ('PurchaseOrderLineItem', 'purchase_order_line_item_id', False, 'purchaseOrderLineItem'),
    'exportedBy': ('AppUser', 'exported_by', False, 'exportedBy'),
    'interCompanyTransferId': ('InterCompanyTransfer', 'inter_company_transfer_id', False, 'interCompanyTransfer'),
    'parentId': ('ProductCategory', 'parent_id', True, 'parentCategory'),
    'roleId': ('Role', 'role_id', False, 'role'),
    'permissionId': ('Permission', 'permission_id', False, 'permission'),
    'userId': ('AppUser', 'user_id', False, 'user'),
}

file_fk_overrides = {
    'SalesOrder.java': {'quoteId': ('Quote', 'quote_id', True, 'quote')},
    'PurchaseOrder.java': {'salesOrderId': ('SalesOrder', 'sales_order_id', True, 'salesOrder')},
    'ServiceJob.java': {
        'amcContractId': ('AmcContract', 'amc_contract_id', True, 'amcContract'),
        'invoiceId': ('Invoice', 'invoice_id', True, 'invoice'),
    },
    'Invoice.java': {'salesOrderId': ('SalesOrder', 'sales_order_id', True, 'salesOrder')},
    'Technician.java': {'supplierId': ('Supplier', 'supplier_id', True, 'supplier')},
    'InterCompanyTransfer.java': {'interCompanyInvoiceId': ('InterCompanyInvoice', 'inter_company_invoice_id', True, 'interCompanyInvoice')},
    'StockItem.java': {'rackLocationId': ('RackLocation', 'rack_location_id', True, 'rackLocation')},
    'EquipmentUnit.java': {'invoiceId': ('Invoice', 'invoice_id', False, 'invoice')},
}

join_tables = {
    'RolePermission.java': [('roleId', 'Role', 'role_id', 'role'), ('permissionId', 'Permission', 'permission_id', 'permission')],
    'CustomerEntity.java': [('customerId', 'Customer', 'customer_id', 'customer'), ('businessEntityId', 'BusinessEntity', 'business_entity_id', 'businessEntity')],
    'ShipmentPurchaseOrder.java': [('shipmentId', 'Shipment', 'shipment_id', 'shipment'), ('purchaseOrderId', 'PurchaseOrder', 'purchase_order_id', 'purchaseOrder')],
}

text_fields = {
    'address', 'billingAddress', 'shippingAddress', 'description', 'termsAndConditions',
    'notes', 'deliveryAddress', 'installationAddress', 'terms', 'reportedIssue', 'diagnosis',
    'resolution', 'workDone', 'partsUsed',
}

name_required = {
    'BusinessEntity': {'name'},
    'Customer': {'name'},
    'Supplier': {'name'},
    'Product': {'name'},
    'ProductCategory': {'name'},
    'Warehouse': {'name'},
    'Technician': {'name'},
}

unique_required = {
    'Role': {'name'},
    'Permission': {'code'},
    'AppUser': {'email'},
}

always_required_amounts = {'quantity', 'totalAmount', 'originalAmount'}
status_field_names = {'status'}

base_imports = {
    'Entity': 'jakarta.persistence.Entity',
    'Table': 'jakarta.persistence.Table',
    'Getter': 'lombok.Getter',
    'Setter': 'lombok.Setter',
    'BaseEntity': 'com.futureprime.core.entity.BaseEntity',
}

relation_imports = {
    'BusinessEntity': 'com.futureprime.identity.entity.BusinessEntity',
    'AppUser': 'com.futureprime.identity.entity.AppUser',
    'Role': 'com.futureprime.identity.entity.Role',
    'Permission': 'com.futureprime.identity.entity.Permission',
    'Customer': 'com.futureprime.master.entity.Customer',
    'Supplier': 'com.futureprime.master.entity.Supplier',
    'ProductCategory': 'com.futureprime.master.entity.ProductCategory',
    'UnitOfMeasure': 'com.futureprime.master.entity.UnitOfMeasure',
    'Product': 'com.futureprime.master.entity.Product',
    'StockItem': 'com.futureprime.inventory.entity.StockItem',
    'Warehouse': 'com.futureprime.inventory.entity.Warehouse',
    'RackLocation': 'com.futureprime.inventory.entity.RackLocation',
    'Quote': 'com.futureprime.trade.entity.Quote',
    'SalesOrder': 'com.futureprime.trade.entity.SalesOrder',
    'Invoice': 'com.futureprime.trade.entity.Invoice',
    'PaymentReceipt': 'com.futureprime.trade.entity.PaymentReceipt',
    'PurchaseOrder': 'com.futureprime.imports.entity.PurchaseOrder',
    'PurchaseOrderLineItem': 'com.futureprime.imports.entity.PurchaseOrderLineItem',
    'LcTracking': 'com.futureprime.imports.entity.LcTracking',
    'Shipment': 'com.futureprime.imports.entity.Shipment',
    'CustomsClearance': 'com.futureprime.imports.entity.CustomsClearance',
    'ShipmentCost': 'com.futureprime.imports.entity.ShipmentCost',
    'LandedCostAllocation': 'com.futureprime.imports.entity.LandedCostAllocation',
    'EquipmentUnit': 'com.futureprime.service.entity.EquipmentUnit',
    'WarrantyRecord': 'com.futureprime.service.entity.WarrantyRecord',
    'FreeServiceEntitlement': 'com.futureprime.service.entity.FreeServiceEntitlement',
    'AmcContract': 'com.futureprime.service.entity.AmcContract',
    'ServiceJob': 'com.futureprime.service.entity.ServiceJob',
    'ServiceVisit': 'com.futureprime.service.entity.ServiceVisit',
    'ServicePartUsage': 'com.futureprime.service.entity.ServicePartUsage',
    'Technician': 'com.futureprime.technician.entity.Technician',
    'TechnicianExpense': 'com.futureprime.technician.entity.TechnicianExpense',
    'TravelRecord': 'com.futureprime.technician.entity.TravelRecord',
    'InterCompanyTransfer': 'com.futureprime.inventory.entity.InterCompanyTransfer',
    'InterCompanyInvoice': 'com.futureprime.finance.entity.InterCompanyInvoice',
    'TallyExportLog': 'com.futureprime.finance.entity.TallyExportLog',
    'DocumentSequence': 'com.futureprime.finance.entity.DocumentSequence',
}

annotation_imports = {
    'Column': 'jakarta.persistence.Column',
    'ManyToOne': 'jakarta.persistence.ManyToOne',
    'FetchType': 'jakarta.persistence.FetchType',
    'JoinColumn': 'jakarta.persistence.JoinColumn',
    'EmbeddedId': 'jakarta.persistence.EmbeddedId',
    'Embeddable': 'jakarta.persistence.Embeddable',
    'MapsId': 'jakarta.persistence.MapsId',
    'UniqueConstraint': 'jakarta.persistence.UniqueConstraint',
}

simple_type_imports = {
    'UUID': 'java.util.UUID',
    'LocalDate': 'java.time.LocalDate',
    'LocalDateTime': 'java.time.LocalDateTime',
    'LocalTime': 'java.time.LocalTime',
    'BigDecimal': 'java.math.BigDecimal',
    'Serializable': 'java.io.Serializable',
}

field_pattern = re.compile(r'^(\s*)private\s+([A-Za-z0-9_<>]+)\s+([A-Za-z0-9_]+);\s*$')

for path in sorted(BASE_DIR.rglob('*.java')):
    if path.name == 'BaseEntity.java':
        continue
    if path.parent.name != 'entity':
        continue
    class_name = path.stem
    content = path.read_text(encoding='utf-8')
    content = content.replace('java.util.UUID', 'UUID')
    content = content.replace('java.time.LocalDateTime', 'LocalDateTime')
    content = content.replace('java.time.LocalDate', 'LocalDate')
    content = content.replace('java.time.LocalTime', 'LocalTime')

    lines = content.splitlines()
    package_line = lines[0]
    content_tail = lines[1:]
    body_start = 0
    while body_start < len(content_tail) and (content_tail[body_start].strip() == '' or content_tail[body_start].startswith('import ')):
        body_start += 1
    body_lines = content_tail[body_start:]

    fk_map = dict(fk_map_general)
    fk_map.update(file_fk_overrides.get(path.name, {}))
    is_join_table = path.name in join_tables

    used_imports = set(base_imports.values())
    used_type_names = set()
    relation_types_used = set()
    annotations_used = set()

    header_lines = []
    body = []
    in_class = False
    for line in body_lines:
        if not in_class:
            header_lines.append(line)
            if line.strip().startswith('public class'):
                in_class = True
            continue
        body.append(line)
    header_lines = [line for line in header_lines if not line.startswith('import ')]

    if class_name == 'DocumentSequence':
        for i, line in enumerate(header_lines):
            if line.strip().startswith('@Table'):
                header_lines[i] = '@Table(name = "document_sequence", uniqueConstraints = @UniqueConstraint(columnNames = {"business_entity_id", "document_type", "year"}))'
                annotations_used.add('UniqueConstraint')
                break

    if is_join_table:
        for i, line in enumerate(header_lines):
            if 'extends BaseEntity' in line:
                header_lines[i] = line.replace('extends BaseEntity', '').replace('  ', ' ')
                break

    generated_body = []
    if is_join_table:
        embedded_fields = join_tables[path.name]
        generated_body.append('')
        generated_body.append('    @EmbeddedId')
        generated_body.append('    private Id id = new Id();')
        annotations_used.update({'EmbeddedId', 'Embeddable', 'MapsId'})
        used_type_names.add('UUID')
        for field_name, entity_name, column_name, relation_name in embedded_fields:
            relation_types_used.add(entity_name)
            generated_body.append('')
            generated_body.append('    @ManyToOne(fetch = FetchType.LAZY)')
            generated_body.append(f'    @MapsId("{field_name}")')
            generated_body.append(f'    @JoinColumn(name = "{column_name}")')
            generated_body.append(f'    private {entity_name} {relation_name};')
            annotations_used.update({'ManyToOne', 'JoinColumn', 'FetchType', 'Column'})
        generated_body.append('')
        generated_body.append('    @Embeddable')
        generated_body.append('    @Getter')
        generated_body.append('    @Setter')
        generated_body.append('    public static class Id implements Serializable {')
        for field_name, _, column_name, _ in embedded_fields:
            generated_body.append(f'        @Column(name = "{column_name}")')
            generated_body.append(f'        private UUID {field_name};')
        generated_body.append('    }')
        generated_body.append('}')
    else:
        for line in body:
            if line.strip() == 'extends BaseEntity {':
                continue
            m = field_pattern.match(line)
            if m:
                indent, field_type, field_name = m.groups()
                if field_name in fk_map:
                    entity_name, column_name, nullable, relation_name = fk_map[field_name]
                    relation_types_used.add(entity_name)
                    annotations_used.update({'ManyToOne', 'JoinColumn', 'FetchType'})
                    generated_body.append(f'{indent}@ManyToOne(fetch = FetchType.LAZY)')
                    generated_body.append(f'{indent}@JoinColumn(name = "{column_name}", nullable = {str(nullable).lower()})')
                    generated_body.append(f'{indent}private {entity_name} {relation_name};')
                    continue
                if field_type in relation_imports:
                    relation_types_used.add(field_type)
                annotation_args = []
                if field_type == 'String' and field_name in text_fields:
                    annotation_args.append('columnDefinition = "TEXT"')
                if class_name in name_required and field_name in name_required[class_name]:
                    annotation_args.append('nullable = false')
                if class_name in unique_required and field_name in unique_required[class_name]:
                    annotation_args.append('unique = true')
                    annotation_args.append('nullable = false')
                if field_name in status_field_names:
                    annotation_args.append('nullable = false')
                if field_type == 'BigDecimal' and field_name in always_required_amounts:
                    annotation_args.append('nullable = false')
                if annotation_args:
                    annotations_used.add('Column')
                    arg_text = ', '.join(dict.fromkeys(annotation_args))
                    if not generated_body or not generated_body[-1].strip().startswith('@Column'):
                        generated_body.append(f'{indent}@Column({arg_text})')
                generated_body.append(line)
                if field_type in simple_type_imports:
                    used_type_names.add(field_type)
                continue
            generated_body.append(line)
            if line.strip().startswith('@ManyToOne'):
                annotations_used.update({'ManyToOne', 'FetchType'})
            if line.strip().startswith('@JoinColumn'):
                annotations_used.add('JoinColumn')
            if line.strip().startswith('@Column'):
                annotations_used.add('Column')
            if line.strip().startswith('@EmbeddedId'):
                annotations_used.add('EmbeddedId')
            if line.strip().startswith('@Embeddable'):
                annotations_used.add('Embeddable')
            if line.strip().startswith('@MapsId'):
                annotations_used.add('MapsId')
            if 'BigDecimal' in line:
                used_type_names.add('BigDecimal')
            if 'UUID' in line and 'UUID' in line.split():
                used_type_names.add('UUID')
            if 'LocalDateTime' in line:
                used_type_names.add('LocalDateTime')
            if 'LocalDate' in line and 'LocalDateTime' not in line:
                used_type_names.add('LocalDate')
            if 'LocalTime' in line:
                used_type_names.add('LocalTime')

    # normalize repeated annotation blocks and merge @Column attributes before field declarations
    def normalize_segment(segment_lines):
        if not segment_lines:
            return []
        if not segment_lines[-1].strip().startswith('private '):
            return segment_lines
        field_line = segment_lines[-1]
        annotation_lines = segment_lines[:-1]
        normalized = []
        column_attrs = {}
        seen = set()
        for ann in annotation_lines:
            stripped = ann.strip()
            if stripped.startswith('@Column'):
                inner = stripped[stripped.find('(') + 1:stripped.rfind(')')].strip()
                for part in [p.strip() for p in inner.split(',') if p.strip()]:
                    if '=' in part:
                        key, value = [item.strip() for item in part.split('=', 1)]
                        column_attrs[key] = value
                continue
            if stripped.startswith('@'):
                if stripped in seen:
                    continue
                seen.add(stripped)
            normalized.append(ann)
        if column_attrs:
            attrs = ', '.join(f'{k} = {v}' for k, v in column_attrs.items())
            normalized.append(f'    @Column({attrs})')
        return normalized + [field_line]

    collapsed_body = []
    segment = []
    for line in generated_body:
        segment.append(line)
        if line.strip().startswith('private '):
            collapsed_body.extend(normalize_segment(segment))
            segment = []
    if segment:
        collapsed_body.extend(normalize_segment(segment))
    generated_body = collapsed_body

    if 'Column' in annotations_used:
        used_imports.add(annotation_imports['Column'])
    if 'ManyToOne' in annotations_used:
        used_imports.add(annotation_imports['ManyToOne'])
        used_imports.add(annotation_imports['JoinColumn'])
        used_imports.add(annotation_imports['FetchType'])
    if 'EmbeddedId' in annotations_used:
        used_imports.add(annotation_imports['EmbeddedId'])
    if 'Embeddable' in annotations_used:
        used_imports.add(annotation_imports['Embeddable'])
    if 'MapsId' in annotations_used:
        used_imports.add(annotation_imports['MapsId'])
    if 'UniqueConstraint' in annotations_used:
        used_imports.add(annotation_imports['UniqueConstraint'])

    if class_name != 'RolePermission' and class_name != 'CustomerEntity' and class_name != 'ShipmentPurchaseOrder':
        used_imports.add(base_imports['BaseEntity'])

    for t in used_type_names:
        if t in simple_type_imports:
            used_imports.add(simple_type_imports[t])
    if is_join_table:
        used_imports.add(simple_type_imports['Serializable'])
    for rel in relation_types_used:
        if rel in relation_imports:
            used_imports.add(relation_imports[rel])

    import_lines = [f'import {imp};' for imp in sorted(used_imports)]
    final_lines = [package_line, ''] + import_lines + [''] + header_lines + generated_body
    path.write_text('\n'.join(final_lines).rstrip() + '\n', encoding='utf-8')
    print(f'Updated {path}')
