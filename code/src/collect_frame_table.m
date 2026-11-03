function T = collect_frame_table(outs, cases)
rows = table();
for i = 1:numel(outs)
    Tf = outs{i}.metrics.frame;
    c = repmat(string(cases(i).name), height(Tf), 1);
    Tf = addvars(Tf, c, 'Before', 1, 'NewVariableNames', 'case_name');
    rows = [rows; Tf]; %#ok<AGROW>
end
T = rows;
end
