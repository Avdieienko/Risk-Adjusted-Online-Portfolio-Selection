function [x, mu, K] = simplexProjection(y, a)
%PROJ_SIMPLEX  Euclidean projection of y onto the r-dim a-simplex:
%   Delta(a) = { x >= 0, sum(x) = a }.
%
% Inputs:
%   y : (r x 1) vector (or 1 x r row vector)
%   a : scalar > 0 (e.g., a = 1 for unit simplex)
%
% Outputs:
%   x  : projection of y onto simplex
%   mu : threshold (Lagrange multiplier for sum constraint)
%   K  : number of positive components in x

    if a <= 0
        error('a must be > 0');
    end
    y = y(:);                 % ensure column
    r = numel(y);

    % --- sort y descending
    [ys, idx] = sort(y, 'descend');

    % --- prefix sums S_k = sum_{j=1..k} y_(j)
    S = cumsum(ys);

    % --- candidate thresholds mu_k = (S_k - a) / k
    k = (1:r).';
    mu_candidates = (S - a) ./ k;

    % --- find K = max{k : y_(k) - mu_k > 0}
    is_active = ys - mu_candidates > 0;
    K = find(is_active, 1, 'last');

    % Edge case: if nothing active (can happen if a is tiny and y very negative)
    if isempty(K)
        % then the best you can do is put all mass on the max component
        % (still a valid simplex point)
        x = zeros(r,1);
        [~, imax] = max(y);
        x(imax) = a;
        mu = NaN;
        K = 1;
        return;
    end

    % --- final threshold mu
    mu = mu_candidates(K);

    % --- thresholding operator: x_i = max(0, y_i - mu)
    x = max(0, y - mu);
end
