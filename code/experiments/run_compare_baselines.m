function summary = run_compare_baselines(results_dir)
% Build a baseline comparison table using actual experiment outputs.
% This function does not force a Monte Carlo run unless MC results already
% exist; it only reads what is available.

if nargin < 1 || isempty(results_dir)
    root_dir = fileparts(fileparts(mfilename('fullpath')));
    results_dir = fullfile(root_dir, 'results_compare_baselines');
else
    root_dir = fileparts(fileparts(mfilename('fullpath')));
end
if ~exist(results_dir,'dir')
    mkdir(results_dir);
end

main_results = fullfile(root_dir, 'results');
case_csv = fullfile(main_results, 'all_case_metrics.csv');
mc_csv = fullfile(main_results, 'mc_case_metrics_summary.csv');
if ~exist(case_csv, 'file')
    run_all_experiments;
end

C = readtable(case_csv);
MC = table();
if exist(mc_csv, 'file')
    MC = readtable(mc_csv);
end

order = ["conductivity_only"; "no_contact"; "no_shift"; "no_adapt"; "full"];
method_names = ["Cond-only"; "No contact"; "No shift"; "No adapt"; "Proposed full"];
summary = table('Size',[numel(order),9], ...
    'VariableTypes', {'string','double','double','double','double','double','double','double','double'}, ...
    'VariableNames', {'Method','Dice','DiceStd','VolumeError','CentroidError','Residual','RuntimeSec','MeshElems','MeshGain'});

for i = 1:numel(order)
    idx = string(C.case_names) == order(i);
    if ~any(idx)
        continue;
    end
    summary.Method(i) = method_names(i);
    summary.Dice(i) = mean(C.mean_dice(idx));
    summary.VolumeError(i) = mean(C.mean_area_error(idx));
    summary.CentroidError(i) = mean(C.mean_centroid_error(idx));
    summary.Residual(i) = mean(C.mean_residual_rel(idx));
    summary.RuntimeSec(i) = mean(C.runtime_sec(idx));
    summary.MeshElems(i) = mean(C.final_mesh_elems(idx));
    summary.MeshGain(i) = mean(C.mean_mesh_gain(idx));
    summary.DiceStd(i) = NaN;
    if ~isempty(MC)
        idxm = string(MC.case_name) == order(i);
        if any(idxm)
            summary.DiceStd(i) = mean(MC.dice_std(idxm));
            if isnan(summary.RuntimeSec(i)) || summary.RuntimeSec(i) == 0
                summary.RuntimeSec(i) = mean(MC.runtime_mean(idxm));
            end
        end
    end
end

writetable(summary, fullfile(results_dir, 'baseline_summary.csv'));
save(fullfile(results_dir, 'baseline_workspace.mat'), 'summary');
disp(summary);
end
