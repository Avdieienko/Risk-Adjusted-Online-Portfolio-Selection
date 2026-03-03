function w_best = solve_best_crp_logwealth(R_hist, w_init)
% SOLVE_BEST_CRP_LOGWEALTH
% w_best = argmax_{w in simplex} sum_{t} log(w^T r_t)
%
% R_hist: t x n price relatives
% w_init: n x 1 initial weights

    ensure_dependency_paths();

    [t, n] = size(R_hist);
    if any(R_hist(:) <= 0)
        error('Price relatives must be strictly positive.');
    end

    w = simplexProjection(w_init(:));
    eps_denom = 1e-12;

    max_iter = 250;
    base_step = 0.2;

    for k = 1:max_iter
        grad = zeros(n,1);

        for s = 1:t
            r = R_hist(s,:)';
            denom = max(w' * r, eps_denom);
            grad = grad + r / denom;
        end

        eta = base_step / sqrt(k);

        w_new = simplexProjection(w + eta * grad);

        if norm(w_new - w, 1) < 1e-10
            w = w_new;
            break;
        end
        w = w_new;
    end

    w_best = w;
end

function ensure_dependency_paths()
    thisDir = fileparts(mfilename('fullpath'));
    rootDir = fileparts(thisDir);
    addpath(rootDir);

    utilsDir = fullfile(rootDir, 'utils');
    if isfolder(utilsDir)
        addpath(utilsDir);
    end
end
