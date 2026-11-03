function generate_paper_figures(results_dir)
if nargin < 1
    results_dir = fullfile(pwd, 'results_compare_baselines');
end

csv_file = fullfile(results_dir, 'baseline_summary.csv');
if ~exist(csv_file, 'file')
    error('Missing baseline_summary.csv. Run run_compare_baselines first.');
end

T = readtable(csv_file);
fig_dir = fullfile(results_dir, 'paper_figures');
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
labels = pretty_case_labels(T.Method, true);

f1 = figure('Color','w','Position',[100 100 1200 480]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile;
bar(T.Residual);
set(gca,'XTick',1:height(T),'XTickLabel',labels,'TickLabelInterpreter','none');
ylabel('Residual'); title('Data misfit comparison'); grid on;
nexttile;
bar(T.Dice);
hold on;
if any(T.DiceStd > 0)
    errorbar(1:height(T), T.Dice, T.DiceStd, '.k');
end
set(gca,'XTick',1:height(T),'XTickLabel',labels,'TickLabelInterpreter','none');
ylabel('Dice'); title('Dice comparison'); grid on;
exportgraphics(f1, fullfile(fig_dir, 'fig_residual_dice_comparison.png'), 'Resolution', 300);
close(f1);

f2 = figure('Color','w','Position',[100 100 1200 480]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile;
bar(T.RuntimeSec);
set(gca,'XTick',1:height(T),'XTickLabel',labels,'TickLabelInterpreter','none');
ylabel('Runtime (s)'); title('Runtime comparison'); grid on;
nexttile;
bar(T.MeshElems);
set(gca,'XTick',1:height(T),'XTickLabel',labels,'TickLabelInterpreter','none');
ylabel('Final mesh elements'); title('Mesh size comparison'); grid on;
exportgraphics(f2, fullfile(fig_dir, 'fig_runtime_mesh_comparison.png'), 'Resolution', 300);
close(f2);
end
