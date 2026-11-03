# Numerical data: provenance and interpretation

All files in `data/` were copied from the author-supplied
`ISAS2026_PUBLIC_REPOSITORY_READY.zip`. No new simulation output was
generated during repository cleanup. The original ZIP remains the recovery
point for all removed files.

## Dataset mapping

| Evidence in manuscript | Path | Provenance and limitation |
| --- | --- | --- |
| Matched-model ten-seed ablations | `data/matched_model/mc_case_metrics_long.csv` | Ten noise seeds applied to one nominal geometry, not 50 independent lesions |
| Full/no-shift paired effects | `data/audit/paired_seed_effects_summary.csv` | Derived paired bootstrap summaries of the ten-seed record |
| Framewise six-frame diagnostics | `data/audit/already_run_frame_audit.csv` and `data/audit/frame_truth_vs_estimated_seed20260406.csv` | Selected saved seed only |
| Objective components | `data/audit/objective_terms_6frames_seed20260406.csv` | Term decomposition of selected saved states, not a penalty-weight sweep |
| Contact by electrode | `data/audit/already_run_contact_by_electrode.csv` and `data/reviewer2_checks/` | Simulated contact truth; not a clinical contact calibration |
| Fifty one-frame varied geometries | `data/reviewer_checks/runs.csv` + `data/independent_mesh/` | 50 pairs, independent truth/inverse meshes with changed drive protocol |
| Growth: no/10/20/30% | `data/reviewer_checks/runs.csv` + `data/growth/` | 3 seeds per level and 2 arms; results document a failure of recovered area tracking |
| Mesh preflight | `data/reviewer_checks/mesh_preflight.csv` | 64-element inverse versus 256-element truth for reviewer tests |
| Forward-only mesh-resolution diagnostic | `data/forward_resolution/forward_signal_resolution.csv` | **256, 576 and 1,024 triangles are archived (12 rows)**; insufficient for convergence claims |

`data/reviewer_checks/runs.csv` has 126 rows marked `OK`: 100
geometry runs, 24 growth runs and two pilot runs. This is successful
job completion only, **not** a validation that outputs are accurate.

## Source and reproducibility distinctions

- The 70-value selected-electrode graph-cycle measurement protocol in
  the historical matched-model archive includes a non-physical closing
  edge between electrodes 10 and 1. The reviewer stress-test code uses
  a 56-value physically adjacent open arc. Treat these as distinct tests.
- The original bad-channel case used a generator-provided corruption mask
  in the weights; it cannot validate blind channel-quality estimation.
  The reviewer harness turns these weights off; it does not implement a
  proven data-driven detector.
- `data/forward_resolution/forward_signal_resolution.csv` now contains all
  three author-supplied mesh levels, 256, 576 and 1,024 triangles. The first
  eight rows have the same scientific voltage metrics as the earlier subset,
  while elapsed-time fields differ between exports. The source is the
  author's twelve-row forward-resolution CSV. These data do not show
  convergence; the voltage sensitivity varies non-monotonically.
- The paper and five PDF figures are **not distributed here**;
  they are kept in the separate author package. Not all figures can
  be regenerated from the included script tree.
- See the SHA-256, byte size and dataset group in `data/FILE_MANIFEST.csv`.
