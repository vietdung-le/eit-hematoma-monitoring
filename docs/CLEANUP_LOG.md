# Changes made when preparing the clean GitHub directory

Source: author-supplied `ISAS2026_PUBLIC_REPOSITORY_READY.zip`. The
source archive was not modified.

1. Flattened `code/02_CODE` into `code/` and relocated two reviewer
   runners next to their required `config/` and `src/` directories.
2. Removed the repeated `code/02_CODE/results/` dataset: the identical
   68 archival entries were imported **once** to `data/matched_model/`
   (except its misleading empty-folder note).
3. Removed `code/02_CODE/results_pilot_old/`, historical figure folders,
   paper-draft Markdown, the unrelated `paper_tex/` paper, old duplicate
   `run_export_paper_figures_old*.m` and the outdated wrapper README.
4. Expanded the three nested data ZIPs into sorted, directly inspectable
   data folders; preserved each MAT and CSV observation. Removed one
   exact duplicate CSV `reviewer2_existing_data_summary.csv` in favour
   of `already_run_summary.csv`.
5. Kept only the correct ISAS LaTeX manuscript and five cited PDF figures;
   omitted the reviewer response and Word author copy from the public repo.
6. Replaced machine-specific default EIDORS path guesses with explicit
   `EIDORS_PATH` configuration. No solver numerical parameter was changed.
7. Corrected LaTeX statements about an unarchived 1024-element mesh:
   the distributed forward-resolution CSV contains 256 and 576 only.
   Removed the unsupported table row and any 1024-element conclusions.
8. Added direct reproducibility instructions, a run/data provenance map,
   `CITATION.cff`, `.gitignore`, file SHA-256 manifest, offline repository
   validation script and an explicit license-decision warning.

These are structural and evidence-consistency changes, **not newly run
numerical experiments**. MATLAB execution, licensing and an end-to-end
figure regeneration check remain pending before a DOI-bearing release.

The author-only Word copy was edited separately to describe the same
two archived mesh resolutions; it is not part of the public ZIP.
The historical deterministic-metric recomputation now reads the
public matched-model dataset without writing into it.

## Public code-and-data edition (v2)

Removed the complete `manuscript/` directory (LaTeX, IOP class, PDF and five
figure PDFs). The paper and reviewer response are preserved **only** in a
separate author package. Updated README, documentation and offline validator
to reflect code/data-only scope. No simulation data or MATLAB numerical
logic was altered in this v2 packaging change.

## Complete repository data and runnable diagnostics (v3)

- Restored the complete author-provided 12-row forward-only table at
  256/576/1024 triangles. Eight previously released rows match on voltage
  metrics; runtime values were recorded independently.
- Added the two Reviewer 2 diagnostic MATLAB scripts from the source bundle
  used to generate the stored Reviewer 2 results. File-loading paths were
  adapted to `data/matched_model/` in the flattened public layout.
- Updated the file checksum manifest, integrity validator, documentation
  and citation title. No new simulation has been run; no licence or DOI
  has been assigned. The manuscript is still distributed separately.
