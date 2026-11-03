# Reproduction protocol for reviewer-oriented EIT experiments

## Software / platform

The archived code was developed in MATLAB R2025b with EIDORS 3.12.
MATLAB and EIDORS are external dependencies and are not redistributed.
The original code has no verified cross-platform numerical parity claim.

## Local setup

1. Clone or download the repository; extract it so `code/config/` and
   `code/src/` are direct children of `code/`.
2. Install EIDORS separately and call its startup script if required.
3. In MATLAB, change folder to `code/`, and use
   `setenv('EIDORS_PATH','YOUR_EIDORS_PARENT_OR_ROOT')`.
4. Run `verify_revision5_package` to check the static configuration.
5. Run `run_review_24h('preflight')` and confirm the coarse and truth mesh
   counts printed by EIDORS. Only then run `pilot`, `configs` and `growth`.
6. Run `run_review_24h('summary')` to read `code/results_review24h/runs.csv`.
7. Use `run_review_forward_resolution({'b2c','c2c','d2c'})` for the mesh study.

## Saved outputs versus regenerated outputs

The code writes new files to `code/results_review24h/` and
`code/results/`. Existing numerical evidence is located in
`data/reviewer_checks/`, `data/independent_mesh/`, `data/growth/`,
`data/matched_model/`, `data/reviewer2_checks/`, `data/audit/` and
`data/forward_resolution/`.

MATLAB may produce additional intermediate `.mat` files. Never copy these
over published source data without checking results and rerun settings.
The 50 independent geometry cases are one frame each. The growth cases
are six frames each, 3 paired seeds per level, with final changes of
zero, 10, 20 and 30 percent. A status value `OK` is a completed job, not
successful detection or good geometry.

## Numerical limitations and missing work

No MATLAB/EIDORS simulation was executed in preparing this cleaned
repository. The code and CSV files were inspected statically. A blind
bad-channel detector, anatomical head mismatch, mechanically calibrated
tissue shift and independent standard-image baseline are not validated
by the stored results. These limitations should remain explicit in any
response-to-reviewers or public release description.

The manuscript and paper figures are distributed only in the separate
author submission package. The repository includes the author-supplied twelve-row forward-only
mesh table (256, 576 and 1,024 elements). These results are forward
sensitivity measurements, not a validated convergence study. Re-run EIDORS,
compare resulting CSVs/MAT records and check paper figure claims separately
before a DOI-bearing release.

## Re-running Reviewer 2 diagnostics

Archived matched-model MAT inputs are under `data/matched_model/`; they are
**not** duplicated in `code/results/`. In MATLAB, change to the `code/`
folder, configure EIDORS, and run:

```matlab
run_review2_priority('audit')
run_review2_priority('truth_residual')
run_review2_priority('oracle')
run_review2_priority('lambda',2)
run_review2_priority('contact_stress')
run_review2_priority('contact_trace')
```

The runner paths were adapted to the clean repository layout; the numerical
search functions were not modified. The instrumented contact replay is a
separate implementation, not a claim of clinical contact identification.
The code has not been executed end-to-end in the archive preparation environment.
