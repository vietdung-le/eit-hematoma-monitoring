# Before making a public GitHub release

- [ ] Confirm authors' ownership and permission to distribute all code,
  derived numerical data and supporting scripts. The paper and figures
  are in a separate author package, not this public repository.
- [ ] Select an appropriate code/data license and add an approved LICENSE.
- [ ] Set a repository URL and insert it only when it is live; do not
  invent a Zenodo DOI.
- [ ] Install MATLAB R2025b + EIDORS 3.12 on a clean system and run
  code/setup checks and at least one reviewer pilot.
- [ ] Compare the archived 50 geometry pairs, 24 growth arms and ten-seed
  matched-model results against reproducible outputs.
- [x] Verify all three claimed forward-only mesh resolutions have CSV rows: 256, 576 and 1,024. This does not establish convergence.
- [ ] Verify manuscript figures separately against archived analysis
  data; record any missing figure-regeneration script.
- [ ] Keep the response-to-reviewers and author-only Word files out of
  the public repository unless explicitly cleared for disclosure.
- [ ] Verify GitHub upload was extracted and source files are visible (not only one ZIP).
- [ ] Publish an immutable release only after checking the archive in a
  clean checkout; then mint and reference a Zenodo DOI if appropriate.
