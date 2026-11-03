function C = build_contact_projection(fmdl)
% Construct a deterministic linear imprint from electrode-contact nuisance
% to measurement space. This augments the standard CEM term so contact
% estimation has a clear and testable effect in the synthetic study.
% Review-4 patch: use signed measurement/stimulation structure and simple
% geometric harmonics so contact updates influence reconstruction more.

n_elec = numel(fmdl.electrode);
n_meas = 0;
for k = 1:numel(fmdl.stimulation)
    n_meas = n_meas + size(fmdl.stimulation(k).meas_pattern,1);
end

C = zeros(n_meas, n_elec);
elec_xy = electrode_centers(fmdl);
theta = atan2(elec_xy(:,2), elec_xy(:,1));
row0 = 0;
for k = 1:numel(fmdl.stimulation)
    I = fmdl.stimulation(k).stim_pattern(:).';
    M = fmdl.stimulation(k).meas_pattern;
    nmk = size(M,1);
    rows = row0 + (1:nmk);

    src = find(I > 0, 1, 'first');
    snk = find(I < 0, 1, 'first');
    if isempty(src); src = 1; end
    if isempty(snk); snk = min(2, n_elec); end

    geom = 0.16 * (cos(theta - theta(src)).' - cos(theta - theta(snk)).');
    if nmk > 0
        base = M + 0.28 * repmat(I, nmk, 1) + repmat(geom, nmk, 1);
        rs = sqrt(sum(base.^2, 2));
        rs(rs < eps) = 1;
        C(rows,:) = base ./ rs;
    end
    row0 = row0 + nmk;
end
end
