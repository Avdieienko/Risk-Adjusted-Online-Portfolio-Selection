function [w, portfolio_wealth] = solve_ubh(R_hist)
% SOLVE_UBH Uniform Buy-and-Hold.
%
% Inputs:
%   R_hist          - T x n matrix of price relatives (strictly > 0)
%
% Outputs:
%   w               - T x n weights used at each period before applying R_hist(t,:)
%   portfolio_wealth- (T+1) x 1 total wealth path, starting at 1
%   asset_wealth    - 1 x n per-asset wealth at the end

    [T, n] = size(R_hist);
    if any(R_hist(:) <= 0)
        error('Price relatives must be strictly positive.');
    end

    asset_wealth = ones(1, n) / n;
    portfolio_wealth = zeros(T + 1, 1);
    portfolio_wealth(1) = 1;
    w = zeros(T, n);

    for t = 1:T
        w(t, :) = asset_wealth / sum(asset_wealth);
        asset_wealth = asset_wealth .* R_hist(t, :);
        portfolio_wealth(t + 1) = sum(asset_wealth);
    end
end
