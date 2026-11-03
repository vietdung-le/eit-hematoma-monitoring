function p_new = update_background_sigma(model_state, state, y, w, cfg)
% Update background brain conductivity using safeguarded Gauss-Newton.

p = state.params;
pred = forward_from_state(model_state, p, state.z, cfg);
p1 = p;
p1.sigma_brain = p1.sigma_brain + cfg.inv.fd_eps_sigma;
pred1 = forward_from_state(model_state, p1, state.z, cfg);
J = (as_pred_vec(pred1) - as_pred_vec(pred)) / cfg.inv.fd_eps_sigma;

W = diag(w(:));
resid = y - as_pred_vec(pred);
H = J.' * W * J + cfg.reg.lambda_sigma;
g = J.' * W * resid;
if abs(H) < 1e-12
    ds = 0;
else
    ds = g / H;
end

base_val = p.sigma_brain;
obj_best = inf;
p_best = p;
for ls = cfg.inv.search.line_search
    p_try = p;
    p_try.sigma_brain = base_val + cfg.inv.step_sigma * ls * ds;
    p_try.sigma_brain = max(0.12, min(0.40, p_try.sigma_brain));
    pred_try = forward_from_state(model_state, p_try, state.z, cfg);
    [obj_try, ~] = compute_objective(y, as_pred_vec(pred_try), w, local_state(state, p_try), cfg);
    if obj_try < obj_best
        obj_best = obj_try;
        p_best = p_try;
    end
end
p_new = p_best;
end

function s = local_state(state, p)
s = state;
s.params = p;
end
