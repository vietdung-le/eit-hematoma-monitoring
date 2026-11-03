function save_results_bundle(out, case_def, cfg)
%SAVE_RESULTS_BUNDLE Save MAT + per-frame CSV + per-case CSV.

if ~isfield(cfg, 'results_dir') || isempty(cfg.results_dir)
    return;
end
if ~exist(cfg.results_dir, 'dir')
    mkdir(cfg.results_dir);
end

name = char(case_def.name);
save(fullfile(cfg.results_dir, sprintf('%s_bundle.mat', name)), 'out', 'case_def');

if isfield(out, 'metrics') && isfield(out.metrics, 'frame_metrics') && ~isempty(out.metrics.frame_metrics)
    Tframe = local_frame_metrics_to_table(out.metrics.frame_metrics);
    writetable(Tframe, fullfile(cfg.results_dir, sprintf('%s_frame_metrics.csv', name)));
end

Tcase = local_case_metrics_to_table(out, case_def);
writetable(Tcase, fullfile(cfg.results_dir, sprintf('%s_case_metrics.csv', name)));
end

function T = local_frame_metrics_to_table(frame_metrics)
n = numel(frame_metrics);
frame = nan(n,1);
dice = nan(n,1);
ellipse_dice = nan(n,1);
centroid_error = nan(n,1);
contact_rel_error = nan(n,1);
residual = nan(n,1);
mesh_elems = nan(n,1);

for i = 1:n
    fm = frame_metrics{i};
    if isfield(fm,'frame'), frame(i) = fm.frame; end
    if isfield(fm,'dice'), dice(i) = fm.dice; end
    if isfield(fm,'ellipse_dice'), ellipse_dice(i) = fm.ellipse_dice; end
    if isfield(fm,'centroid_error'), centroid_error(i) = fm.centroid_error; end
    if isfield(fm,'contact_rel_error'), contact_rel_error(i) = fm.contact_rel_error; end
    if isfield(fm,'residual'), residual(i) = fm.residual; end
    if isfield(fm,'mesh_elems'), mesh_elems(i) = fm.mesh_elems; end
end

T = table(frame, dice, ellipse_dice, centroid_error, contact_rel_error, residual, mesh_elems);
end

function T = local_case_metrics_to_table(out, case_def)
case_name = string(case_def.name);
mean_dice = NaN;
mean_ellipse_dice = NaN;
mean_centroid_error = NaN;
mean_contact_rel_error = NaN;
mean_relative_residual = NaN;
final_mesh_elems = NaN;
runtime_sec = NaN;

if isfield(out,'metrics')
    m = out.metrics;
    if isfield(m,'mean_dice'), mean_dice = m.mean_dice; end
    if isfield(m,'mean_ellipse_dice'), mean_ellipse_dice = m.mean_ellipse_dice; end
    if isfield(m,'mean_centroid_error'), mean_centroid_error = m.mean_centroid_error; end
    if isfield(m,'mean_contact_rel_error'), mean_contact_rel_error = m.mean_contact_rel_error; end
    if isfield(m,'mean_relative_residual'), mean_relative_residual = m.mean_relative_residual; end
    if isfield(m,'final_mesh_elems'), final_mesh_elems = m.final_mesh_elems; end
end
if isfield(out,'runtime_sec')
    runtime_sec = out.runtime_sec;
end

T = table(case_name, mean_dice, mean_ellipse_dice, mean_centroid_error, mean_contact_rel_error, ...
          mean_relative_residual, final_mesh_elems, runtime_sec);
end
