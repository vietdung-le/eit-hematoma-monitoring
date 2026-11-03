function plot_results(varargin)
%PLOT_RESULTS Backward-compatible plotting wrapper.
%
% Supported calls:
%   plot_results(results, case_def, cfg)
%   plot_results(model_state0, truth, meas, results, case_def, cfg)

if nargin == 3
    results  = varargin{1};
    case_def = varargin{2};
    cfg      = varargin{3};
elseif nargin == 6
    results  = varargin{4};
    case_def = varargin{5};
    cfg      = varargin{6};
else
    error('plot_results:invalidInputs', ...
        'Supported signatures: plot_results(results, case_def, cfg) or plot_results(model_state0, truth, meas, results, case_def, cfg)');
end

if ~isfield(cfg,'results_dir') || isempty(cfg.results_dir)
    return;
end

if ~isfield(results,'frames') || isempty(results.frames)
    return;
end

nT = numel(results.frames);
f = figure('Visible','off','Color','w');

dice = nan(nT,1);
resid = nan(nT,1);
goal  = nan(nT,1);

for t = 1:nT
    fr = results.frames{t};

    if isfield(fr,'metrics') && isfield(fr.metrics,'dice')
        dice(t) = fr.metrics.dice;
    end
    if isfield(fr,'resid') && ~isempty(fr.resid)
        resid(t) = fr.resid;
    end
    if isfield(fr,'goal') && ~isempty(fr.goal)
        goal(t) = fr.goal;
    end
end

subplot(3,1,1);
plot(1:nT, dice, '-o', 'LineWidth', 1.2);
xlabel('Frame');
ylabel('Dice');
title(char(case_def.name), 'Interpreter', 'none');
grid on;

subplot(3,1,2);
plot(1:nT, resid, '-o', 'LineWidth', 1.2);
xlabel('Frame');
ylabel('Residual');
title('Residual', 'Interpreter', 'none');
grid on;

subplot(3,1,3);
plot(1:nT, goal, '-o', 'LineWidth', 1.2);
xlabel('Frame');
ylabel('Goal');
title('Goal indicator', 'Interpreter', 'none');
grid on;

out_file = fullfile(cfg.results_dir, sprintf('%s_summary.png', char(case_def.name)));
exportgraphics(f, out_file, 'Resolution', 200);
close(f);
end
