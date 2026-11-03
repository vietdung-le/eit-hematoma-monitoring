function [stim, meas_sel] = create_partial_stim_patterns(n_elec_total, active)
% Adjacent-drive with measurements only on active electrodes.

n_active = numel(active);
stim = repmat(struct('stim_pattern',[],'meas_pattern',[],'stimulation','Amp'), n_active, 1);
meas_sel = [];
for k = 1:n_active
    src = active(k);
    snk = active(mod(k, n_active) + 1);
    I = zeros(n_elec_total,1);
    I(src) = 1;
    I(snk) = -1;

    M = local_adjacent_meas(n_elec_total, active, src, snk);
    stim(k).stim_pattern = I;
    stim(k).meas_pattern = M;
    stim(k).stimulation = 'Amp';
    meas_sel = [meas_sel; true(size(M,1),1)]; %#ok<AGROW>
end
end

function M = local_adjacent_meas(n_total, active, src, snk)
rows = {};
na = numel(active);
for j = 1:na
    a = active(j);
    b = active(mod(j, na) + 1);
    if any([a,b] == src) || any([a,b] == snk)
        continue;
    end
    row = zeros(1, n_total);
    row(a) = 1;
    row(b) = -1;
    rows{end+1} = row; %#ok<AGROW>
end
if isempty(rows)
    M = zeros(0, n_total);
else
    M = cell2mat(rows(:));
end
end
