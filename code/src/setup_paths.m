function setup_paths(cfg)
%SETUP_PATHS Configure project and EIDORS paths with safe precedence.

this_dir = fileparts(mfilename('fullpath'));
root_dir = fileparts(this_dir);

rmpath_if_present(fullfile(root_dir, 'experiments'));
rmpath_if_present(fullfile(root_dir, 'baselines'));
rmpath_if_present(fullfile(root_dir, 'src'));
rmpath_if_present(fullfile(root_dir, 'config'));

addpath(root_dir, '-begin');
addpath(fullfile(root_dir, 'config'), '-begin');
addpath(fullfile(root_dir, 'src'), '-begin');
addpath(fullfile(root_dir, 'baselines'), '-end');
addpath(fullfile(root_dir, 'experiments'), '-end');

clear export_summary_tables export_case_summaries export_baseline_tables

if isfield(cfg, 'eidors_path') && ~isempty(cfg.eidors_path)
    if exist(cfg.eidors_path, 'dir') == 7
        startup_file = fullfile(cfg.eidors_path, 'eidors', 'startup.m');
        if exist(startup_file, 'file') ~= 2
            % Also accept cfg.eidors_path pointing directly at the eidors folder.
            startup_file = fullfile(cfg.eidors_path, 'startup.m');
        end
        if exist(startup_file, 'file') == 2
            run(startup_file);
        else
            addpath(genpath(cfg.eidors_path), '-end');
            warning('EIDORS startup.m not found; used genpath fallback: %s', cfg.eidors_path);
        end
    else
        warning(['Configured EIDORS path does not exist: %s. ' ...
                 'Set the EIDORS_PATH environment variable or edit config/default_config.m.'], ...
                 cfg.eidors_path);
    end
end
end

function rmpath_if_present(p)
if exist(p,'dir') == 7
    try
        rmpath(p);
    catch
    end
end
end
