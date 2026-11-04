# Final GitHub release checklist (2026-11-04)

- [x] Offline data archive: 212 SHA-256-indexed research files in 4 upload ZIPs; 126 saved run records.
- [x] Public GitHub address supplied by the authors: https://github.com/vietdung-le/eit-hematoma-monitoring
- [x] Distinct licensing structure selected: root MIT for eligible original code; `data/LICENSE` CC BY 4.0 for original datasets (rights clearance still required).
- [ ] Confirm that a non-logged-in browser can read the online `README.md`, `code/run_review_24h.m`, `data/FILE_MANIFEST.csv`, `data/LICENSE` and a sample `.mat` file.
- [ ] Overwrite only the modified README/docs/validator files included in the GitHub patch ZIP. **Do not overwrite the existing MIT root `LICENSE`.**
- [ ] Clone the GitHub repository and execute `python scripts/validate_repository.py`; confirm `PASS` without MATLAB.
- [ ] Run a fresh MATLAB R2025b + EIDORS 3.12 preflight and one representative case. Compare scientific values, not merely exit status.
- [ ] Obtain contributor/organisation permission for open licensing where necessary, and exclude separately licensed third-party sources.
- [ ] Test regeneration of manuscript figures separately (the repository does not claim a fully automated end-to-end figure pipeline).
- [ ] Confirm final manuscript/reviewer response hyperlink uses the GitHub URL above.
- [ ] Tag and publish a GitHub Release after inspection. Do not claim a Zenodo DOI until minted.
