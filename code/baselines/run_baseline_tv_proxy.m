function out = run_baseline_tv_proxy(problem)
% Edge-preserving proxy baseline for TV-like inversion.
%
% This is not an exact TV solver. It uses iteratively reweighted quadratic
% regularization to approximate edge-preserving behavior.

sigma = problem.sigma0(:);
J = problem.J;
dv = problem.dv(:);
G = problem.G; % gradient operator
lambda = problem.lambda;
eps_tv = problem.eps_tv;
max_iter = problem.max_iter;

history.residual = zeros(max_iter,1);

for k = 1:max_iter
    g = G*sigma;
    w = 1 ./ sqrt(g.^2 + eps_tv^2);
    Wtv = spdiags(w,0,length(w),length(w));

    A = (J'*J) + lambda*(G'*Wtv*G);
    b = J'*dv;
    sigma_new = A \ b;

    history.residual(k) = norm(dv - J*sigma_new);

    if norm(sigma_new - sigma) / max(norm(sigma_new),1e-12) < 1e-4
        sigma = sigma_new;
        history.residual = history.residual(1:k);
        break;
    end
    sigma = sigma_new;
end

out.sigma = sigma;
out.history = history;
out.residual = history.residual(end);
end
