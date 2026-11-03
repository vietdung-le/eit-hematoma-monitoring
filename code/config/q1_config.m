function cfg = q1_config()
cfg = default_config();
cfg.n_frames = 6;
cfg.truth.growth_per_frame = [0.00, 0.015, 0.030, 0.045, 0.060, 0.080];
cfg.noise_std_rel = 0.004;
cfg.bad_channel_fraction = 0.04;
cfg.contact_forward_gain = 0.75;
cfg.inv.max_iter_per_frame = 4;
cfg.inv.step_contact = 0.55;
cfg.inv.step_shape = 1.00;
cfg.inv.contact_accept_ratio = 0.9995;
cfg.inv.contact_resid_gate = 0.08;
% Revised submission analysis: contact updating is triggered only by the
% observable weighted residual, never by the known simulated jitter level.
cfg.inv.contact_gate_mode = "residual_only";
cfg.inv.shift_prior_ref = 0.050;
cfg.inv.keep_refined_if_within = 1.01;
cfg.inv.adapt_resid_gate = 0.12;
cfg.reg.lambda_contact = 6e-4;
cfg.reg.lambda_growth = 5e-4;
cfg.reg.lambda_center_prior = 2e-5;
cfg.goal.refine_threshold = 0.06;
cfg.goal.min_mesh_gain = 1.02;
cfg.mc.seeds = cfg.random_seed + (0:9);
end
