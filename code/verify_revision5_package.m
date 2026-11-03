function verify_revision5_package()
%VERIFY_REVISION5_PACKAGE Fast package check; does not run EIDORS simulations.

root_dir = fileparts(mfilename('fullpath'));
addpath(root_dir, '-begin');
addpath(fullfile(root_dir, 'config'), '-begin');
addpath(fullfile(root_dir, 'src'), '-begin');

assert(exist('q1_config', 'file') == 2, 'q1_config.m is not visible.');
assert(exist('setup_paths', 'file') == 2, 'setup_paths.m is not visible.');
assert(exist('build_experiment_suite', 'file') == 2, 'build_experiment_suite.m is not visible.');

cfg = q1_config();
assert(isfield(cfg.inv, 'shift_prior_ref'), 'Missing cfg.inv.shift_prior_ref.');
assert(strcmp(string(cfg.inv.contact_gate_mode), "residual_only"), ...
    'Contact gate is not residual_only.');
assert(numel(cfg.mc.seeds) == 10, 'Monte Carlo seed count is not 10.');

prior_cases = build_experiment_suite(cfg, "shift_prior");
prior_refs = zeros(numel(prior_cases), 1);
for i = 1:numel(prior_cases)
    prior_refs(i) = prior_cases(i).overrides.inv.shift_prior_ref;
end
expected_refs = [0.020; 0.035; 0.050; 0.065; 0.080];
assert(isequal(round(prior_refs, 6), round(expected_refs, 6)), ...
    'Shift-prior sensitivity values are incorrect.');

growth_cases = build_experiment_suite(cfg, "growth");
for i = 1:numel(growth_cases)
    assert(abs(growth_cases(i).overrides.truth.shift_strength - cfg.truth.shift_strength) < 1e-12, ...
        'Growth case %d does not keep shift strength fixed.', i);
end

fprintf('REVISION-5 PACKAGE CHECK: PASS\n');
fprintf('q1_config: %s\n', which('q1_config'));
fprintf('setup_paths: %s\n', which('setup_paths'));
fprintf('contact gate: %s\n', string(cfg.inv.contact_gate_mode));
fprintf('shift prior refs: 0.020 0.035 0.050 0.065 0.080\n');
fprintf('MC seeds: %d\n', numel(cfg.mc.seeds));
fprintf('EIDORS root candidate: %s\n', cfg.eidors_path);
fprintf('Now run: run_revision5_validation\n');
end
