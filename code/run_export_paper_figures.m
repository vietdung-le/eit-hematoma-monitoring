function run_export_paper_figures(results_dir)
%RUN_EXPORT_PAPER_FIGURES Export paper-ready figures from existing results/.
%
% Usage:
%   run_export_paper_figures
%   run_export_paper_figures('D:\...\results')
%
% The script overwrites files in:
%   results/paper_figures/
%
% Main paper-ready outputs:
%   fig_ablation_frame_overlay.(png|pdf)
%   fig_full_progression.(png|pdf)
%
% Additional outputs:
%   fig_quantitative_summary.(png|pdf)
%   fig_ablation_bar.(png|pdf)
%   fig_growth_bar.(png|pdf)
%   fig_no_shift_progression.(png|pdf)
%   fig_conductivity_only_progression.(png|pdf)
%   fig_growth_frame_overlay.(png|pdf)
%   fig_case_trajectories.(png|pdf)
%   fig_growth_trajectories.(png|pdf)

if nargin < 1 || isempty(results_dir)
    results_dir = fullfile(pwd, 'results');
end

if ~exist(results_dir, 'dir')
    error('run_export_paper_figures:missingResultsDir', ...
        'Results directory not found: %s', results_dir);
end

fig_dir = fullfile(results_dir, 'paper_figures');
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end

export_quantitative_summary(results_dir, fig_dir);
export_ablation_bar(results_dir, fig_dir);
export_growth_bar(results_dir, fig_dir);

% Main geometry figures
export_bundle_progression(results_dir, fig_dir, 'full');
export_bundle_progression(results_dir, fig_dir, 'no_shift');
export_bundle_progression(results_dir, fig_dir, 'state_off');
export_frame_overlay_comparison(results_dir, fig_dir, ...
    {'full','no_shift','state_off'}, [1 3 6], ...
    'fig_ablation_frame_overlay');
export_frame_overlay_comparison(results_dir, fig_dir, ...
    {'growth_slow','growth_medium','growth_fast'}, [1 3 6], ...
    'fig_growth_frame_overlay');

% Trajectory figures
export_case_trajectory(results_dir, fig_dir, ...
    {'full','no_contact','no_shift','state_off'}, ...
    'fig_case_trajectories');
export_case_trajectory(results_dir, fig_dir, ...
    {'growth_slow','growth_medium','growth_fast'}, ...
    'fig_growth_trajectories');

fprintf('Paper figures exported to: %s\n', fig_dir);
end

function export_quantitative_summary(results_dir, fig_dir)
csv_file = fullfile(results_dir, 'all_case_metrics.csv');
if ~exist(csv_file, 'file')
    warning('Missing %s', csv_file);
    return;
end
T = readtable(csv_file);
labels = local_pretty_labels(string(T.case_name));

fig = figure('Visible','off','Color','w','Position',[100 100 1250 780]);
tl = tiledlayout(2,2,'Padding','compact','TileSpacing','compact');

nexttile;
bar(T.mean_dice, 'FaceColor', [0.25 0.45 0.85], 'EdgeColor', 'none');
title('Mean Dice'); ylabel('Dice'); grid on;
set(gca,'XTick',1:numel(labels),'XTickLabel',labels,'XTickLabelRotation',28);
local_format_axes(gca);

nexttile;
bar(T.mean_centroid_error, 'FaceColor', [0.85 0.45 0.25], 'EdgeColor', 'none');
title('Mean centroid error'); ylabel('Error'); grid on;
set(gca,'XTick',1:numel(labels),'XTickLabel',labels,'XTickLabelRotation',28);
local_format_axes(gca);

nexttile;
bar(T.mean_relative_residual, 'FaceColor', [0.35 0.65 0.35], 'EdgeColor', 'none');
title('Mean relative residual'); ylabel('Residual'); grid on;
set(gca,'XTick',1:numel(labels),'XTickLabel',labels,'XTickLabelRotation',28);
local_format_axes(gca);

nexttile;
bar(T.mean_contact_rel_error, 'FaceColor', [0.55 0.40 0.75], 'EdgeColor', 'none');
title('Mean contact relative error'); ylabel('Relative error'); grid on;
set(gca,'XTick',1:numel(labels),'XTickLabel',labels,'XTickLabelRotation',28);
local_format_axes(gca);

title(tl, 'Quantitative summary across deterministic cases', ...
    'FontWeight', 'bold', 'FontSize', 14);
local_export_both(fig, fullfile(fig_dir, 'fig_quantitative_summary'));
close(fig);
end

function export_ablation_bar(results_dir, fig_dir)
csv_file = fullfile(results_dir, 'all_case_metrics.csv');
if ~exist(csv_file, 'file')
    return;
end
T = readtable(csv_file);
order = ["full","no_contact","no_shift","state_off","no_adapt"];
keep = ismember(string(T.case_name), order);
T = T(keep,:);
[~,ord] = ismember(string(T.case_name), order);
[~,idx] = sort(ord);
T = T(idx,:);
labels = local_pretty_labels(string(T.case_name));

fig = figure('Visible','off','Color','w','Position',[100 100 900 430]);
b = bar(T.mean_dice, 'FaceColor','flat', 'EdgeColor','none');
b.CData = [0.10 0.40 0.90;
           0.85 0.15 0.15;
           0.55 0.35 0.15;
           0.15 0.15 0.15;
           0.50 0.50 0.50];
grid on;
ylabel('Mean Dice');
title('Ablation comparison', 'FontWeight', 'bold');
set(gca,'XTick',1:height(T),'XTickLabel',labels,'XTickLabelRotation',20);
local_format_axes(gca);
local_export_both(fig, fullfile(fig_dir, 'fig_ablation_bar'));
close(fig);
end

function export_growth_bar(results_dir, fig_dir)
csv_file = fullfile(results_dir, 'all_case_metrics.csv');
if ~exist(csv_file, 'file')
    return;
end
T = readtable(csv_file);
order = ["growth_slow","growth_medium","growth_fast"];
keep = ismember(string(T.case_name), order);
T = T(keep,:);
[~,ord] = ismember(string(T.case_name), order);
[~,idx] = sort(ord);
T = T(idx,:);
labels = local_pretty_labels(string(T.case_name));

fig = figure('Visible','off','Color','w','Position',[100 100 900 430]);
b = bar(T.mean_dice, 'FaceColor','flat', 'EdgeColor','none');
b.CData = [0.65 0.45 0.20;
           0.25 0.45 0.85;
           0.15 0.60 0.35];
grid on;
ylabel('Mean Dice');
title('Growth-scenario comparison', 'FontWeight', 'bold');
set(gca,'XTick',1:height(T),'XTickLabel',labels,'XTickLabelRotation',20);
local_format_axes(gca);
local_export_both(fig, fullfile(fig_dir, 'fig_growth_bar'));
close(fig);
end

function export_case_trajectory(results_dir, fig_dir, case_names, outbase)
fig = figure('Visible','off','Color','w','Position',[100 100 920 500]);
ax = axes('Parent', fig);
hold(ax, 'on');

styles = local_case_styles();
handles = gobjects(0);
labels = strings(0);

for i = 1:numel(case_names)
    csv_file = fullfile(results_dir, sprintf('%s_frame_metrics.csv', case_names{i}));
    if ~exist(csv_file, 'file')
        continue;
    end
    T = readtable(csv_file);
    st = styles.(char(case_names{i}));
    h = plot(ax, T.frame, T.dice, ...
        'LineStyle', st.lineStyle, ...
        'Color', st.color, ...
        'LineWidth', 2.2, ...
        'Marker', st.marker, ...
        'MarkerSize', 7.5, ...
        'MarkerFaceColor', 'w', ...
        'DisplayName', st.label);
    handles(end+1) = h; %#ok<AGROW>
    labels(end+1) = string(st.label); %#ok<AGROW>
end

grid(ax, 'on');
xlabel(ax, 'Frame');
ylabel(ax, 'Dice');
title(ax, 'Frame-wise Dice trajectories', 'FontWeight', 'bold');
local_format_axes(ax);
xlim(ax, [1 6]);

lgd = legend(ax, handles, cellstr(labels), ...
    'Orientation', 'horizontal', 'Box', 'off', 'Location', 'southoutside');
lgd.FontSize = 10;
local_export_both(fig, fullfile(fig_dir, outbase));
close(fig);
end

function export_bundle_progression(results_dir, fig_dir, case_name)
mat_file = fullfile(results_dir, sprintf('%s_bundle.mat', case_name));
if ~exist(mat_file, 'file')
    warning('Missing %s', mat_file);
    return;
end

S = load(mat_file, 'out');
out = S.out;
if ~isfield(out,'results') || ~isfield(out.results,'frames')
    return;
end

nT = numel(out.results.frames);
frames_to_show = unique(round(linspace(1, nT, min(nT,3))));
styles = local_case_styles();
st = styles.(char(case_name));

fig = figure('Visible','off','Color','w','Position',[100 100 980 375]);
tl = tiledlayout(1, numel(frames_to_show), 'Padding','compact', 'TileSpacing','compact');

hTruth = gobjects(1);
hRec = gobjects(1);
axFirst = [];

for j = 1:numel(frames_to_show)
    t = frames_to_show(j);
    ax = nexttile;
    if isempty(axFirst), axFirst = ax; end
    hold(ax, 'on');

    fmdl = local_get_fwd_model(out, t);
    if ~isempty(fmdl)
        local_plot_mesh(ax, fmdl);
        local_apply_domain_limits(ax, fmdl);
    end

    p_truth = local_get_truth_params(out, t);
    p_rec   = local_get_rec_params(out, t);

    h1 = local_plot_ellipse(ax, p_truth, '-', 2.4, [0.15 0.15 0.15]);
    h2 = local_plot_ellipse(ax, p_rec,  st.lineStyle, 2.6, st.color);

    if j == 1
        hTruth = h1;
        hRec = h2;
    end

    axis(ax, 'equal');
    axis(ax, 'off');
    box(ax, 'on');
    local_panel_title(ax, j, t);
end

local_bottom_legend(fig, axFirst, [hTruth hRec], {'Truth', st.label});
if strcmpi(case_name, 'full')
    ttl = 'Representative progression of the full model';
else
    ttl = sprintf('Representative %s progression', lower(st.label));
end
title(tl, ttl, 'FontWeight', 'bold', 'FontSize', 14);
local_export_both(fig, fullfile(fig_dir, sprintf('fig_%s_progression', case_name)));
close(fig);
end

function export_frame_overlay_comparison(results_dir, fig_dir, case_names, frames_to_show, outbase)
fig = figure('Visible','off','Color','w','Position',[100 100 980 390]);
tl = tiledlayout(1, numel(frames_to_show), 'Padding','compact', 'TileSpacing','compact');

base_case = case_names{1};
base_mat = fullfile(results_dir, sprintf('%s_bundle.mat', base_case));
if ~exist(base_mat, 'file')
    warning('Missing %s', base_mat);
    return;
end
S = load(base_mat, 'out');
out0 = S.out;

styles = local_case_styles();
legend_handles = gobjects(0);
legend_labels = strings(0);
axFirst = [];

for j = 1:numel(frames_to_show)
    t = frames_to_show(j);
    ax = nexttile;
    if isempty(axFirst), axFirst = ax; end
    hold(ax, 'on');

    fmdl = local_get_fwd_model(out0, t);
    if ~isempty(fmdl)
        local_plot_mesh(ax, fmdl);
        local_apply_domain_limits(ax, fmdl);
    end

    p_truth = local_get_truth_params(out0, min(t, numel(out0.results.frames)));
    hTruth = local_plot_ellipse(ax, p_truth, '-', 2.5, [0.10 0.10 0.10]);

    if j == 1
        legend_handles(end+1) = hTruth; %#ok<AGROW>
        legend_labels(end+1) = "Truth"; %#ok<AGROW>
    end

    for i = 1:numel(case_names)
        mat_file = fullfile(results_dir, sprintf('%s_bundle.mat', case_names{i}));
        if ~exist(mat_file, 'file')
            continue;
        end
        S1 = load(mat_file, 'out');
        p_rec = local_get_rec_params(S1.out, t);
        st = styles.(char(case_names{i}));
        h = local_plot_ellipse(ax, p_rec, st.lineStyle, 2.4, st.color);
        if j == 1
            legend_handles(end+1) = h; %#ok<AGROW>
            legend_labels(end+1) = string(st.label); %#ok<AGROW>
        end
    end

    axis(ax, 'equal');
    axis(ax, 'off');
    box(ax, 'on');
    local_panel_title(ax, j, t);
end

local_bottom_legend(fig, axFirst, legend_handles, cellstr(legend_labels));
title(tl, 'Representative truth-versus-reconstruction comparison', ...
    'FontWeight', 'bold', 'FontSize', 14);
local_export_both(fig, fullfile(fig_dir, outbase));
close(fig);
end

function local_plot_mesh(ax, fmdl)
patch(ax, 'Faces', fmdl.elems, 'Vertices', fmdl.nodes, ...
    'FaceColor', 'none', ...
    'EdgeColor', [0.86 0.86 0.86], ...
    'LineWidth', 0.30);
end

function local_apply_domain_limits(ax, fmdl)
xy = fmdl.nodes;
xmin = min(xy(:,1)); xmax = max(xy(:,1));
ymin = min(xy(:,2)); ymax = max(xy(:,2));
dx = xmax - xmin; dy = ymax - ymin;
pad = 0.005 * max(dx,dy);
xlim(ax, [xmin-pad, xmax+pad]);
ylim(ax, [ymin-pad, ymax+pad]);
end

function local_panel_title(ax, j, frame_id)
letters = 'abcdefghijklmnopqrstuvwxyz';
title(ax, sprintf('(%c) Frame %d', letters(j), frame_id), ...
    'FontWeight', 'bold', 'FontSize', 12);
end

function lgd = local_bottom_legend(fig, axRef, handles, labels)
valid = isgraphics(handles);
handles = handles(valid);
labels = labels(valid);
if isempty(handles)
    lgd = [];
    return;
end

% Create a tiny invisible axes dedicated to the legend.
axLeg = axes('Parent', fig, ...
    'Position', [0.10 0.00 0.80 0.01], ...
    'Visible', 'off');
lgd = legend(axLeg, handles, labels, ...
    'Orientation', 'horizontal', ...
    'Box', 'off', ...
    'Location', 'south');
lgd.FontSize = 10;

% Keep panel area large while placing legend below.
try
    lgd.Units = 'normalized';
    lgd.Position(2) = 0.01;
catch
end

% Also make sure the first axes does not auto-delete legend association.
if ~isempty(axRef) && isgraphics(axRef)
    axes(axRef); %#ok<LAXES>
end
end

function fmdl = local_get_fwd_model(out, t)
fmdl = [];
try
    fr = out.results.frames{t};
    if isfield(fr,'model_state') && isstruct(fr.model_state) && isfield(fr.model_state,'fwd_model')
        fmdl = fr.model_state.fwd_model;
    elseif isfield(out,'model_state0') && isstruct(out.model_state0) && isfield(out.model_state0,'fwd_model')
        fmdl = out.model_state0.fwd_model;
    end
catch
end
end

function p = local_get_truth_params(out, t)
p = struct('cx',0,'cy',0,'ax',0.05,'ay',0.05,'rot',0);
try
    if isfield(out,'truth') && isfield(out.truth,'params')
        if iscell(out.truth.params)
            p = out.truth.params{t};
        else
            p = out.truth.params(t);
        end
        return;
    end
catch
end
end

function p = local_get_rec_params(out, t)
p = struct('cx',0,'cy',0,'ax',0.05,'ay',0.05,'rot',0);
try
    fr = out.results.frames{t};
    if isfield(fr,'state') && isstruct(fr.state) && isfield(fr.state,'params')
        p = fr.state.params;
        return;
    end
    if isfield(fr,'params')
        p = fr.params;
        return;
    end
catch
end
end

function h = local_plot_ellipse(ax, p, line_style, line_width, color)
if isempty(p) || ~isstruct(p)
    h = plot(ax, nan, nan);
    return;
end
cx = local_field(p,'cx',0);
cy = local_field(p,'cy',0);
axr = max(local_field(p,'ax',0.05), 1e-4);
ayr = max(local_field(p,'ay',0.05), 1e-4);
rot = local_field(p,'rot',0);

tt = linspace(0,2*pi,240);
R = [cos(rot), -sin(rot); sin(rot), cos(rot)];
xy = R * [axr*cos(tt); ayr*sin(tt)];
h = plot(ax, cx + xy(1,:), cy + xy(2,:), ...
    'LineStyle', line_style, ...
    'LineWidth', line_width, ...
    'Color', color);
end

function styles = local_case_styles()
styles.full = struct('color',[0.00 0.35 0.85], 'lineStyle','--', 'marker','o', 'label','Full');
styles.no_contact = struct('color',[0.80 0.10 0.10], 'lineStyle','-', 'marker','s', 'label','No-contact');
styles.no_shift = struct('color',[0.82 0.42 0.00], 'lineStyle','-', 'marker','^', 'label','No-shift');
styles.conductivity_only = struct('color',[0.72 0.50 0.00], 'lineStyle','-.', 'marker','d', 'label','Legacy state-off');
styles.state_off = struct('color',[0.30 0.30 0.30], 'lineStyle',':', 'marker','d', 'label','State-off');
styles.no_adapt = struct('color',[0.45 0.45 0.45], 'lineStyle','-', 'marker','x', 'label','No-adapt');
styles.growth_slow = struct('color',[0.65 0.45 0.20], 'lineStyle','-', 'marker','o', 'label','Growth-slow');
styles.growth_medium = struct('color',[0.25 0.45 0.85], 'lineStyle','-', 'marker','s', 'label','Growth-medium');
styles.growth_fast = struct('color',[0.15 0.60 0.35], 'lineStyle','-', 'marker','^', 'label','Growth-fast');
end

function labels = local_pretty_labels(raw)
labels = strings(size(raw));
for i = 1:numel(raw)
    key = char(raw(i));
    switch key
        case 'full'
            labels(i) = "Full";
        case 'no_contact'
            labels(i) = "No-contact";
        case 'no_shift'
            labels(i) = "No-shift";
        case 'conductivity_only'
            labels(i) = "Legacy state-off";
        case 'state_off'
            labels(i) = "State-off";
        case 'no_adapt'
            labels(i) = "No-adapt";
        case 'growth_slow'
            labels(i) = "Growth-slow";
        case 'growth_medium'
            labels(i) = "Growth-medium";
        case 'growth_fast'
            labels(i) = "Growth-fast";
        case 'rob_noise_low'
            labels(i) = "Noise-low";
        case 'rob_noise_mid'
            labels(i) = "Noise-mid";
        case 'rob_noise_high'
            labels(i) = "Noise-high";
        case 'rob_contact_heavy'
            labels(i) = "Contact-heavy";
        case 'rob_dropout_heavy'
            labels(i) = "Dropout-heavy";
        case 'rob_partial_8'
            labels(i) = "Partial-8";
        otherwise
            labels(i) = string(strrep(key, '_', '-'));
    end
end
end

function v = local_field(s, name, default_val)
if isstruct(s) && isfield(s,name) && ~isempty(s.(name))
    v = s.(name);
else
    v = default_val;
end
end

function local_format_axes(ax)
ax.FontSize = 11;
ax.LineWidth = 0.8;
ax.Box = 'on';
ax.GridAlpha = 0.20;
ax.Layer = 'top';
end

function local_export_both(fig, outbase)
set(fig, 'Renderer', 'painters');
exportgraphics(fig, [outbase '.png'], 'Resolution', 600);
exportgraphics(fig, [outbase '.pdf'], 'ContentType', 'vector');
end
