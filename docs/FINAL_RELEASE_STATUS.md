# GitHub Code and Data Release Status

Repository: https://github.com/vietdung-le/eit-hematoma-monitoring

Last checked: 2026-11-04

## Completed

- The repository contains `code/`, `data/`, `docs/`, and `scripts/`.
- GitHub Actions successfully repaired the original split-data directory structure.
- All 212 checksum-indexed research data files passed the offline SHA-256 integrity check using the GitHub-downloaded ZIP.
- The saved run log contains 126 records.
- Forward-resolution records include the 256-, 576-, and 1024-element cases.
- The root `LICENSE` is MIT for eligible author-owned software; `data/LICENSE` is CC BY 4.0 for eligible original datasets.
- `scripts/validate_repository.py` returned PASS on the downloaded repository archive.
- Manuscript and reviewer-response documents are intentionally excluded from the public code/data repository.

## Remaining verification and release tasks

- Independently rerun representative MATLAB R2025b/EIDORS 3.12 simulations and compare numerical results with the archive.
- Confirm rights and permissions for openly licensed author-owned code, data, and documentation.
- Verify the final manuscript and response-to-reviewers files cite the correct repository URL.
- Publish a versioned GitHub Release when ready. No DOI is claimed.

## Scope of verification

The checks establish archived-file integrity and repository structure. They do not demonstrate independent numerical reproducibility, mesh convergence, experimental validation, or clinical applicability.
