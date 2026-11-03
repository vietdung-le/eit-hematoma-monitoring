function plot_mesh_progression(out, cfg)
% Save before/after mesh visualizations for the adaptive method.

if isempty(out.results.model_state)
    return;
end
ms0 = out.model_state0;
ms1 = out.results.model_state{end};
fig = figure('Visible','off','Color','w','Position',[100 100 1200 520]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');

nexttile;
local_plot_mesh(ms0.fwd_model, out.truth.params(1));
title(sprintf('Initial mesh: %s (%d elems)', strrep(ms0.mesh_name,'_',' '), size(ms0.fwd_model.elems,1)), 'Interpreter','none');

nexttile;
local_plot_mesh(ms1.fwd_model, out.results.frames{end}.params);
title(sprintf('Final mesh: %s (%d elems)', strrep(ms1.mesh_name,'_',' '), size(ms1.fwd_model.elems,1)), 'Interpreter','none');

exportgraphics(fig, fullfile(cfg.results_dir, sprintf('%s_mesh_progression.png', char(out.case.name))), 'Resolution', 180);
close(fig);
end

function local_plot_mesh(fmdl, p)
patch('Faces',fmdl.elems,'Vertices',fmdl.nodes,'FaceColor','none','EdgeColor',[0.4 0.4 0.4]);
hold on;
t = linspace(0, 2*pi, 160);
R = [cos(p.rot), -sin(p.rot); sin(p.rot), cos(p.rot)];
xy = R * [p.ax*cos(t); p.ay*sin(t)];
plot(p.cx + xy(1,:), p.cy + xy(2,:), 'LineWidth', 1.4);
axis equal tight;
set(gca,'XTick',[],'YTick',[]);
box on;
end
