function T = run_ablation_study
% Bootstrap project paths so this entry point works from a clean MATLAB session.
root_dir = fileparts(mfilename('fullpath'));
addpath(root_dir, '-begin');
addpath(fullfile(root_dir, 'config'), '-begin');
addpath(fullfile(root_dir, 'src'), '-begin');

cfg = q1_config();
setup_paths(cfg);
rng(cfg.random_seed, 'twister');

cases = build_experiment_suite(cfg, "ablation");
outs = cell(numel(cases),1);
for i = 1:numel(cases)
    fprintf('Ablation %d/%d: %s\n', i, numel(cases), cases(i).name);
    outs{i} = run_single_experiment(cases(i), cfg);
    save_results_bundle(outs{i}, cases(i), cfg);
end
summary = export_case_summaries(outs, cases, cfg);
T = summary;
disp(T);
end
