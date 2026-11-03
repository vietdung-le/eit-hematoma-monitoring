function model_state_new = refine_fwd_model_uniform(model_state, cfg)
%REFINE_FWD_MODEL_UNIFORM Scheduled mesh refinement with state transfer.

model_state_new = model_state;
model_state_new.coarse2fine = [];

if ~isfield(cfg,'mesh_schedule') || isempty(cfg.mesh_schedule)
    warning('refine_fwd_model_uniform:fallback', 'No mesh_schedule configured.');
    return;
end

level = 1;
if isfield(model_state,'mesh_level') && ~isempty(model_state.mesh_level)
    level = model_state.mesh_level;
end
if level >= numel(cfg.mesh_schedule)
    return;
end

next_name = cfg.mesh_schedule{level+1};

try
    imdl = mk_common_model(next_name, cfg.n_elec_total);
    fmdl = imdl.fwd_model;

    if isfield(model_state,'active_electrodes') && ~isempty(model_state.active_electrodes)
        active = model_state.active_electrodes;
    else
        active = 1:cfg.n_elec_active;
    end

    [stim, meas_sel] = create_partial_stim_patterns(cfg.n_elec_total, active);
    fmdl.stimulation = stim;
    fmdl.meas_select = meas_sel;

    for k = 1:numel(fmdl.electrode)
        fmdl.electrode(k).z_contact = cfg.contact0(k);
    end

    cent_new = interp_mesh(fmdl);
    img_bkg = mk_image(fmdl, cfg.sigma_scalp * ones(size(fmdl.elems,1),1));
    r = sqrt(sum(cent_new.^2, 2));
    img_bkg.elem_data(r <= 0.88) = cfg.sigma_skull;
    img_bkg.elem_data(r <= 0.78) = cfg.sigma_brain;

    model_state_new.imdl = imdl;
    model_state_new.fwd_model = fmdl;
    model_state_new.img_background = img_bkg;
    model_state_new.elem_centers = cent_new;
    model_state_new.active_electrodes = active;
    model_state_new.elec_xy = electrode_centers(fmdl);
    model_state_new.contact_proj = build_contact_projection(fmdl);
    model_state_new.mesh_level = level + 1;
    model_state_new.mesh_name = next_name;

    if isfield(model_state,'elem_centers') && ~isempty(model_state.elem_centers) && isfield(model_state,'img_background') ...
            && ~isempty(model_state.img_background) && numel(model_state.img_background.elem_data) == size(model_state.elem_centers,1)
        model_state_new.img_background.elem_data = local_transfer_field(model_state.elem_centers, model_state.img_background.elem_data(:), cent_new);
    end

    model_state_new.sigma = model_state_new.img_background.elem_data(:);

catch ME
    warning('refine_fwd_model_uniform:fallback', ...
        'Refinement backend unavailable or invalid, keeping old mesh: %s', ME.message);
    model_state_new = model_state;
    model_state_new.coarse2fine = [];
end
end

function vals_new = local_transfer_field(cent_old, vals_old, cent_new)
vals_old = vals_old(:);
vals_new = zeros(size(cent_new,1),1);
for i = 1:size(cent_new,1)
    d2 = sum((cent_old - cent_new(i,:)).^2, 2);
    [~, idx] = min(d2);
    vals_new(i) = vals_old(idx);
end
end
