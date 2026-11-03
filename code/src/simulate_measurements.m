function meas = simulate_measurements(model_state, truth, cfg)
%SIMULATE_MEASUREMENTS Simulate noisy voltages with contact drift and outliers.

nT = numel(truth.frames);
meas.voltage = cell(nT,1);
meas.voltage_clean = cell(nT,1);
meas.z_true = cell(nT,1);
meas.weights = cell(nT,1);
meas.weight = cell(nT,1);
meas.bad_idx = cell(nT,1);

for t = 1:nT
    z_true = cfg.contact0 .* (1 + cfg.contact_truth_jitter * randn(cfg.n_elec_total,1));
    z_true = max(cfg.contact_recon_bounds(1), min(cfg.contact_recon_bounds(2), z_true));

    fmdl = model_state.fwd_model;
    for k = 1:numel(fmdl.electrode)
        fmdl.electrode(k).z_contact = z_true(k);
    end

    img_t = truth.frames{t};
    img_t.fwd_model = fmdl;
    sol = fwd_solve(img_t);
    v_clean = as_pred_vec(sol);

    if isfield(model_state, 'contact_proj') && ~isempty(model_state.contact_proj)
        v_clean = v_clean + cfg.contact_forward_gain * model_state.contact_proj * (z_true(:) - cfg.contact0(:));
    end

    sigma_n = max(cfg.noise_std_rel * max(std(v_clean), 0.20 * mean(abs(v_clean))), 1e-6);
    v = v_clean + sigma_n * randn(size(v_clean));

    nbad = max(1, round(cfg.bad_channel_fraction * numel(v)));
    bad_idx = randperm(numel(v), nbad);
    v(bad_idx) = v(bad_idx) + 4*sigma_n.*randn(size(bad_idx(:)));

    w = ones(size(v));
    if isfield(cfg,'flags') && isfield(cfg.flags,'use_bad_channel_weights') && cfg.flags.use_bad_channel_weights
        w = robust_trim_weights(v - v_clean, bad_idx);
    end

    meas.voltage{t} = v;
    meas.voltage_clean{t} = v_clean;
    meas.z_true{t} = z_true;
    meas.weights{t} = w;
    meas.weight{t} = w;
    meas.bad_idx{t} = bad_idx(:);
end
end
