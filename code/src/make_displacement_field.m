function d = make_displacement_field(pts, params, cfg)
x = pts(:,1) - params.cx;
y = pts(:,2) - params.cy;
r = sqrt(x.^2 + y.^2) + eps;

decay = 0.24;
if isfield(cfg,'truth') && isfield(cfg.truth,'shift_decay') && ~isempty(cfg.truth.shift_decay)
    decay = cfg.truth.shift_decay;
end

radial = exp(-r / max(decay, 1e-3));
scale = 1.8 * params.shift_strength .* radial;
d = [scale .* x ./ r, scale .* y ./ r];
end
