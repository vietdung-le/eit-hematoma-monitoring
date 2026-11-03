function plot_experiment_summary(summary, cfg)
%PLOT_EXPERIMENT_SUMMARY Plot aggregate case-level summary from the new table format.

if istable(summary)
    T = summary;
elseif isstruct(summary) && isfield(summary,'case_metrics')
    T = summary.case_metrics;
else
    error('plot_experiment_summary:invalidInput', ...
        'Expected a table or a struct with field case_metrics.');
end

if isempty(T) || ~istable(T)
    return;
end

if ~isfield(cfg,'results_dir') || isempty(cfg.results_dir)
    cfg.results_dir = fullfile(pwd,'results');
end
if ~exist(cfg.results_dir,'dir')
    mkdir(cfg.results_dir);
end

% Expected variable names from export_case_summaries
name_var = 'case_name';
dice_var = 'mean_dice';
centroid_var = 'mean_centroid_error';
contact_var = 'mean_contact_rel_error';
resid_var = 'mean_relative_residual';
mesh_var = 'final_mesh_elems';

if ~ismember(name_var, T.Properties.VariableNames)
    error('plot_experiment_summary:missingCaseName', ...
        'Missing table variable: %s', name_var);
end

labels = pretty_case_labels(string(T.(name_var)), false);

f = figure('Visible','off','Color','w');

subplot(2,2,1);
if ismember(dice_var, T.Properties.VariableNames)
    bar(T.(dice_var));
end
xticklabels(labels);
xtickangle(30);
ylabel('Dice');
title('Mean Dice', 'Interpreter', 'none');
grid on;

subplot(2,2,2);
if ismember(centroid_var, T.Properties.VariableNames)
    bar(T.(centroid_var));
end
xticklabels(labels);
xtickangle(30);
ylabel('Error');
title('Mean centroid error', 'Interpreter', 'none');
grid on;

subplot(2,2,3);
if ismember(resid_var, T.Properties.VariableNames)
    bar(T.(resid_var));
end
xticklabels(labels);
xtickangle(30);
ylabel('Residual');
title('Mean relative residual', 'Interpreter', 'none');
grid on;

subplot(2,2,4);
if ismember(mesh_var, T.Properties.VariableNames)
    bar(T.(mesh_var));
end
xticklabels(labels);
xtickangle(30);
ylabel('Elements');
title('Final mesh elements', 'Interpreter', 'none');
grid on;

sgtitle('GO-MPIEIT-Q1 aggregate summary', 'Interpreter', 'none');

exportgraphics(f, fullfile(cfg.results_dir, 'aggregate_summary.png'), 'Resolution', 200);
close(f);
end
