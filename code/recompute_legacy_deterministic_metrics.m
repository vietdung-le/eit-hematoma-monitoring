function T = recompute_legacy_deterministic_metrics(results_dir)
%RECOMPUTE_LEGACY_DETERMINISTIC_METRICS Repair metrics in saved single-seed bundles.
%
% This does not rerun EIDORS. It recomputes the final weighted residual from
% the saved final prediction and adds oriented ellipse Dice. It is useful for
% auditing the old deterministic bundles, but it cannot repair the old
% Monte Carlo CSV because per-seed predictions were not saved there.

% Bootstrap project paths so this entry point works from a clean MATLAB session.
root_dir = fileparts(mfilename('fullpath'));
if nargin < 1 || isempty(results_dir)
    results_dir = fullfile(root_dir, '..', 'data', 'matched_model');
end
% Archived data are inputs only. Derived metrics go to code/results/.
outdir = fullfile(root_dir, 'results');
if exist(outdir,'dir') ~= 7, mkdir(outdir); end
addpath(root_dir, '-begin');
addpath(fullfile(root_dir, 'config'), '-begin');
addpath(fullfile(root_dir, 'src'), '-begin');

cfg = q1_config();
files = dir(fullfile(results_dir, '*_bundle.mat'));
rows = {};

for i = 1:numel(files)
    fn = fullfile(files(i).folder, files(i).name);
    S = load(fn, 'out', 'case_def');
    if ~isfield(S,'out') || ~isfield(S.out,'results') || ~isfield(S.out,'truth') || ~isfield(S.out,'meas')
        continue;
    end
    m = evaluate_metrics(S.out.results, S.out.truth, S.out.meas, cfg);
    case_name = erase(string(files(i).name), '_bundle.mat');
    rows(end+1,:) = {case_name, m.mean_dice, m.mean_ellipse_dice, ...
        m.mean_centroid_error, m.mean_contact_rel_error, m.mean_relative_residual}; %#ok<AGROW>
end

T = cell2table(rows, 'VariableNames', {'case_name','mean_box_dice','mean_ellipse_dice', ...
    'mean_centroid_error','mean_contact_rel_error','mean_final_weighted_residual'});
writetable(T, fullfile(outdir, 'legacy_deterministic_metrics_recomputed.csv'));
fprintf('Wrote %s\n', fullfile(outdir, 'legacy_deterministic_metrics_recomputed.csv'));
end
