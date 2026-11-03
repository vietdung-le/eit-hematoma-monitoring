function [model_state_new, accepted, adapt_info] = adaptive_remesh(model_state, state, cfg, y, w)
%ADAPTIVE_REMESH Build next scheduled mesh if valid; final acceptance happens upstream.

model_state_new = model_state;
accepted = false;

n_old = size(model_state.fwd_model.elems,1);
adapt_info = struct('accepted', false, 'reason', "disabled", 'mesh_gain', 1, ...
    'n_elem_old', n_old, 'n_elem_new', n_old);

use_adapt = false;
if isfield(cfg,'flags') && isfield(cfg.flags,'use_adapt')
    use_adapt = logical(cfg.flags.use_adapt);
elseif isfield(cfg,'use_adapt')
    use_adapt = logical(cfg.use_adapt);
end
if ~use_adapt
    adapt_info.reason = "adapt_off";
    return;
end

cand = refine_fwd_model_uniform(model_state, cfg);
n_new = size(cand.fwd_model.elems,1);
adapt_info.n_elem_new = n_new;
adapt_info.mesh_gain = n_new / max(1,n_old);

if n_new <= n_old
    adapt_info.reason = "no_growth";
    return;
end

try
    pred_new = forward_from_state(cand, state.params, state.z, cfg);
    if any(~isfinite(pred_new))
        error('nonfinite_pred');
    end
catch ME
    warning('adaptive_remesh:rejectInvalid', 'Rejected refined mesh: %s', ME.message);
    adapt_info.reason = "invalid_refined_model";
    return;
end

model_state_new = cand;
accepted = true;
adapt_info.accepted = true;
adapt_info.reason = "accepted_valid_growth";
end
