function [model_state, truth] = build_head_model(cfg)
% Build 2D EIDORS model with partial-boundary stimulation.

mesh_name = cfg.mesh_schedule{1};
imdl = mk_common_model(mesh_name, cfg.n_elec_total);
fmdl = imdl.fwd_model;

active = select_active_electrodes(cfg.n_elec_total, cfg.n_elec_active, cfg.active_elec_mode);
[stim, meas_sel] = create_partial_stim_patterns(cfg.n_elec_total, active);
fmdl.stimulation = stim;
fmdl.meas_select = meas_sel;

for k = 1:numel(fmdl.electrode)
    fmdl.electrode(k).z_contact = cfg.contact0(k);
end

cent = interp_mesh(fmdl);
img_bkg = mk_image(fmdl, cfg.sigma_scalp * ones(size(fmdl.elems,1),1));
r = sqrt(sum(cent.^2, 2));
img_bkg.elem_data(r <= 0.88) = cfg.sigma_skull;
img_bkg.elem_data(r <= 0.78) = cfg.sigma_brain;

truth = struct();
truth.base_img = img_bkg;
truth.elem_centers = cent;
truth.active_electrodes = active;

model_state = struct();
model_state.imdl = imdl;
model_state.fwd_model = fmdl;
model_state.img_background = img_bkg;
model_state.elem_centers = cent;
model_state.active_electrodes = active;
model_state.elec_xy = electrode_centers(fmdl);
model_state.contact_proj = build_contact_projection(fmdl);
model_state.mesh_level = 1;
model_state.mesh_name = mesh_name;
end

function active = select_active_electrodes(n_total, n_active, mode_name)
if n_active >= n_total
    active = 1:n_total;
    return;
end
switch string(mode_name)
    case "contiguous"
        active = 1:n_active;
    otherwise
        idx = round(linspace(1, n_total, n_active+1));
        active = unique(idx(1:end-1));
end
active = active(:).';
end
