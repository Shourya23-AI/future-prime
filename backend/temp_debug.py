from pathlib import Path
import re
BASE_DIR = Path('src/main/java/com/futureprime')
fk_map_general = {'businessEntityId': ('BusinessEntity', 'business_entity_id', False, 'businessEntity')}
relation_imports = {'BusinessEntity': 'com.futureprime.identity.entity.BusinessEntity'}
field_pattern = re.compile(r'^(\\s*)private\\s+([A-Za-z0-9_<>]+)\\s+([A-Za-z0-9_]+);\\s*$')
path = BASE_DIR / 'finance' / 'entity' / 'DocumentSequence.java'
content = path.read_text(encoding='utf-8')
lines = content.splitlines()
package_line = lines[0]
body_start = 1
while body_start < len(lines) and lines[body_start].strip() == '':
    body_start += 1
while body_start < len(lines) and lines[body_start].startswith('import '):
    body_start += 1
while body_start < len(lines) and lines[body_start].strip() == '':
    body_start += 1
print('BODY_START', body_start, repr(lines[body_start]))
body_lines = lines[body_start:]
header = []
body = []
in_class = False
for line in body_lines:
    if not in_class:
        header.append(line)
        if line.strip().startswith('public class'):
            in_class = True
        continue
    body.append(line)
print('HEADER', header[:10])
print('BODY', body[:20])
used_imports = set(['com.futureprime.core.entity.BaseEntity', 'jakarta.persistence.Entity', 'jakarta.persistence.Table', 'lombok.Getter', 'lombok.Setter'])
relation_types_used = set()
annotations_used = set()
used_type_names = set()
for line in body:
    m = field_pattern.match(line)
    if m:
        indent, field_type, field_name = m.groups()
        print('MATCH', field_name, field_type)
        if field_name in fk_map_general:
            ent, col, nullable, rel = fk_map_general[field_name]
            relation_types_used.add(ent)
            annotations_used.update({'ManyToOne', 'JoinColumn', 'FetchType'})
            continue
print('relation_types_used', relation_types_used)
print('annotations_used', annotations_used)
for rel in relation_types_used:
    if rel in relation_imports:
        used_imports.add(relation_imports[rel])
print('used_imports', sorted(used_imports))
