function truth = generate_truth_sequence(model_state, truth, cfg)
% Generate truth frames and associated parameters.

frames = cell(cfg.n_frames,1);
params = repmat(struct('cx',0,'cy',0,'ax',0,'ay',0,'rot',0,'shift_strength',0,'sigma_brain',0), cfg.n_frames, 1);

for t = 1:cfg.n_frames
    p = struct();
    p.cx = cfg.truth.cx0;
    p.cy = cfg.truth.cy0;
    p.ax = cfg.truth.ax0 + cfg.truth.growth_per_frame(t);
    p.ay = cfg.truth.ay0 + 0.75 * cfg.truth.growth_per_frame(t);
    p.rot = deg2rad(cfg.truth.rotation_deg);
    p.shift_strength = cfg.truth.shift_strength * (1 + 0.6*cfg.truth.growth_per_frame(t)/max(cfg.truth.growth_per_frame(end),1e-6));
    p.sigma_brain = cfg.sigma_brain;
    frames{t} = apply_hematoma_and_shift(truth.base_img, p, cfg);
    params(t) = p;
end

truth.frames = frames;
truth.params = params;
end
