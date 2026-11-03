function [obj, resid_norm] = compute_objective(y, pred, w, state, cfg)
%COMPUTE_OBJECTIVE Shape/growth/shift-first objective.

y = y(:); w = w(:); pred = as_pred_vec(pred);
k = min([numel(y), numel(w), numel(pred)]);
y = y(1:k); w = w(1:k); pred = pred(1:k);

resid = (y - pred) .* w;
resid_norm = norm(resid);
obj = 0.5 * (resid.' * resid);

lam_growth   = local_cfg(cfg, {'reg','lambda_growth'}, 0);
lam_center   = local_cfg(cfg, {'reg','lambda_center_prior'}, 0);
lam_contact  = local_cfg(cfg, {'reg','lambda_contact'}, 0);
lam_shift    = local_cfg(cfg, {'reg','lambda_shift'}, 0);
lam_temporal = local_cfg(cfg, {'reg','lambda_temporal'}, 0);
lam_vol      = local_cfg(cfg, {'reg','lambda_volume_target'}, 0);

if nargin >= 4 && isstruct(state)
    if isfield(state,'params') && isstruct(state.params)
        p = state.params;

        ax = local_field(p,'ax',0.05);
        ay = local_field(p,'ay',0.05);
        area = max(ax*ay,1e-8);
        obj = obj + lam_growth * area + lam_vol * (sqrt(area) - 0.11)^2;

        cx = local_field(p,'cx',0); cy = local_field(p,'cy',0);
        obj = obj + lam_center * (cx.^2 + cy.^2);

        if isfield(p,'shift_strength')
            use_shift = true;
            if isfield(cfg,'flags') && isfield(cfg.flags,'use_shift_model')
                use_shift = logical(cfg.flags.use_shift_model);
            end
            target_shift = 0;
            if use_shift
                target_shift = local_cfg(cfg, {'inv','shift_prior_ref'}, 0.05);
            end
            obj = obj + lam_shift * (p.shift_strength - target_shift).^2;
        end

        if isfield(state,'prev_params') && isstruct(state.prev_params)
            pp = state.prev_params;
            obj = obj + lam_temporal * (local_field(p,'cx',0)-local_field(pp,'cx',0)).^2;
            obj = obj + lam_temporal * (local_field(p,'cy',0)-local_field(pp,'cy',0)).^2;
            obj = obj + 0.4*lam_temporal * (local_field(p,'ax',ax)-local_field(pp,'ax',ax)).^2;
            obj = obj + 0.4*lam_temporal * (local_field(p,'ay',ay)-local_field(pp,'ay',ay)).^2;
        end
    end

    if isfield(state,'z') && ~isempty(state.z)
        z = state.z(:);
        obj = obj + 0.20 * lam_contact * norm(z - mean(z))^2;
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

function v = local_field(s, name, default_val)
if isstruct(s) && isfield(s,name) && ~isempty(s.(name))
    v = s.(name);
else
    v = default_val;
end
end
