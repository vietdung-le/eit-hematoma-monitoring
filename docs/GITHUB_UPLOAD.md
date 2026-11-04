# Updating the existing public GitHub repository (2026-11-04)

Repository: https://github.com/vietdung-le/eit-hematoma-monitoring

The authors report that the MATLAB code and the three uploaded data batches
have already been added. To apply the final small-file correction:

1. Clone the **existing** repository with GitHub Desktop.
2. Copy the contents of the accompanying `GITHUB_PATCH_UPLOAD_CONTENTS/`
   directory into the repository root, retaining paths and overwriting the
   indicated small files. Do not create an extra nested folder.
3. Preserve the existing **MIT** root `LICENSE`; it is not part of this patch.
4. Preserve `data/LICENSE` (**CC BY 4.0**) and all CSV/MAT files.
5. Commit the updates and Push origin.
6. From a fresh checkout, run `python scripts/validate_repository.py`.
7. In an incognito browser, inspect at least README, one MATLAB file, data
   manifest, data/LICENSE and several data files. A link alone is not proof of
   a complete public deposit.

The research-paper Word/LaTeX files and author response are a separate
submission package; do not upload them to the public code/data repository.
No independent full MATLAB/EIDORS re-execution or DOI is claimed.
