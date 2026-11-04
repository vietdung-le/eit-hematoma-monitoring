#!/usr/bin/env python3
"""Check this repository's structure, published data inventory and hashes.

Uses the Python standard library only. Does not run MATLAB/EIDORS.
"""
from collections import Counter
import csv, hashlib, pathlib, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
ERRORS=[]
def check(ok,msg):
    if not ok: ERRORS.append(msg)

for rel in ['README.md','LICENSE','data/LICENSE','docs/LICENSE_AND_ATTRIBUTION.md','CITATION.cff','.gitignore','docs/DATA_DICTIONARY.md',
    'code/run_review_24h.m','code/run_review_forward_resolution.m',
    'code/run_revision5_validation.m',
    'code/run_review2_priority.m','code/r2_reconstruct_sequence_logged.m','code/config/q1_config.m',
    'code/config/default_config.m','code/src/setup_paths.m',
    'data/FILE_MANIFEST.csv','data/reviewer_checks/runs.csv',
    'data/reviewer_checks/mesh_preflight.csv',
    'data/forward_resolution/forward_signal_resolution.csv']:
    check((ROOT/rel).is_file(),'missing '+rel)

# The accepted title is consistent in the README and the software citation.
TITLE='A Shape-, Growth-, and Shift-Aware EIT Framework for Intracranial Hematoma Monitoring'
check('Permission is hereby granted' in (ROOT/'LICENSE').read_text(encoding='utf-8') if (ROOT/'LICENSE').is_file() else False, 'root MIT code license missing or unexpected')
check('CC-BY-4.0' in (ROOT/'data/LICENSE').read_text(encoding='utf-8') if (ROOT/'data/LICENSE').is_file() else False, 'data/LICENSE CC BY 4.0 notice not found')
check(TITLE in (ROOT/'README.md').read_text(encoding='utf-8'),'manuscript title not found in README')
check(('title: "'+TITLE+'"') in (ROOT/'CITATION.cff').read_text(encoding='utf-8'),'citation title differs from accepted manuscript title')

with (ROOT/'data/FILE_MANIFEST.csv').open(encoding='utf-8',newline='') as f:
    index=list(csv.DictReader(f))
expected={r['relative_path'] for r in index}
check(len(expected)==len(index), 'duplicate relative_path values in FILE_MANIFEST.csv')
seen=set()
for r in index:
    name=r['relative_path'];p=ROOT/name
    check(p.is_file(),'missing '+name)
    if not p.is_file():continue
    check(p.stat().st_size==int(r['bytes']),'size mismatch '+name)
    check(hashlib.sha256(p.read_bytes()).hexdigest()==r['sha256'],'sha mismatch '+name)
    seen.add(name)
actual={p.relative_to(ROOT).as_posix() for p in (ROOT/'data').rglob('*')
        if p.is_file() and p.name not in ('FILE_MANIFEST.csv','LICENSE')}
check(actual==seen,'unexpected or unindexed data files: '+str(actual.symmetric_difference(seen)))
check(len(index)==212,'expected 212 checksummed research data files, not '+str(len(index)))

with (ROOT/'data/reviewer_checks/runs.csv').open(encoding='utf-8-sig',newline='') as f:
    rows=list(csv.DictReader(f))
counts=Counter(r['group'] for r in rows)
check(counts=={'geometry':100,'growth':24,'pilot':2},'reviewer counts differ: '+str(counts))
check(all(r['status']=='OK' for r in rows),'some stored status not OK')
check(len(list((ROOT/'data/independent_mesh').glob('geometry_*.mat')))==100,'not 100 geometry MAT files')
check(len(list((ROOT/'data/growth').glob('growth_*.mat')))==24,'not 24 growth MAT files')
with (ROOT/'data/forward_resolution/forward_signal_resolution.csv').open(newline='') as f:
    res=list(csv.DictReader(f))
meshes={int(float(r['elements'])) for r in res}
check(meshes=={256,576,1024},'unexpected mesh resolutions '+str(meshes))
check(len(res)==12,'expected 12 forward-only mesh/growth records')
check({(int(float(r['elements'])),int(float(r['growth_percent']))) for r in res}=={(m,g) for m in (256,576,1024) for g in (0,10,20,30)},'incomplete forward growth grid')
check(not (ROOT/'manuscript').exists(),'paper manuscript should be absent from public repository')
# Duplicate nested legacy result copies must not reappear.
check(not (ROOT/'code/02_CODE').exists(),'nested old 02_CODE')
check(not (ROOT/'code/results').exists(),'generated results in code/results')
check(not list((ROOT/'data').rglob('*.zip')),'nested data zip present')
print('Audited data files:',len(index),'| reviewer runs:',len(rows),'| manuscript: excluded')
if ERRORS:
    for e in ERRORS:print('FAIL:',e)
    sys.exit(1)
print('PASS: archive integrity and directory consistency. MATLAB not executed.')
