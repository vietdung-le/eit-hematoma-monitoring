function results = r2_reconstruct_sequence_logged(model_state, truth, meas, state, cfg)
%R2_RECONSTRUCT_SEQUENCE_LOGGED Unmodified reconstruction decisions plus event counters.
% This is a separate copy to avoid overwriting the submitted algorithm.
%
% Revision-5 changes:
%   1) the contact trigger can be residual-only (q1_config default),
%   2) the residual used by the trigger is the CURRENT post-state-search
%      residual rather than the pre-update residual,
%   3) the stored frame residual is recomputed from the final accepted
%      prediction to prevent stale residual reporting.

nT = numel(meas.voltage);
frames = cell(nT,1);
contact_attempts = zeros(nT,1);
contact_accepts = zeros(nT,1);

current_model_state = model_state;
current_state = state;
n_iter = 4;
if isfield(cfg,'inv') && isfield(cfg.inv,'max_iter_per_frame') && ~isempty(cfg.inv.max_iter_per_frame)
    n_iter = max(2, min(6, round(cfg.inv.max_iter_per_frame)));
end

for t = 1:nT
    fprintf('Reconstructing frame %d / %d\n', t, nT);

    y = meas.voltage{t};
    if isfield(meas,'weights') && numel(meas.weights) >= t && ~isempty(meas.weights{t})
        w = meas.weights{t};
    elseif isfield(meas,'weight') && numel(meas.weight) >= t && ~isempty(meas.weight{t})
        w = meas.weight{t};
    else
        w = ones(size(y));
    end

    current_pred = forward_from_state(current_model_state, current_state.params, current_state.z, cfg);
    [best_obj, resid_cur] = compute_objective(y, current_pred, w, current_state, cfg);
    best_goal = compute_goal_indicator(current_model_state, current_state, y, w, cfg);

    for it = 1:n_iter
        improved = false;

        if isfield(cfg,'flags') && isfield(cfg.flags,'use_shape_update') && cfg.flags.use_shape_update
            p_try = update_hematoma_params(current_model_state, current_state, y, w, cfg);
            state_try = current_state;
            state_try.params = p_try;
            pred_try = forward_from_state(current_model_state, state_try.params, state_try.z, cfg);
            [obj_try, resid_try] = compute_objective(y, pred_try, w, state_try, cfg);
            if obj_try + 1e-9 < best_obj
                current_state = state_try;
                current_pred = pred_try;
                best_obj = obj_try;
                resid_cur = resid_try;
                improved = true;
            end
        end

        do_contact = local_contact_gate(resid_cur, cfg);
        if do_contact
            contact_attempts(t) = contact_attempts(t) + 1;
            z_try = update_contact_impedance(current_model_state, current_state, y, w, current_pred, cfg);
            state_try = current_state;
            state_try.z = z_try;
            pred_try = forward_from_state(current_model_state, state_try.params, state_try.z, cfg);
            [obj_try, resid_try] = compute_objective(y, pred_try, w, state_try, cfg);
            accept_ratio = local_cfg(cfg, {'inv','contact_accept_ratio'}, 0.9995);
            if obj_try <= accept_ratio * best_obj
                contact_accepts(t) = contact_accepts(t) + 1;
                current_state = state_try;
                current_pred = pred_try;
                best_obj = obj_try;
                resid_cur = resid_try;
                improved = true;
            end
        end

        if ~improved
            break;
        end
    end

    best_goal = compute_goal_indicator(current_model_state, current_state, y, w, cfg);

    accepted = false;
    adapt_info = struct('accepted',false,'mesh_gain',1,'n_elem_old',size(current_model_state.fwd_model.elems,1), ...
                        'n_elem_new',size(current_model_state.fwd_model.elems,1),'reason',"skipped");

    do_adapt = false;
    if isfield(cfg,'flags') && isfield(cfg.flags,'use_adapt') && cfg.flags.use_adapt
        resid_gate = local_cfg(cfg, {'inv','adapt_resid_gate'}, 0.12);
        do_adapt = (t == 1) || (resid_cur > resid_gate);
    end

    if do_adapt
        [model_state_new, accepted_raw, adapt_info] = adaptive_remesh(current_model_state, current_state, cfg, y, w);
        if accepted_raw
            pred_new = forward_from_state(model_state_new, current_state.params, current_state.z, cfg);
            [obj_new, resid_new] = compute_objective(y, pred_new, w, current_state, cfg);
            goal_new = compute_goal_indicator(model_state_new, current_state, y, w, cfg);

            keep_ratio = local_cfg(cfg, {'inv','keep_refined_if_within'}, 1.01);
            if obj_new <= keep_ratio * best_obj && adapt_info.mesh_gain > 1
                current_model_state = model_state_new;
                current_pred = pred_new;
                best_obj = obj_new;
                resid_cur = resid_new;
                best_goal = goal_new;
                accepted = true;
                adapt_info.accepted = true;
                adapt_info.reason = "accepted_obj_safe";
            else
                accepted = false;
                adapt_info.accepted = false;
                adapt_info.reason = "rejected_obj_worse";
            end
        end
    end

    % Recompute from the final accepted prediction. This guards the exported
    % residual against stale values after shape/contact updates.
    [~, resid_cur] = compute_objective(y, current_pred, w, current_state, cfg);

    frame = struct();
    frame.pred = current_pred;
    frame.obj = best_obj;
    frame.resid = resid_cur;
    frame.goal = best_goal;
    frame.state = current_state;
    frame.model_state = current_model_state;
    frame.adapt_info = adapt_info;
    frame.accepted_adapt = accepted;
    frames{t} = frame;

    current_state.prev_params = current_state.params;
    current_state.prev_z = current_state.z;
end

results = struct();
results.frames = frames;
results.truth = truth;
results.meas = meas;
results.r2_contact_attempts = contact_attempts;
results.r2_contact_accepts = contact_accepts;
end

function tf = local_contact_gate(resid_cur, cfg)
tf = false;
if ~(isfield(cfg,'flags') && isfield(cfg.flags,'use_contact_update') && cfg.flags.use_contact_update)
    return;
end

resid_gate = local_cfg(cfg, {'inv','contact_resid_gate'}, 0.08);
mode = "residual_only";
if isfield(cfg,'inv') && isfield(cfg.inv,'contact_gate_mode') && ~isempty(cfg.inv.contact_gate_mode)
    mode = string(cfg.inv.contact_gate_mode);
end

switch lower(mode)
    case "residual_only"
        tf = resid_cur > resid_gate;
    case "residual_or_stress"
        stress_gate = local_cfg(cfg, {'inv','contact_stress_gate'}, 0.20);
        design_stress = local_cfg(cfg, {'contact_truth_jitter'}, 0);
        tf = (resid_cur > resid_gate) || (design_stress >= stress_gate);
    otherwise
        error('reconstruct_sequence:UnknownContactGateMode', ...
            'Unknown cfg.inv.contact_gate_mode: %s', char(mode));
end
end

function v = local_cfg(cfg, path, default_val)
v = default_val;
try
    cur = cfg;
    for i = 1:numel(path)
        cur = cur.(path{i});
    end
    if ~isempty(cur)
        v = cur;
    end
catch
end
end
