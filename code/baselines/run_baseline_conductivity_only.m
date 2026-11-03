function out = run_baseline_conductivity_only(problem)
% Conductivity-only + contact estimation baseline.
%
% Alternating updates:
%   1) sigma update with Tikhonov
%   2) z update with damped least squares

sigma = problem.sigma0(:);
z = problem.z0(:);

J_sigma = problem.J_sigma;
J_z = problem.J_z;
dv = problem.dv(:);

lambda_sigma = problem.lambda_sigma;
lambda_z = problem.lambda_z;
max_iter = problem.max_iter;

history.residual = zeros(max_iter,1);

for k = 1:max_iter
    r = dv - J_sigma*sigma - J_z*z;

    A_sigma = (J_sigma'*J_sigma) + lambda_sigma*speye(length(sigma));
    b_sigma = J_sigma'*r;
    ds = A_sigma \ b_sigma;
    sigma = sigma + ds;

    r = dv - J_sigma*sigma - J_z*z;
    A_z = (J_z'*J_z) + lambda_z*speye(length(z));
    b_z = J_z'*r;
    dz = A_z \ b_z;
    z = max(z + dz, 1e-6);

    history.residual(k) = norm(dv - J_sigma*sigma - J_z*z);

    if norm(ds) / max(norm(sigma),1e-12) < 1e-4 && norm(dz) / max(norm(z),1e-12) < 1e-4
        history.residual = history.residual(1:k);
        break;
    end
end

out.sigma = sigma;
out.z = z;
out.history = history;
out.residual = history.residual(end);
end
