# GitHub code/data release status (author-reported upload, 2026-11-04)

Public repository URL provided by the corresponding author:
https://github.com/vietdung-le/eit-hematoma-monitoring

## Confirmed by offline ZIP audit
- Four browser upload batches contain 282 nonoverlapping files.
- The `data/` batches contain 212 checksum-indexed research files plus `FILE_MANIFEST.csv` and `data/LICENSE` (CC BY 4.0).
- The `scripts/validate_repository.py` implementation is updated for the root MIT software license and data-specific CC BY 4.0 license.
- The 126 saved run log records, 100 one-frame geometry arm files, 24 growth arm files, and the 256/576/1024 forward-resolution rows can be inspected offline.
- Published numerical outputs include known estimator failures; they are not evidence of clinical validity or of mesh convergence.

## Still outstanding before claiming a verified public, reproducible release
- Open the repository in a private/incognito browser session and inspect representative `code/` and `data/` files.
- Update the repository with the files in the accompanying GitHub patch ZIP and run the Python checker on a clean checkout.
- Confirm the root `LICENSE` is MIT and `data/LICENSE` is CC BY 4.0; confirm authors' rights for both.
- Run MATLAB R2025b/EIDORS 3.12 on a clean system and compare regeneration against archived MAT/CSV datasets.
- Create a versioned GitHub Release after the upload and checkout are verified. No DOI is asserted here.

The online repository content was not independently accessible from the audit environment at preparation time. This report is not a certification of a complete public upload.
