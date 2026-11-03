function metrics = evaluate_metrics(results, truth, meas, cfg)
%EVALUATE_METRICS Evaluate frame-wise reconstruction metrics.
%
% Besides the legacy axis-aligned parameter-box Dice, Revision 5 reports an
% oriented ellipse Dice diagnostic. The latter includes the fixed orientation
% mismatch (truth 15 deg versus inversion 5 deg) and therefore prevents the
% box score from being interpreted as a rotation-aware overlap metric.

if nargin < 4 || isempty(cfg)
    cfg = struct();
end

nT = numel(results.frames);
frame_metrics = cell(nT,1);

dice_all = nan(nT,1);
ellipse_dice_all = nan(nT,1);
centroid_err_all = nan(nT,1);
contact_err_all = nan(nT,1);
resid_all = nan(nT,1);
mesh_all = nan(nT,1);
adapt_all = nan(nT,1);

for t = 1:nT
    fr = results.frames{t};

    if isfield(fr,'state') && isstruct(fr.state) && isfield(fr.state,'params')
        pR = fr.state.params;
    else
        pR = struct();
    end

    if isfield(fr,'state') && isstruct(fr.state) && isfield(fr.state,'z')
        zR = fr.state.z(:);
    else
        zR = [];
    end

    if isfield(truth,'params')
        if iscell(truth.params)
            pT = truth.params{t};
        elseif numel(truth.params) >= t
            pT = truth.params(t);
        else
            pT = truth.params;
        end
    else
        pT = struct();
    end

    zT = [];
    if nargin >= 3 && isstruct(meas) && isfield(meas,'z_true') && numel(meas.z_true) >= t && ~isempty(meas.z_true{t})
        zT = meas.z_true{t}(:);
    elseif isfield(truth,'z')
        if iscell(truth.z) && numel(truth.z) >= t
            zT = truth.z{t}(:);
        else
            zT = truth.z(:);
        end
    end

    dice_val = local_param_overlap(pR, pT);
    ellipse_dice_val = local_oriented_ellipse_dice(pR, pT, cfg);
    centroid_err = local_centroid_error(pR, pT);

    if ~isempty_builtin_safe(zR) && ~isempty_builtin_safe(zT)
        k = min(numel(zR), numel(zT));
        contact_err = norm(zR(1:k) - zT(1:k)) / max(norm(zT(1:k)), 1e-12);
    else
        contact_err = NaN;
    end

    % Prefer a direct residual recomputation from the saved final prediction.
    % This also repairs legacy deterministic bundles whose frame.resid field
    % was stored before the final accepted state update.
    resid_val = local_recompute_residual(fr, meas, t);

    if isfield(fr,'model_state') && isstruct(fr.model_state) && isfield(fr.model_state,'fwd_model')
        mesh_elems = size(fr.model_state.fwd_model.elems,1);
    else
        mesh_elems = NaN;
    end

    acc_adapt = 0;
    if isfield(fr,'accepted_adapt') && ~isempty_builtin_safe(fr.accepted_adapt)
        acc_adapt = double(logical(fr.accepted_adapt));
    end

    fm = struct();
    fm.frame = t;
    fm.dice = dice_val;
    fm.ellipse_dice = ellipse_dice_val;
    fm.centroid_error = centroid_err;
    fm.contact_rel_error = contact_err;
    fm.residual = resid_val;
    fm.mesh_elems = mesh_elems;
    fm.accepted_adapt = acc_adapt;
    frame_metrics{t} = fm;

    dice_all(t) = dice_val;
    ellipse_dice_all(t) = ellipse_dice_val;
    centroid_err_all(t) = centroid_err;
    contact_err_all(t) = contact_err;
    resid_all(t) = resid_val;
    mesh_all(t) = mesh_elems;
    adapt_all(t) = acc_adapt;
end

metrics = struct();
metrics.frame_metrics = frame_metrics;
metrics.mean_dice = mean(dice_all, 'omitnan');
metrics.mean_ellipse_dice = mean(ellipse_dice_all, 'omitnan');
metrics.mean_centroid_error = mean(centroid_err_all, 'omitnan');
metrics.mean_contact_rel_error = mean(contact_err_all, 'omitnan');
metrics.mean_relative_residual = mean(resid_all, 'omitnan');
metrics.total_adapt = sum(adapt_all, 'omitnan');
metrics.mean_mesh_gain = local_mesh_gain(frame_metrics);

idx = find(~isnan(mesh_all),1,'last');
if isempty_builtin_safe(idx)
    metrics.final_mesh_elems = NaN;
else
    metrics.final_mesh_elems = mesh_all(idx);
end
end

function r = local_recompute_residual(fr, meas, t)
r = NaN;
try
    if isfield(fr,'pred') && ~isempty_builtin_safe(fr.pred) && ...
            isstruct(meas) && isfield(meas,'voltage') && numel(meas.voltage) >= t
        y = meas.voltage{t};
        pred = as_pred_vec(fr.pred);
        if isfield(meas,'weights') && numel(meas.weights) >= t && ~isempty_builtin_safe(meas.weights{t})
            w = meas.weights{t};
        elseif isfield(meas,'weight') && numel(meas.weight) >= t && ~isempty_builtin_safe(meas.weight{t})
            w = meas.weight{t};
        else
            w = ones(size(y));
        end
        y = y(:); w = w(:); pred = pred(:);
        k = min([numel(y), numel(w), numel(pred)]);
        r = norm((y(1:k) - pred(1:k)) .* w(1:k));
        return;
    end
catch
end
if isfield(fr,'resid') && ~isempty_builtin_safe(fr.resid)
    r = fr.resid;
end
end

function d = local_oriented_ellipse_dice(pR, pT, cfg)
n = 301;
try
    if isfield(cfg,'metrics') && isfield(cfg.metrics,'ellipse_dice_grid') && ~isempty(cfg.metrics.ellipse_dice_grid)
        n = max(101, round(cfg.metrics.ellipse_dice_grid));
    end
catch
end

v = linspace(-1,1,n);
[X,Y] = meshgrid(v,v);
maskR = local_ellipse_mask(X,Y,pR);
maskT = local_ellipse_mask(X,Y,pT);
inter = nnz(maskR & maskT);
areaR = nnz(maskR);
areaT = nnz(maskT);
d = 2*inter / max(areaR + areaT, 1);
d = max(0, min(1, d));
end

function m = local_ellipse_mask(X,Y,p)
cx = local_get_field(p, 'cx', 0);
cy = local_get_field(p, 'cy', 0);
ax = max(local_get_field(p, 'ax', 0.05), 1e-6);
ay = max(local_get_field(p, 'ay', 0.05), 1e-6);
rot = local_get_field(p, 'rot', 0);
dx = X - cx;
dy = Y - cy;
xr = cos(rot).*dx + sin(rot).*dy;
yr = -sin(rot).*dx + cos(rot).*dy;
m = (xr./ax).^2 + (yr./ay).^2 <= 1;
end

function g = local_mesh_gain(frame_metrics)
vals = nan(numel(frame_metrics),1);
for i = 1:numel(frame_metrics)
    if isfield(frame_metrics{i},'mesh_elems')
        vals(i) = frame_metrics{i}.mesh_elems;
    end
end
vals = vals(~isnan(vals));
if isempty_builtin_safe(vals)
    g = NaN;
else
    g = vals(end) / max(vals(1),1);
end
end

function d = local_param_overlap(pR, pT)
boxR = local_param_to_box(pR);
boxT = local_param_to_box(pT);
inter = local_box_intersection(boxR, boxT);
areaR = max(boxR(3)*boxR(4), 1e-12);
areaT = max(boxT(3)*boxT(4), 1e-12);
d = 2*inter / (areaR + areaT + 1e-12);
d = max(0, min(1, d));
end

function e = local_centroid_error(pR, pT)
cxR = local_get_field(pR, 'cx', 0);
cyR = local_get_field(pR, 'cy', 0);
cxT = local_get_field(pT, 'cx', 0);
cyT = local_get_field(pT, 'cy', 0);
e = sqrt((cxR-cxT)^2 + (cyR-cyT)^2);
end

function box = local_param_to_box(p)
cx = local_get_field(p, 'cx', 0);
cy = local_get_field(p, 'cy', 0);
ax = max(local_get_field(p, 'ax', 0.05), 1e-6);
ay = max(local_get_field(p, 'ay', 0.05), 1e-6);
box = [cx-ax, cy-ay, 2*ax, 2*ay];
end

function a = local_box_intersection(b1, b2)
x1 = max(b1(1), b2(1));
y1 = max(b1(2), b2(2));
x2 = min(b1(1)+b1(3), b2(1)+b2(3));
y2 = min(b1(2)+b1(4), b2(2)+b2(4));
w = max(0, x2-x1);
h = max(0, y2-y1);
a = w*h;
end

function v = local_get_field(s, name, default_val)
if isstruct(s) && isfield(s, name)
    val = s.(name);
    if ~isempty_builtin_safe(val)
        v = val;
        return;
    end
end
v = default_val;
end

function tf = isempty_builtin_safe(x)
tf = builtin('isempty', x);
end
