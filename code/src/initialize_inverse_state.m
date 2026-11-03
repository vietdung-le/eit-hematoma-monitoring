function state = initialize_inverse_state(model_state, cfg)
state = struct();
state.params = struct();
state.params.cx = cfg.inv.cx0;
state.params.cy = cfg.inv.cy0;
state.params.ax = cfg.inv.ax0;
state.params.ay = cfg.inv.ay0;
state.params.rot = deg2rad(cfg.inv.rotation_deg0);
state.params.shift_strength = cfg.inv.shift_strength0;
state.params.sigma_brain = cfg.inv.sigma_brain0;

if isfield(cfg,'flags') && isfield(cfg.flags,'use_shift_model') && ~cfg.flags.use_shift_model
    state.params.shift_strength = 0;
end

state.z = cfg.contact0;
state.prev_params = state.params;
state.prev_z = state.z;
state.mesh_elements = size(model_state.fwd_model.elems,1);
end
