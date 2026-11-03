function outputs = run_revision5_validation()
%RUN_REVISION5_VALIDATION One entry point for the five reviewer fixes.
%
% Requires MATLAB R2025b + EIDORS 3.12.
% Outputs include:
%   results/mc_case_metrics_long.csv
%   results/mc_case_metrics_summary.csv
%   results/mc_shift_prior_sensitivity_long.csv
%   results/mc_shift_prior_sensitivity_summary.csv
%
% The revised configuration uses:
%   - residual-only contact gating;
%   - post-update/final residual reporting;
%   - independent shift-prior reference;
%   - growth-only stress cases with fixed base shift;
%   - both axis-aligned box Dice and oriented ellipse Dice.

root_dir = fileparts(mfilename('fullpath'));
cd(root_dir);
% Bootstrap project paths so this entry point works from a clean MATLAB session.
addpath(root_dir, '-begin');
addpath(fullfile(root_dir, 'config'), '-begin');
addpath(fullfile(root_dir, 'src'), '-begin');

cfg = q1_config();
setup_paths(cfg);

% Fail early with a clear message if EIDORS did not initialize.
if exist('mk_common_model', 'file') ~= 2 && exist('ng_mk_cyl_models', 'file') ~= 2
    error('Revision5:EIDORSNotFound', [ ...
        'EIDORS is not available on the MATLAB path. Set EIDORS_PATH to the ' ...
        'EIDORS root folder or edit config/default_config.m, then run again.']);
end

fprintf('=== Revision-5 validation: single-seed cases ===\n');
outputs.single_seed = run_all_experiments();

fprintf('=== Revision-5 validation: 10-seed Monte Carlo ===\n');
outputs.monte_carlo = run_all_experiments_mc();

fprintf('=== Revision-5 validation complete ===\n');
end
