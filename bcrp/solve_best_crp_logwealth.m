function [w_best, wealth, loss] = solve_best_crp_logwealth(R_hist, arg2)
% Best Constant Rebalanced Portfolio (BCRP) in terms of log-wealth.
% Solves for the best fixed portfolio in hindsight that maximizes cumulative log-wealth.
% w_best = argmax_{w in simplex} sum_{t} log(w^T r_t)
%
% R_hist: t x n price relatives
% arg2:
%   - function handle loss_func(w, r), or
%   - n x 1 initial weights

    ensure_dependency_paths();

    [t, n] = size(R_hist);
    if any(R_hist(:) <= 0)
        error('Price relatives must be strictly positive.');
    end

    [w_init, loss_func] = parse_inputs(arg2, n);
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
    port_rel = R_hist * w_best;
    wealth = [1; cumprod(port_rel)];
    loss = zeros(t, 1);
    for s = 1:t
        loss(s) = loss_func(w_best, R_hist(s,:)');
    end
end

function [w_init, loss_func] = parse_inputs(arg2, n)
    default_loss = @(w, r) -log(max(w' * r, 1e-12));

    if nargin < 1 || isempty(arg2)
        w_init = ones(n, 1) / n;
        loss_func = default_loss;
        return;
    end

    if isa(arg2, 'function_handle')
        w_init = ones(n, 1) / n;
        loss_func = arg2;
        return;
    end

    w_init = arg2(:);
    if numel(w_init) ~= n
        error('w_init must have one element per asset.');
    end
    loss_func = default_loss;
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
