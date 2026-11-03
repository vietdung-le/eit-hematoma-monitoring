function w = robust_trim_weights(resid, bad_idx)
% Downweight outliers while keeping deterministic bad-channel trimming.

s = median(abs(resid - median(resid))) / 0.6745;
s = max(s, 1e-6);
w = 1 ./ (1 + (abs(resid) ./ (3*s)).^2);
if nargin > 1 && ~isempty(bad_idx)
    w(bad_idx) = 0.20 * w(bad_idx);
end
w = max(w, 0.05);
end
