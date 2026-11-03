function goal = compute_goal_indicator(model_state, state, y, w, cfg)
if isnumeric(model_state) || (isstruct(model_state) && (isfield(model_state,'v') || isfield(model_state,'meas')))
    pred_vec = as_pred_vec(model_state);
else
    pred_vec = forward_from_state(model_state, state.params, state.z, cfg);
end

y = y(:); w = w(:); pred_vec = pred_vec(:);
k = min([numel(y), numel(w), numel(pred_vec)]);
y = y(1:k); w = w(1:k); pred_vec = pred_vec(1:k);

resid = (y - pred_vec) .* w;
goal = norm(resid);

if isstruct(state) && isfield(state,'params') && isstruct(state.params)
    p = state.params;
    if isfield(p,'ax') && isfield(p,'ay')
        goal = goal + local_cfg(cfg, {'goal','weight_growth'}, 0.5) * abs(p.ax * p.ay);
    end
    if isfield(p,'shift_strength')
        goal = goal + local_cfg(cfg, {'goal','weight_shape_misfit'}, 0.5) * abs(p.shift_strength);
    end
end
end

function v = local_cfg(cfg, path, default_val)
v = default_val;
try
    cur = cfg;
    for i = 1:numel(path)
        cur = cur.(path{i});
    end
    if isnumeric(cur) && ~isempty(cur), v = cur; end
catch
end
end
