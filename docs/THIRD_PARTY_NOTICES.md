# External dependencies, licenses and attribution

This repository contains the authors' MATLAB source and synthetic simulation
records. It does **not** distribute MATLAB, EIDORS, Netgen, or their upstream
source or binary packages.

## EIDORS

- Software: EIDORS (Electrical Impedance Tomography and Diffuse Optical
  Tomography Reconstruction Software), version 3.12 as recorded for this work.
- Official project: https://eidors3d.sourceforge.net/
- Upstream license: GNU General Public License, version 2 or version 3;
  verify the notice in the precise EIDORS distribution installed.
- Role here: independently installed EIT forward-model solver and mesh/model
  utilities accessed through interfaces such as `mk_common_model` and
  `fwd_solve`. EIDORS files are not included in the repository.

Suggested scholarly citation for EIDORS:

Adler, A., and Lionheart, W. R. B. (2006). Uses and abuses of EIDORS:
an extensible software base for EIT. *Physiological Measurement*, 27(5),
S25-S42. https://doi.org/10.1088/0967-3334/27/5/S03

Using an external GPL program is not a blanket authorization to copy or
relicense its source. If any included author file was derived from EIDORS
source rather than written independently against its interfaces, the authors
must identify that file and assess the applicable GPL obligations before
releasing it under a blanket MIT notice.

## MATLAB

- Software: MATLAB R2025b, the recorded development environment.
- Publisher: The MathWorks, Inc. https://www.mathworks.com/
- MATLAB is separately licensed proprietary software and is not included.
- MATLAB File Exchange or MathWorks example code, if imported or adapted,
  must be assessed against its specific file license and notice requirements;
  no general MATLAB ownership rights are granted by the repository MIT file.

## Repository licenses and ownership check

- Root `LICENSE` (MIT): applies only to eligible author-owned software and
  associated author-owned software documentation.
- `data/LICENSE` (CC BY 4.0): original synthetic numerical records and their
  data documentation, to the extent the listed rights holders can grant it.
- Author-written project documentation: CC BY 4.0 as described in
  `docs/LICENSE_AND_ATTRIBUTION.md`.
- Publishing under a public GitHub account does not establish copyright
  ownership. The authors should confirm coauthor and institutional rights
  before publishing a tagged release.

This notice documents dependencies and release scope; it is not a legal
finding that all included code has an independently established provenance.
