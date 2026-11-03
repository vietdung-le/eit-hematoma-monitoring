function cfg = default_config()
cfg.project_name = 'GO-MPIEIT-Q1';
cfg.random_seed = 20260406;
% Set EIDORS_PATH in the MATLAB session, or run EIDORS startup.m first.
% A system-specific absolute path must not be stored in a public repository.
cfg.eidors_path = getenv('EIDORS_PATH');

cfg.n_elec_total = 16;
cfg.n_elec_active = 10;
cfg.mesh_schedule = {'a2c', 'b2c', 'c2c', 'd2c'};
cfg.active_elec_mode = "contiguous";

cfg.sigma_scalp = 0.43;
cfg.sigma_skull = 0.018;
cfg.sigma_brain = 0.22;
cfg.sigma_blood = 0.70;
cfg.sigma_bg = cfg.sigma_brain;
cfg.sigma_bg_init = cfg.sigma_brain;

cfg.n_frames = 5;
cfg.truth.cx0 = 0.22;
cfg.truth.cy0 = 0.08;
cfg.truth.ax0 = 0.11;
cfg.truth.ay0 = 0.08;
cfg.truth.rotation_deg = 15;
cfg.truth.growth_per_frame = [0.00, 0.02, 0.04, 0.06, 0.08];
cfg.truth.shift_strength = 0.050;
cfg.truth.shift_decay = 0.24;

cfg.noise_std_rel = 0.005;
cfg.contact0 = 0.010 * ones(cfg.n_elec_total,1);
cfg.contact_truth_jitter = 0.25;
cfg.contact_recon_bounds = [0.001, 0.060];
cfg.contact_forward_gain = 0.65;
cfg.bad_channel_fraction = 0.03;
cfg.dropout_mode = "random";

cfg.inv.cx0 = 0.14;
cfg.inv.cy0 = -0.02;
cfg.inv.ax0 = 0.07;
cfg.inv.ay0 = 0.06;
cfg.inv.rotation_deg0 = 5;
cfg.inv.shift_strength0 = 0.015;
cfg.inv.shift_prior_ref = 0.050;
cfg.inv.sigma_brain0 = 0.20;
cfg.inv.max_iter_per_frame = 4;
cfg.inv.max_adapt_per_frame = 1;
cfg.inv.post_adapt_rebalance_steps = 2;
cfg.inv.fd_eps_shape = 1e-3;
cfg.inv.fd_eps_sigma = 1e-3;
cfg.inv.fd_eps_contact = 4e-4;
cfg.inv.step_shape = 0.95;
cfg.inv.step_sigma = 0.14;
cfg.inv.step_contact = 0.50;
cfg.inv.contact_max_rel_step = 0.10;
cfg.inv.contact_shrink = 0.08;
cfg.inv.contact_accept_ratio = 0.9995;
cfg.inv.contact_resid_gate = 0.08;
cfg.inv.contact_stress_gate = 0.20;
% "residual_or_stress" reproduces the legacy simulation trigger.
% q1_config() switches the revised analysis to the observable residual-only gate.
cfg.inv.contact_gate_mode = "residual_or_stress";
cfg.inv.adapt_resid_gate = 0.12;
cfg.inv.keep_refined_if_within = 1.01;

cfg.inv.search.cx_step = 0.08;
cfg.inv.search.cy_step = 0.06;
cfg.inv.search.ax_step = 0.04;
cfg.inv.search.ay_step = 0.03;
cfg.inv.search.shift_step = 0.03;

cfg.reg.lambda_shape = 1.2e-3;
cfg.reg.lambda_sigma = 5e-3;
cfg.reg.lambda_contact = 6e-4;
cfg.reg.lambda_temporal = 2e-3;
cfg.reg.lambda_shift = 4e-4;
cfg.reg.lambda_growth = 6e-4;
cfg.reg.lambda_center_prior = 4e-5;
cfg.reg.lambda_volume_target = 1.8e-3;

cfg.goal.weight_growth = 1.4;
cfg.goal.weight_shape_misfit = 1.7;
cfg.goal.refine_threshold = 0.08;
cfg.goal.force_refine_first_frame = true;
cfg.goal.min_mesh_gain = 1.03;

cfg.metrics.ellipse_dice_grid = 301;

cfg.mc.enable = true;
cfg.mc.seeds = cfg.random_seed + (0:5);

cfg.flags.use_contact_update = true;
cfg.flags.use_adapt = true;
cfg.flags.use_shift_model = true;
cfg.flags.use_shape_update = true;
cfg.flags.use_sigma_update = false;
cfg.flags.use_bad_channel_weights = true;

cfg.results_dir = fullfile(pwd, 'results');
end
