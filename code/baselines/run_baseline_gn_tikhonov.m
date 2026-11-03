function out = run_baseline_gn_tikhonov(problem)
% GN + Tikhonov baseline for conductivity-only EIT inversion.
%
% Inputs:
%   problem struct with fields:
%     .J               Jacobian / sensitivity matrix
%     .dv              measured voltage difference vector
%     .lambda          Tikhonov parameter
%     .W               data weighting matrix (optional)
%     .R               regularization matrix (optional)
%     .sigma0          initial conductivity/state vector
%     .max_iter
%
% Output:
%   out struct with fields .sigma .history .residual

sigma = problem.sigma0(:);
J = problem.J;
dv = problem.dv(:);

if isfield(problem,'W') && ~isempty(problem.W)
    W = problem.W;
else
    W = speye(length(dv));
end

if isfield(problem,'R') && ~isempty(problem.R)
    R = problem.R;
else
    R = speye(length(sigma));
end

lambda = problem.lambda;
max_iter = problem.max_iter;

history.residual = zeros(max_iter,1);
history.stepnorm = zeros(max_iter,1);

for k = 1:max_iter
    r = dv - J*sigma;
    A = (J'*W*J) + lambda*(R'*R);
    b = J'*W*r;
    ds = A \ b;
    sigma = sigma + ds;

    history.residual(k) = norm(r);
    history.stepnorm(k) = norm(ds);

    if norm(ds) / max(norm(sigma),1e-12) < 1e-4
        history.residual = history.residual(1:k);
        history.stepnorm = history.stepnorm(1:k);
        break;
    end
end

out.sigma = sigma;
out.history = history;
out.residual = history.residual(end);
end
