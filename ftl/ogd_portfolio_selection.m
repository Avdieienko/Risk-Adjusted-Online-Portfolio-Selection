function out = ogd_portfolio_selection(R, eta, loss_func, w0)
% OGD_PORTFOLIO_SELECTION
% Online Gradient Descent (Euclidean) for portfolio selection on the simplex.
%
% Inputs:
%   R            - T x n matrix of price relatives (gross returns), R(t,i)>0
%   eta0         - base learning rate (scalar)
%   loss_type    - "linear" or "logwealth"
%   w0           - n x 1 initial weights (optional, default uniform)
%   use_schedule - true/false, if true eta_t = eta0/sqrt(t)
%
% Output struct out:
%   out.W        - T x n matrix of weights
%   out.wealth   - (T+1) x 1 wealth path, wealth(1)=1
%   out.port_rel - T x 1 portfolio gross returns each step (w_t' r_t)

    ensure_dependency_paths();

    if isempty(w0)
        n = size(R,2);
        w0 = ones(n,1)/n;
    end
    [T, n] = size(R);

    % Basic checks
    if any(R(:) <= 0)
        error('All price relatives must be strictly positive.');
    end
    w = simplexProjection(w0(:));

    W = zeros(T, n);
    wealth = ones(T+1, 1);
    port_rel = zeros(T, 1);

    for t = 1:T
        rt = R(t,:)';

        % Record weights used this period
        W(t,:) = w';

        % Realised portfolio gross return and wealth update
        pr = w' * rt;
        port_rel(t) = pr;
        wealth(t+1) = wealth(t) * pr;


        % One OGD step
        w = simple_ogd_update(w, rt, eta, @(w,r) loss_func(w,r));
    end

    out.W = W;
    out.wealth = wealth;
    out.port_rel = port_rel;
end

function ensure_dependency_paths()
    thisDir = fileparts(mfilename('fullpath'));
    rootDir = fileparts(thisDir);
    addpath(thisDir);
    addpath(rootDir);

    utilsDir = fullfile(rootDir, 'utils');
    if isfolder(utilsDir)
        addpath(utilsDir);
    end
end
