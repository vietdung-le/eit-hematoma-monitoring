function summary = export_case_summaries(outs, cases, cfg)
if ~isfield(cfg,'results_dir') || isempty(cfg.results_dir)
    cfg.results_dir = fullfile(pwd,'results');
end
if ~exist(cfg.results_dir,'dir')
    mkdir(cfg.results_dir);
end

frame_metrics = collect_frame_table(outs, cases);
case_metrics  = collect_case_table(outs, cases);

writetable(frame_metrics, fullfile(cfg.results_dir, 'all_frame_metrics.csv'));
writetable(case_metrics,  fullfile(cfg.results_dir, 'all_case_metrics.csv'));

summary = case_metrics;

try
    plot_experiment_summary(summary, cfg);
catch ME
    warning('export_case_summaries:plotFailed', 'plot_experiment_summary failed: %s', ME.message);
end
end

function T = collect_frame_table(outs, cases)
rows = {};
for i = 1:numel(outs)
    case_name = string(cases(i).name);
    if ~isfield(outs{i},'metrics') || ~isfield(outs{i}.metrics,'frame_metrics') || isempty(outs{i}.metrics.frame_metrics)
        continue;
    end
    fm = outs{i}.metrics.frame_metrics;
    for j = 1:numel(fm)
        r = fm{j};
        rows(end+1,:) = {case_name, get_field_or(r,'frame',j), get_field_or(r,'dice',NaN), ...
            get_field_or(r,'ellipse_dice',NaN), get_field_or(r,'centroid_error',NaN), ...
            get_field_or(r,'contact_rel_error',NaN), get_field_or(r,'residual',NaN), ...
            get_field_or(r,'mesh_elems',NaN), get_field_or(r,'accepted_adapt',0)}; %#ok<AGROW>
    end
end
if isempty(rows)
    T = table();
else
    T = cell2table(rows, 'VariableNames', ...
        {'case_name','frame','dice','ellipse_dice','centroid_error','contact_rel_error','residual','mesh_elems','accepted_adapt'});
end
end

function T = collect_case_table(outs, cases)
rows = {};
for i = 1:numel(outs)
    case_name = string(cases(i).name);

    mean_dice = NaN; mean_ellipse_dice = NaN; mean_centroid_error = NaN; mean_contact_rel_error = NaN;
    mean_relative_residual = NaN; final_mesh_elems = NaN; runtime_sec = NaN;
    total_adapt = NaN; mean_mesh_gain = NaN;

    if isfield(outs{i},'metrics')
        m = outs{i}.metrics;
        mean_dice = get_field_or(m,'mean_dice',NaN);
        mean_ellipse_dice = get_field_or(m,'mean_ellipse_dice',NaN);
        mean_centroid_error = get_field_or(m,'mean_centroid_error',NaN);
        mean_contact_rel_error = get_field_or(m,'mean_contact_rel_error',NaN);
        mean_relative_residual = get_field_or(m,'mean_relative_residual',NaN);
        final_mesh_elems = get_field_or(m,'final_mesh_elems',NaN);
        total_adapt = get_field_or(m,'total_adapt',NaN);
        mean_mesh_gain = get_field_or(m,'mean_mesh_gain',NaN);
    end

    if isfield(outs{i},'runtime_sec')
        runtime_sec = outs{i}.runtime_sec;
    end

    rows(end+1,:) = {case_name, mean_dice, mean_ellipse_dice, mean_centroid_error, mean_contact_rel_error, ...
        mean_relative_residual, final_mesh_elems, runtime_sec, total_adapt, mean_mesh_gain}; %#ok<AGROW>
end

T = cell2table(rows, 'VariableNames', ...
    {'case_name','mean_dice','mean_ellipse_dice','mean_centroid_error','mean_contact_rel_error', ...
     'mean_relative_residual','final_mesh_elems','runtime_sec','total_adapt','mean_mesh_gain'});
end

function v = get_field_or(s, name, default_val)
if isstruct(s) && isfield(s,name) && ~builtin('isempty', s.(name))
    v = s.(name);
else
    v = default_val;
end
end
