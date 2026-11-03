function export_baseline_tables(results_dir)
if nargin < 1
    results_dir = fullfile(pwd, 'results_compare_baselines');
end

csv_file = fullfile(results_dir, 'baseline_summary.csv');
if ~exist(csv_file, 'file')
    error('Missing baseline_summary.csv. Run run_compare_baselines first.');
end

T = readtable(csv_file);
tex_file = fullfile(results_dir, 'table_baseline_summary.tex');
fid = fopen(tex_file, 'w');

fprintf(fid, '\\begin{tabular}{lccccccc}\n');
fprintf(fid, '\\hline\n');
fprintf(fid, 'Method & Dice & DiceStd & AreaErr & CentroidErr & Residual & Runtime & MeshElems \\\\n');
fprintf(fid, '\\hline\n');
for i = 1:height(T)
    fprintf(fid, '%s & %.3f & %.3f & %.3f & %.3f & %.3f & %.2f & %.0f \\\\n', ...
        string(T.Method(i)), T.Dice(i), T.DiceStd(i), T.VolumeError(i), T.CentroidError(i), ...
        T.Residual(i), T.RuntimeSec(i), T.MeshElems(i));
end
fprintf(fid, '\\hline\n');
fprintf(fid, '\\end{tabular}\n');
fclose(fid);
end
