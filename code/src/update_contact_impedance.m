function z_new = update_contact_impedance(model_state, state, y, w, pred, cfg)
%UPDATE_CONTACT_IMPEDANCE Bounded contact nuisance update.
%
% Revision 5 removes all use of the known simulated contact-jitter level
% from the inverse update. Step limits, scaling, and shrinkage are controlled
% only by inverse configuration fields.

z = state.z(:);
n_z = numel(z);
pred0 = as_pred_vec(pred);
y = y(:); w = w(:);

k0 = min([numel(y), numel(w), numel(pred0)]);
y = y(1:k0); w = w(1:k0); pred0 = pred0(1:k0);

if n_z == 0
    z_new = z;
    return;
end

fd_eps = local_cfg(cfg, {'inv','fd_eps_contact'}, 4e-4);
J = zeros(k0, n_z);

for k = 1:n_z
    zt = z;
    zt(k) = zt(k) + fd_eps;
    p1 = as_pred_vec(forward_from_state(model_state, state.params, zt, cfg));
    kk = min(k0, numel(p1));
    J(1:kk,k) = ((p1(1:kk) - pred0(1:kk)) .* w(1:kk)) / fd_eps;
end

r = (y - pred0) .* w;
lam = max(local_cfg(cfg, {'reg','lambda_contact'}, 6e-4), 6e-4);
A = J.' * J + lam * eye(n_z);
b = J.' * r;
dz = A \ b;

max_rel_step = local_cfg(cfg, {'inv','contact_max_rel_step'}, 0.10);
den = max(abs(z), 1e-6);
rel = abs(dz) ./ den;
mx = max(rel);
if mx > max_rel_step
    dz = dz * (max_rel_step / mx);
end

step_scale = local_cfg(cfg, {'inv','step_contact'}, 0.50);
z_new = z + step_scale * dz;

bounds = [1e-3, 0.06];
if isfield(cfg,'contact_recon_bounds') && numel(cfg.contact_recon_bounds) == 2
    bounds = cfg.contact_recon_bounds;
end
z_new = min(bounds(2), max(bounds(1), z_new));

zbar = mean(z_new);
shrink = local_cfg(cfg, {'inv','contact_shrink'}, 0.08);
z_new = (1-shrink) * z_new + shrink * zbar;
end

function v = local_cfg(cfg, path, default_val)
v = default_val;
try
    cur = cfg;
    for i = 1:numel(path)
        cur = cur.(path{i});
    end
    if isnumeric(cur) && ~isempty(cur)
        v = cur;
    end
catch
end
end
