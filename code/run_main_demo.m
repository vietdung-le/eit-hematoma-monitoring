function out = run_main_demo
%RUN_MAIN_DEMO Main demo entry point.

fprintf('=== GO-MPIEIT-Q1 main demo ===\n');

% Bootstrap project paths so this entry point works from a clean MATLAB session.
root_dir = fileparts(mfilename('fullpath'));
addpath(root_dir, '-begin');
addpath(fullfile(root_dir, 'config'), '-begin');
addpath(fullfile(root_dir, 'src'), '-begin');

cfg = q1_config();
setup_paths(cfg);

exp_case = build_experiment_suite(cfg, "demo");
if numel(exp_case) > 1
    exp_case = exp_case(1);
end

out = run_single_experiment(exp_case, cfg);

try
    plot_results(out.model_state0, out.truth, out.meas, out.results, exp_case, cfg);
catch ME
    warning('run_main_demo:plotFailed', 'plot_results failed: %s', ME.message);
end
end
