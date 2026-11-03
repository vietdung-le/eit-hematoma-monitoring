function prepare_results_dir(results_dir, mode)
% Remove stale output files so each run exports a consistent result set.

if nargin < 2 || isempty(mode)
    mode = 'standard';
end

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

switch lower(string(mode))
    case "standard"
        patterns = {
            '*_bundle.mat', '*_frame_metrics.csv', '*_summary.png', '*_mesh_progression.png', ...
            'all_case_metrics.csv', 'all_frame_metrics.csv', 'aggregate_summary.png'};
    case "mc"
        patterns = {'mc_case_metrics_long.csv', 'mc_case_metrics_summary.csv', 'mc_summary.png'};
    otherwise
        patterns = {'all_case_metrics.csv', 'all_frame_metrics.csv', 'aggregate_summary.png'};
end

for i = 1:numel(patterns)
    files = dir(fullfile(results_dir, patterns{i}));
    for k = 1:numel(files)
        delete(fullfile(results_dir, files(k).name));
    end
end
end
