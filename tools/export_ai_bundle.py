from pathlib import Path
import os

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / 'ai-code-bundle.txt'

include_dirs = [
    'app',
    'bootstrap',
    'config',
    'database',
    'resources',
    'routes',
    'tests',
]
include_files = [
    'artisan',
    'composer.json',
    'package.json',
    'phpunit.xml',
    'README.md',
    'vite.config.js',
]
exclude_dirs = {
    'vendor',
    'node_modules',
    'storage',
    'public',
    'bootstrap/cache',
}

files = []
for rel in include_dirs:
    path = ROOT / rel
    if path.exists():
        for p in path.rglob('*'):
            if p.is_file():
                rel_path = p.relative_to(ROOT).as_posix()
                if any(part in exclude_dirs for part in rel_path.split('/')):
                    continue
                files.append(rel_path)

for rel in include_files:
    p = ROOT / rel
    if p.exists():
        files.append(rel)

files = sorted(set(files))

with OUTPUT.open('w', encoding='utf-8') as out:
    out.write('AI CODE BUNDLE\n')
    out.write('Project: api-magang\n')
    out.write('Generated from workspace root\n')
    out.write('=' * 80 + '\n\n')

    for rel in files:
        path = ROOT / rel
        if not path.exists() or not path.is_file():
            continue
        try:
            text = path.read_text(encoding='utf-8')
        except Exception:
            continue
        out.write(f'===== FILE: {rel} =====\n')
        out.write(text)
        if not text.endswith('\n'):
            out.write('\n')
        out.write('\n' + '=' * 80 + '\n\n')

print(f'Created {OUTPUT} with {len(files)} files')
