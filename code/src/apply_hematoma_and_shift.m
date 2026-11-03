function img = apply_hematoma_and_shift(base_img, params, cfg)
%APPLY_HEMATOMA_AND_SHIFT Shape+growth+shift focused conductivity update.
% Tuned toward the stronger review22-style behavior.

img = base_img;
cent = interp_mesh(base_img.fwd_model);

mask_core = make_hematoma_mask(cent, params.cx, params.cy, params.ax, params.ay, params.rot);

r = sqrt(sum(cent.^2,2));
img.elem_data(r <= 0.78) = params.sigma_brain;
img.elem_data(mask_core) = cfg.sigma_blood;

% Halo makes lesion-size changes visible in the data.
mask_halo = make_hematoma_mask(cent, params.cx, params.cy, 1.18*params.ax, 1.18*params.ay, params.rot) & ~mask_core;
img.elem_data(mask_halo) = 0.65 * cfg.sigma_blood + 0.35 * params.sigma_brain;

use_shift = true;
if isfield(cfg,'flags') && isfield(cfg.flags,'use_shift_model')
    use_shift = logical(cfg.flags.use_shift_model);
end

if use_shift && isfield(params,'shift_strength') && params.shift_strength > 0
    d = make_displacement_field(cent, params, cfg);
    warped = cent - d;

    mask_shift = make_hematoma_mask(warped, params.cx, params.cy, params.ax, params.ay, params.rot);
    img.elem_data(mask_shift) = cfg.sigma_blood;

    rim_shift = make_hematoma_mask(warped, params.cx, params.cy, 1.12*params.ax, 1.12*params.ay, params.rot) & ~mask_shift;
    img.elem_data(rim_shift) = 0.50 * cfg.sigma_blood + 0.50 * params.sigma_brain;
end
end
