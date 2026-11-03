function out = run_single_experiment(exp_case, cfg0)
cfg = apply_case_overrides(cfg0, exp_case);
rng(exp_case.seed, 'twister');

tic;
[model_state, truth] = build_head_model(cfg);
truth = generate_truth_sequence(model_state, truth, cfg);
meas = simulate_measurements(model_state, truth, cfg);
state = initialize_inverse_state(model_state, cfg);
results = reconstruct_sequence(model_state, truth, meas, state, cfg);
runtime_sec = toc;
metrics = evaluate_metrics(results, truth, meas, cfg);

out = struct();
out.cfg = cfg;
out.case = exp_case;
out.model_state0 = model_state;
out.truth = truth;
out.meas = meas;
out.results = results;
out.metrics = metrics;
out.runtime_sec = runtime_sec;
end

function cfg = apply_case_overrides(cfg, exp_case)
if isfield(exp_case, 'overrides') && ~isempty(exp_case.overrides)
    ov = exp_case.overrides;
    if isfield(ov, 'scalar')
        fns = fieldnames(ov.scalar);
        for i = 1:numel(fns), cfg.(fns{i}) = ov.scalar.(fns{i}); end
    end
    if isfield(ov, 'flags')
        fns = fieldnames(ov.flags);
        for i = 1:numel(fns), cfg.flags.(fns{i}) = ov.flags.(fns{i}); end
        if isfield(cfg.flags,'use_shift_model') && ~cfg.flags.use_shift_model
            cfg.inv.shift_strength0 = 0;
        end
    end
    if isfield(ov, 'truth')
        fns = fieldnames(ov.truth);
        for i = 1:numel(fns), cfg.truth.(fns{i}) = ov.truth.(fns{i}); end
        if isfield(ov.truth, 'growth_per_frame')
            cfg.n_frames = numel(ov.truth.growth_per_frame);
        end
    end
    if isfield(ov, 'inv')
        fns = fieldnames(ov.inv);
        for i = 1:numel(fns), cfg.inv.(fns{i}) = ov.inv.(fns{i}); end
    end
end
end
