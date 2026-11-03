function mask = make_hematoma_mask(pts, cx, cy, ax, ay, rot)
% Rotated elliptical lesion mask.

R = [cos(rot), -sin(rot); sin(rot), cos(rot)];
xy = (pts(:,1:2) - [cx, cy]) * R;
mask = (xy(:,1)./max(ax,eps)).^2 + (xy(:,2)./max(ay,eps)).^2 <= 1;
end
