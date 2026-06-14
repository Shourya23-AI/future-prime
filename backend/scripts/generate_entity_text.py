from pathlib import Path

root = Path('src/main/java/com/futureprime')
output = Path('generated-entity-classes.txt')
packages = ['identity','master','inventory','trade','imports','service','technician','finance']

with output.open('w', encoding='utf-8') as out:
    for pkg in packages:
        pkg_path = root / pkg
        if not pkg_path.exists():
            continue
        for path in sorted(pkg_path.rglob('*.java')):
            out.write(f'--- FILE: {path.as_posix()} ---\n')
            out.write(path.read_text(encoding='utf-8'))
            out.write('\n\n')

print(output.resolve())
