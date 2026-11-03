function xy = electrode_centers(fmdl)
xy = zeros(numel(fmdl.electrode), 2);
for k = 1:numel(fmdl.electrode)
    nd = fmdl.electrode(k).nodes;
    pts = fmdl.nodes(nd,:);
    xy(k,:) = mean(pts,1);
end
end
