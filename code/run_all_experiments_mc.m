function summary = run_all_experiments_mc
%RUN_ALL_EXPERIMENTS_MC Revised 10-seed Monte Carlo analysis.
% Includes oriented ellipse Dice and shift-prior sensitivity cases.

% Bootstrap project paths so this entry point works from a clean MATLAB session.
root_dir = fileparts(mfilename('fullpath'));
addpath(root_dir, '-begin');
addpath(fullfile(root_dir, 'config'), '-begin');
addpath(fullfile(root_dir, 'src'), '-begin');

cfg0 = q1_config();
setup_paths(cfg0);

cases_demo = build_experiment_suite(cfg0, 'demo');
cases_ablation = build_experiment_suite(cfg0, 'ablation');
cases_robustness = build_experiment_suite(cfg0, 'robustness');
cases_growth = build_experiment_suite(cfg0, 'growth');
cases_shift_prior = build_experiment_suite(cfg0, 'shift_prior');

cases = [ ...
    cases_demo(:); ...
    cases_ablation(:); ...
    cases_robustness(:); ...
    cases_growth(:); ...
    cases_shift_prior(:) ...
];

seeds = cfg0.mc.seeds(:);
nSeeds = numel(seeds);
nCases = numel(cases);

rows = cell(nSeeds * nCases, 9);
row = 0;

for s = 1:nSeeds
    seed_cfg = cfg0;
    seed_cfg.random_seed = seeds(s);
    rng(seeds(s), 'twister');

    fprintf('\n=== Monte Carlo seed %d / %d (%d) ===\n', s, nSeeds, seeds(s));

    for i = 1:nCases
        case_i = cases(i);
        case_i.seed = seeds(s);

        out = run_single_experiment(case_i, seed_cfg);
        m = out.metrics;
        row = row + 1;
        rows(row,:) = { ...
            string(case_i.name), ...
            seeds(s), ...
            get_field_or(m, 'mean_dice', NaN), ...
            get_field_or(m, 'mean_ellipse_dice', NaN), ...
            get_field_or(m, 'mean_centroid_error', NaN), ...
            get_field_or(m, 'mean_contact_rel_error', NaN), ...
            get_field_or(m, 'mean_relative_residual', NaN), ...
            get_field_or(m, 'final_mesh_elems', NaN), ...
            get_field_or(m, 'mean_mesh_gain', NaN)};
    end
end

T = cell2table(rows, 'VariableNames', { ...
    'case_name','seed','mean_dice','mean_ellipse_dice','mean_centroid_error', ...
    'mean_contact_rel_error','mean_relative_residual', ...
    'final_mesh_elems','mean_mesh_gain'});

[G, case_names] = findgroups(T.case_name);
summary = table();
summary.case_name = case_names;
summary.dice_mean = splitapply(@(x) mean(x,'omitnan'), T.mean_dice, G);
summary.dice_std = splitapply(@(x) std(x,0,'omitnan'), T.mean_dice, G);
summary.ellipse_dice_mean = splitapply(@(x) mean(x,'omitnan'), T.mean_ellipse_dice, G);
summary.ellipse_dice_std = splitapply(@(x) std(x,0,'omitnan'), T.mean_ellipse_dice, G);
summary.centroid_mean = splitapply(@(x) mean(x,'omitnan'), T.mean_centroid_error, G);
summary.centroid_std = splitapply(@(x) std(x,0,'omitnan'), T.mean_centroid_error, G);
summary.contact_mean = splitapply(@(x) mean(x,'omitnan'), T.mean_contact_rel_error, G);
summary.contact_std = splitapply(@(x) std(x,0,'omitnan'), T.mean_contact_rel_error, G);
summary.residual_mean = splitapply(@(x) mean(x,'omitnan'), T.mean_relative_residual, G);
summary.residual_std = splitapply(@(x) std(x,0,'omitnan'), T.mean_relative_residual, G);
summary.mesh_final_mean = splitapply(@(x) mean(x,'omitnan'), T.final_mesh_elems, G);
summary.mesh_gain_mean = splitapply(@(x) mean(x,'omitnan'), T.mean_mesh_gain, G);

if ~exist(cfg0.results_dir, 'dir')
    mkdir(cfg0.results_dir);
end
writetable(T, fullfile(cfg0.results_dir, 'mc_case_metrics_long.csv'));
writetable(summary, fullfile(cfg0.results_dir, 'mc_case_metrics_summary.csv'));

% Dedicated prior-sensitivity exports for the manuscript update.
prior_mask = startsWith(string(T.case_name), "shift_prior_");
writetable(T(prior_mask,:), fullfile(cfg0.results_dir, 'mc_shift_prior_sensitivity_long.csv'));
prior_summary_mask = startsWith(string(summary.case_name), "shift_prior_");
writetable(summary(prior_summary_mask,:), fullfile(cfg0.results_dir, 'mc_shift_prior_sensitivity_summary.csv'));
end

function v = get_field_or(s, name, default_val)
if isstruct(s) && isfield(s, name) && ~isempty(s.(name))
    v = s.(name);
else
    v = default_val;
end
end
