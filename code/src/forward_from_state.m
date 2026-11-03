function pred = forward_from_state(model_state, params, z, cfg)
%FORWARD_FROM_STATE Predict boundary measurements from current param state.
% Shape/growth/shift are primary; contact is a meaningful nuisance term.

fmdl = model_state.fwd_model;

if isfield(model_state,'img_background') && ~isempty(model_state.img_background)
    img = apply_hematoma_and_shift(model_state.img_background, params, cfg);
else
    n_elem = size(fmdl.elems,1);
    sigma_bg = local_sigma_bg(cfg);
    img = mk_image(fmdl, sigma_bg * ones(n_elem,1));
end

img.fwd_model = fmdl;

if nargin >= 3 && ~isempty(z)
    z = z(:);
    for k = 1:min(numel(fmdl.electrode), numel(z))
        img.fwd_model.electrode(k).z_contact = z(k);
    end
end

sol = fwd_solve(img);
pred = as_pred_vec(sol);

if nargin >= 3 && ~isempty(z) && isfield(cfg,'contact_forward_gain') && ~isempty(cfg.contact_forward_gain) ...
        && cfg.contact_forward_gain > 0
    C = build_contact_projection(fmdl);
    if ~isempty(C)
        k = min(size(C,2), numel(z));
        % Use the same forward contact sensitivity for truth and inversion.
        % Contact-jitter magnitude changes z_true in simulate_measurements;
        % it must not alter the inverse forward model through known truth metadata.
        contact_scale = 0.70 * cfg.contact_forward_gain;
        pred = pred + contact_scale * C(:,1:k) * (z(1:k) - mean(z(1:k)));
    end
end

pred = pred(:);
end

function sigma_bg = local_sigma_bg(cfg)
sigma_bg = [];
fields = {'sigma_bg_init','sigma_bg','sigma_init','background_sigma','sigma_brain'};
for i = 1:numel(fields)
    f = fields{i};
    if isfield(cfg,f) && ~isempty(cfg.(f)) && isnumeric(cfg.(f))
        sigma_bg = cfg.(f);
        break;
    end
end
if isempty(sigma_bg), sigma_bg = 1.0; end
end
