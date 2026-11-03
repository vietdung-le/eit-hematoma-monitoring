function p_best = update_hematoma_params(model_state, state, y, w, cfg)
%UPDATE_HEMATOMA_PARAMS Strong shape/growth/shift search.

p0 = state.params;
[p_best, ~, ~] = local_dictionary_search(model_state, p0, state, y, w, cfg);
end

function [p_best, pred_best, obj_best] = local_dictionary_search(model_state, p0, state, y, w, cfg)
p_best = p0;
pred_best = forward_from_state(model_state, p0, state.z, cfg);
[obj_best, ~] = compute_objective(y, pred_best, w, local_state(state, p_best), cfg);

cx_step = local_cfg(cfg, {'inv','search','cx_step'}, 0.04);
cy_step = local_cfg(cfg, {'inv','search','cy_step'}, 0.04);
ax_step = local_cfg(cfg, {'inv','search','ax_step'}, 0.02);
ay_step = local_cfg(cfg, {'inv','search','ay_step'}, 0.02);
sh_step = local_cfg(cfg, {'inv','search','shift_step'}, 0.015);

steps_ax = [0, ax_step, 2*ax_step, 3*ax_step, -ax_step];
steps_ay = [0, ay_step, 2*ay_step, -ay_step];
steps_cx = [0, -cx_step, cx_step];
steps_cy = [0, -cy_step, cy_step];

use_shift = true;
if isfield(cfg,'flags') && isfield(cfg.flags,'use_shift_model')
    use_shift = logical(cfg.flags.use_shift_model);
end
if use_shift
    steps_sh = [0, sh_step, 2*sh_step, -sh_step];
else
    steps_sh = 0;
    if isfield(p0,'shift_strength'), p0.shift_strength = 0; end
end

for dax = steps_ax
    for day = steps_ay
        for dcx = steps_cx
            for dcy = steps_cy
                for dsh = steps_sh
                    p_try = p0;
                    if isfield(p_try,'ax'), p_try.ax = max(0.02, p_try.ax + dax); end
                    if isfield(p_try,'ay'), p_try.ay = max(0.02, p_try.ay + day); end
                    if isfield(p_try,'cx'), p_try.cx = p_try.cx + dcx; end
                    if isfield(p_try,'cy'), p_try.cy = p_try.cy + dcy; end
                    if isfield(p_try,'shift_strength')
                        if use_shift
                            p_try.shift_strength = max(0, p_try.shift_strength + dsh);
                        else
                            p_try.shift_strength = 0;
                        end
                    end

                    pred_try = forward_from_state(model_state, p_try, state.z, cfg);
                    [obj_try, ~] = compute_objective(y, pred_try, w, local_state(state, p_try), cfg);

                    if obj_try < obj_best
                        obj_best = obj_try;
                        p_best = p_try;
                        pred_best = pred_try;
                    end
                end
            end
        end
    end
end

if isfield(state,'prev_params') && isstruct(state.prev_params)
    if isfield(p_best,'cx') && isfield(state.prev_params,'cx')
        p_best.cx = 0.84*p_best.cx + 0.16*state.prev_params.cx;
    end
    if isfield(p_best,'cy') && isfield(state.prev_params,'cy')
        p_best.cy = 0.84*p_best.cy + 0.16*state.prev_params.cy;
    end
end
end

function s = local_state(state, p)
s = state;
s.params = p;
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
