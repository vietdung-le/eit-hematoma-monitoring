# Data dictionary and conventions

The CSV and MAT files report **synthetic numerical experiments**, not patient
measurements. They preserve the original MATLAB field names to allow an
independent reader to trace the archived values to the code.

## Run and mesh identifiers

- `full`: five-parameter inverse with the simulated displacement scalar.
- `no_shift`: inverse arm with that scalar disabled; it is not a full
  benchmark image-reconstruction method.
- `no_contact`: no contact-state updating in the indicated experiment.
- `a2c`, `b2c`, `c2c`, `d2c`: the EIDORS mesh-design identifiers used by the
  source scripts, with 64, 256, 576 and 1,024 triangles in these runs.
- `seed` and names such as `seed20260406`: pseudorandom-number-generator
  initialisation integers; not dates, clinical identifiers or case dates.
- `status = OK` in `reviewer_checks/runs.csv`: the MATLAB job completed and
  wrote a record; it does **not** mean the reconstructed geometry is correct.

## Core metrics

- `ellipse_dice`: 2D area overlap of the estimated and prescribed
  parameter-ellipses. It is not a volumetric or clinical-lesion overlap.
- `box_dice`: historical axis-aligned rectangular overlap used in the first
  code version, not the primary shape metric.
- `centroid_error`: 2D Euclidean distance between estimated and true ellipse
  centres, in *head-radius units*; no physical millimetre scale is implied.
- `contact_error`: relative norm difference between estimated and simulated
  contact parameters; the values are numerical model parameters, not
  independently calibrated electrode impedances.
- `area_ratio_true`/`area_ratio_est`: dimensionless final-to-first-frame
  ellipse areas for the growth sequences. The one-frame study by itself
  cannot estimate longitudinal growth.
- `weighted_norm` in `data/reviewer_checks/runs.csv`: **misleading legacy
  field name**. The reviewer stress tests set supplied weights to one, so
  this column is an *unweighted and unnormalised* Euclidean voltage norm,
  not a relative residual or a percentage. The original matched-model
  archive used residual-dependent channel weights, which are not directly
  comparable to the new challenge.

## Forward-only resolution table

`data/forward_resolution/forward_signal_resolution.csv` has 12 records
(three meshes by four prescribed growth levels, including no growth).

- `growth_percent`: prescribed 2D ellipse-area increase, not volume growth.
- `changed_elements`: number of mesh elements whose assigned conductivity
  changed relative to the same-mesh no-growth reference.
- `voltage_delta_norm`: Euclidean norm of the noise-free voltage difference.
- `voltage_delta_relative`: `voltage_delta_norm / ||v_no_growth||_2`.
  Multiply by 100 for percent changes (e.g. 0.001073282 = 0.1073282%).
- `expected_noise_norm`: model-based reference norm for the specified noise
  level; not an observed sample of the noise vector.
- `signal_to_expected_noise`: ratio of voltage-change norm to the preceding
  reference norm. It is not a validated detection score or success rate.
- `elapsed_sec`: runtime per stored execution; this field can vary across
  runs without changing the numerical response. The completed 12-row file
  comes from an author-supplied independent run of all three mesh levels.

## Reproducibility and remaining limitations

The data are sufficient for an integrity audit and inspection of reported
metrics, but **not yet independently proven sufficient for exact end-to-end
reproduction**. The MATLAB/EIDORS environment, numerical configuration and
figure-generation pipeline must be tested on a clean machine. Contact and
oracle diagnostics may use simulated truth that a blind method would not
possess, and must not be labelled clinical validation.
