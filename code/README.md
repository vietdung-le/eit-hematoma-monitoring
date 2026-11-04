# MATLAB source directory

The main runnable MATLAB project is **this `code/` folder**. The inherited
`02_CODE` wrapper has been removed to fix `config/` and `src/` lookups.
Existing numerical solvers are preserved except for removal of the
old machine-specific EIDORS-path fallback. The two reviewer runners were
moved here without changing their numerical formulas.

| Entry point | Role and output |
| --- | --- |
| `verify_revision5_package` | Check the stored configuration without forward simulation |
| `run_review_24h('preflight')` | Check independent truth and inversion meshes |
| `run_review_24h('configs', 50)` | One-frame, 50-configuration geometric stress test |
| `run_review_24h('growth', 3)` | No-growth and 10/20/30% three-seed sequences |
| `run_review_forward_resolution({'b2c','c2c','d2c'})` | Static forward-only three-mesh diagnostic |
| `run_review2_priority('audit')` | Read original MAT inputs and save per-frame residual/contact audit |
| `run_review2_priority('oracle')` | One-frame truth-initialized diagnostic, not blind inference |
| `run_review2_priority('lambda',2)` | Two prior-weight settings, not a full sweep |
| `run_review2_priority('contact_trace')` | Instrumented replay contact attempt/accept counts |
| `run_revision5_validation` | Historical six-frame matched-model Monte Carlo replay |
| `run_export_paper_figures` | Historical figure exporter; **does not** establish reproduction of all figures in the separately supplied paper |

Set `EIDORS_PATH` to the external EIDORS installation, then `cd` into
this folder. Do not add this entire tree with `genpath`; `setup_paths`
places `config`, `src`, `experiments` and `baselines` in a deliberate order.
Outputs are created locally under `results/` or `results_review24h/` and
are excluded from Git commits. The audited results are in `../data/`. Reviewer 2 scripts read `../data/matched_model/` and write new outputs under `code/results_review2_priority/`; this folder is intentionally ignored by Git.

**Not performed in this repository cleanup:** executing MATLAB/EIDORS,
independently validating the forward-mesh experiments or reconstructing
the paper figures from raw data. Do not infer successful numeric replay
from successful Python integrity checks. Paper LaTeX is distributed separately.

**Licensing:** The repository-root `LICENSE` is the MIT License for author-owned code in `code/` and `scripts/`, subject to rights clearance. The dataset-specific `data/LICENSE` grants CC BY 4.0 to author-owned numerical data. Neither covers MATLAB/EIDORS dependencies.
