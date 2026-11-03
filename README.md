# A Shape-, Growth-, and Shift-Aware EIT Framework for Intracranial Hematoma Monitoring

**MATLAB/EIDORS code and synthetic numerical datasets (ISAS 2026)**

This repository provides the MATLAB/EIDORS implementation and archived
numerical records associated with the manuscript *A Shape-, Growth-, and
Shift-Aware EIT Framework for Intracranial Hematoma Monitoring*.
The study is **numerical and two-dimensional**; the displacement coordinate
is not a calibrated clinical midline shift. The independent-mesh and growth
tests expose failure cases and must not be represented as successful
monitoring or clinical validation.

## Repository contents

| Path | Purpose |
| --- | --- |
| `code/` | MATLAB/EIDORS implementation, independent-mesh and Reviewer 2 diagnostic runners |
| `data/matched_model/` | Original matched-generator outputs, including ten measurement-seed summaries |
| `data/independent_mesh/` | Fifty one-frame geometry pairs and pilot MAT files |
| `data/growth/` | No-growth and 10/20/30% six-frame cases (three seeds per condition, two arms) |
| `data/reviewer_checks/` | Case-level runs and 64/256-element truth/inverse mesh preflight |
| `data/reviewer2_checks/` | Saved contact, residual, prior and oracle diagnostics |
| `data/forward_resolution/` | Three forward-only mesh resolutions (256, 576 and 1,024 elements) |
| `data/audit/` | Derived CSV summaries and one-seed objective/trajectory audits |
| `data/FILE_MANIFEST.csv` | SHA-256 checksum and provenance for every public data file |
| `scripts/validate_repository.py` | Offline integrity/structure test (no MATLAB required) |
| `docs/` | Reproducibility protocol, data traceability and release cautions |

No archive ZIP files are nested in `data/`. The same original matched-model
files are stored **once**, in `data/matched_model/`. Output folders from new
MATLAB runs are excluded by `.gitignore` so that historic published records
cannot be silently replaced.

## Requirements

- MATLAB R2025b (the archived implementation's recorded environment).
- EIDORS 3.12, installed **separately**; EIDORS is not bundled.
- Python 3.9+ standard library for the integrity check only.

## Reproduce and validate the code

In a fresh MATLAB session:

```matlab
cd('PATH_TO_REPOSITORY/eit-hematoma-monitoring/code')
setenv('EIDORS_PATH', 'PATH_TO_EIDORS_ROOT')  % contains eidors/startup.m or startup.m
verify_revision5_package                     % static test; no EIDORS forward solves
run_review_24h('preflight')                   % inspect actual mesh sizes
run_review_24h('pilot')                       % one matched pair on distinct meshes
run_review_24h('configs', 5)                  % pilot subset, then 50 for full set
run_review_24h('configs', 50)
run_review_24h('growth', 3)                   % 0/10/20/30%, 3 seeds per level
run_review_24h('summary')
run_review2_priority('audit')                % retrospective data audit
run_review2_priority('truth_residual')       % EIDORS required
run_review2_priority('oracle')               % one-frame diagnostic
run_review2_priority('lambda', 2)            % two penalty settings
run_review2_priority('contact_stress')       % contact multipliers
run_review2_priority('contact_trace')        % contact-gate log
run_review_forward_resolution({'b2c','c2c','d2c'}) % 256, 576 and 1024 triangles
```

Runners save **new** results to `code/results_review24h/`. The
legacy matched-model sweep is available separately via
`run_revision5_validation` (writes to `code/results/`). Existing public
datasets are never overwritten by those scripts. For preflight only,
execute `python scripts/validate_repository.py` at the repository root.

**Important:** The original archive supplies ten-seed matched-model output,
but the independent-mesh geometry tests use 50 distinct **single-frame**
configurations, not 50 six-frame tracking sequences. The reviewer scripts
disable the original known-corruption-mask weighting; this is **not** a
validated blind bad-channel detector. The revised open-arc protocol has 56
measurements; the historical graph-cycle protocol has 70. These are not
identical protocols, so independent-mesh results are not a mesh-only ablation.

## Results and figures

The archived `runs.csv` has 126 `OK` rows (100 geometry arms, 24 growth
arms and two pilot arms). An `OK` status indicates that a MATLAB job
returned and a record was saved, **not** that the algorithm met an
accuracy threshold. The paper manuscript and its figures are **not included** in this public code/data package.
A fully automated, independently verified regeneration pipeline for all
paper figures is not supplied; do not claim otherwise.

The forward-resolution CSV contains **all three recorded mesh levels** (256,
576 and 1,024 triangles), with 0%, 10%, 20% and 30% prescribed area growth.
The data document discretization sensitivity, **not** mesh convergence or
reliable small-growth detection. The complete 12-row author-supplied CSV
replaces an earlier, incomplete eight-row export; measured voltage metrics
in their shared rows agree, whereas measured wall-clock times differ between
independent exports.

Dataset identifiers are kept as run identifiers for reproducibility, not
scientific labels: `a2c`, `b2c`, `c2c` and `d2c` are EIDORS mesh-design names
(64, 256, 576 and 1,024 triangles respectively). A number such as `20260406`
identifies a pseudorandom-number-generator seed; it is **not** a measurement
date or patient identifier. `weighted_norm` in the revised geometry/growth
challenge is a historical column name: with weights set to one it is an
unweighted, **unnormalised** voltage norm, not a percent residual.

See [`docs/DATA_DICTIONARY.md`](docs/DATA_DICTIONARY.md) for metric and
field definitions, [`docs/DATA_PROVENANCE.md`](docs/DATA_PROVENANCE.md) for the evidence
map, [`docs/REPRODUCIBILITY.md`](docs/REPRODUCIBILITY.md) for run details
and [`docs/GITHUB_UPLOAD.md`](docs/GITHUB_UPLOAD.md) for uploading the unpacked
files via GitHub Desktop.

## Attribution and public release

The published paper's final citation, GitHub URL and Zenodo DOI are not
known to this bundle; none have been invented. `CITATION.cff` includes
author names and an appropriate software title but no fabricated DOI.
Original synthetic research data and author-written documentation are
licensed under **CC BY 4.0 International**, as scoped in the repository-root
[`LICENSE`](LICENSE) and [`docs/LICENSE_AND_ATTRIBUTION.md`](docs/LICENSE_AND_ATTRIBUTION.md).
Please cite the listed authors and indicate changes when reusing the data.
**Software source in `code/` and `scripts/` is not covered by CC BY 4.0**;
a software license remains to be approved by the rights holders. MATLAB and
EIDORS remain external dependencies. The manuscript (Word, LaTeX and PDF),
paper figures and peer-review response are intentionally excluded from this
public repository and remain in the separate submission package.
